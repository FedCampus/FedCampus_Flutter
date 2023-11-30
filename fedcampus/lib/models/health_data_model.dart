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
  final Map<String, double> _screenData = ScreenData.mapOf();
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
    _loading = true;
    notifyListeners();
    // reset each entry to 0 whenever a new request is received.
    for (var k in _healthData.keys) {
      _healthData[k] = 0;
    }

    late List<Data> dataList;
    try {
      DataWrapper dw = DataWrapper();
      dataList =
          await dw.getDataList(DataWrapper.dataNameList, int.parse(_date));
      logger.i("data  ${dataListJsonEncode(dataList)}");
      _healthData.addAll(dataToMap(dataList));
    } on AuthenticationException catch (error) {
      logger.e(error);
      _notify();
      bus.emit("toast_error", "Not authenticated.");
      await userApi.healthDataHandler.authenticate();
    } on InternetConnectionException catch (error) {
      logger.e(error);
      _notify();
      bus.emit("toast_error",
          "Internet connection error, cannot connect to health data handler server.");
    }

    if (userApi.isAndroid) {
      try {
        var data = await _getScreenData();
        dataList.add(data);
        _healthData.addAll(dataToMap([data]));
      } catch (e) {
        logger.e(e);
        _notify();
        bus.emit("app_usage_stats_error",
            "You have not granted the permission to access phone usage, go to preferences of this application to redirect to system settings page");
      }
    }
    _notify();

    // send it to the server
    try {
      final dataJson = dataListJsonEncode(dataList);
      final dataFuzzJson = dataListJsonEncode(DataWrapper.fuzzData(dataList));
      List<http.Response> responseArr = await Future.wait([
        HTTPApi.sendData(dataJson),
        HTTPApi.sendData(dataFuzzJson, dp: true)
      ]).timeout(const Duration(seconds: 5));
      logger.i("Data Status Code ${responseArr[0].statusCode} : $dataJson");
      logger.i(
          "Data DP Status Code ${responseArr[1].statusCode} : $dataFuzzJson");
      if (responseArr[0].statusCode == 401) {
        dataWrapperToast("Data sent failed, Please Log in!");
      } else if (responseArr[0].statusCode == 200) {
        dataWrapperToast("success");
      }
    } on ClientException {
      remindDkuNetwork();
      return;
    } on TimeoutException {
      logger.d("internet issue");
      remindDkuNetwork();
      return;
    } on SocketException {
      dataWrapperToast("Please connect to Network");
      return;
    } catch (err, stackTrace) {
      logger.e("$err\n$stackTrace");
      dataWrapperToast("Unknown issue: $err. Please try again later.");
    }
  }

  /// Only work on Android.
  Future<Data> _getScreenData() async {
    // TODO: cache screen time in DB because the screen time data expires after several days
    Map<String, double> res = {};

    res = await userApi.screenTimeDataHandler.getDataMap(
        entry: [""],
        startTime: calendar.intToDateTime(int.parse(date)),
        endTime: calendar
            .intToDateTime(int.parse(date))
            .add(const Duration(days: 1)));

    final data = Data(
        name: "total_time_foreground",
        value: res['total_time_foreground']!,
        startTime: int.parse(date),
        endTime: int.parse(date));
    _screenData.addAll(res);
    logger.i(_screenData);
    return data;
  }

  void _notify() {
    logger.d("loading_done");
    bus.emit("loading_done");
    _loading = false;
    notifyListeners();
  }
}
