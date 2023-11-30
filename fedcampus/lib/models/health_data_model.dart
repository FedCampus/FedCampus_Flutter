import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/models/screen_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:flutter/material.dart';
import '../../utility/calendar.dart' as calendar;
import '../utility/event_bus.dart';
import '../utility/http_api.dart';
import '../utility/my_exceptions.dart';

class HealthDataModel extends ChangeNotifier {
  final Map<String, double> _healthData = HealthData.mapOf();
  final nameList = [
    "step",
    "calorie",
    "distance",
    "stress",
    "rest_heart_rate",
    "intensity",
    "exercise_heart_rate",
    "step_time",
    "sleep_efficiency",
    "query_time",
    "total_time_foreground",
    "sleep_duration",
    "carbon_emission"
  ];
  bool _loading = false;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  Map<String, double> get healthData => Map.unmodifiable(_healthData);

  String get date => _date;

  bool get loading => _loading;

  set date(String date) {
    _date = date;
    requestAllData();
  }

  Future<void> requestAllData({bool forcedRefresh = false}) async {
    final List<Data> dataList;
    _loading = true;
    notifyListeners();
    // reset each entry to 0 whenever a new request is received.
    for (final k in _healthData.keys) {
      _healthData[k] = 0;
    }
    // assert keys of _healthData do not change
    assert(() {
      final mapKeys = _healthData.keys.toSet();
      final listElements = nameList.toSet();
      return mapKeys.length == listElements.length &&
          mapKeys.containsAll(listElements);
    }());

    // get health data
    try {
      DataWrapper dw = DataWrapper();
      dataList = await dw.getDataList(
          DataWrapper.dataNameList, int.parse(_date),
          forcedRefresh: forcedRefresh);
      logger.i("data  ${dataListJsonEncode(dataList)}");
    } on AuthenticationException catch (error) {
      _logAndNotify(error, "Not authenticated.");
      await userApi.healthDataHandler.authenticate();
      return;
    } on InternetConnectionException catch (error) {
      _logAndNotify(error,
          "Internet connection error, cannot connect to health data handler server.");
      return;
    }

    // get screen data on Android
    if (userApi.isAndroid) {
      try {
        final data =
            await _getScreenData(calendar.intToDateTime(int.parse(date)));
        assert(data.name == "total_time_foreground");
        dataList.add(data);
      } on Exception catch (e) {
        _logAndNotify(e,
            "You have not granted the permission to access phone usage, go to preferences of this application to redirect to system settings page");
        await userApi.screenTimeDataHandler.authenticate();
      }
    }

    // notify view to update data
    _healthData.addAll(dataToMap(dataList));
    _notify();

    // send it to the server
    try {
      await _sentToServer(dataList);
    } on ClientException catch (e) {
      _logAndNotify(e, "Please make sure you are connected to DKU network!");
    } on TimeoutException catch (e) {
      _logAndNotify(e, "Please make sure you are connected to DKU network!");
    } on SocketException catch (e) {
      _logAndNotify(e, "Please make sure you are connected to DKU network!");
    } on Exception catch (err, stackTrace) {
      logger.e("$err\n$stackTrace");
      _logAndNotify(err, "Please make sure you are connected to DKU network!");
    }
  }

  void _logAndNotify(Exception error, String message) {
    logger.e(error);
    _notify();
    bus.emit("toast_error", message);
  }

  Future<void> _sentToServer(List<Data> dataList) async {
    final dataJson = dataListJsonEncode(dataList);
    final dataFuzzJson = dataListJsonEncode(DataWrapper.fuzzData(dataList));
    List<http.Response> responseArr = await Future.wait([
      HTTPApi.sendData(dataJson),
      HTTPApi.sendData(dataFuzzJson, dp: true)
    ]).timeout(const Duration(seconds: 5));
    logger.i("Data Status Code ${responseArr[0].statusCode} : $dataJson");
    logger
        .i("Data DP Status Code ${responseArr[1].statusCode} : $dataFuzzJson");
    if (responseArr[0].statusCode == 401) {
      dataWrapperToast("Data sent failed, Please Log in!");
    } else if (responseArr[0].statusCode == 200) {
      dataWrapperToast("success");
    }
  }

  /// Only work on Android.
  Future<Data> _getScreenData(DateTime date) async {
    // TODO: cache screen time in DB because the screen time data expires after several days
    int dateCode = calendar.dateTimeToInt(date);
    final Map<String, double> res =
        await userApi.screenTimeDataHandler.getDataMap(
      entry: [""],
      startTime: date,
      endTime: date.add(const Duration(days: 1)),
    );

    return Data(
      name: "total_time_foreground",
      value: res['total_time_foreground']!,
      startTime: dateCode,
      endTime: dateCode,
    );
  }

  void _notify() {
    logger.d("loading_done");
    bus.emit("loading_done");
    _loading = false;
    notifyListeners();
  }
}
