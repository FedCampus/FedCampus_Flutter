import 'dart:async';

import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/models/screen_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:flutter/material.dart';
import '../../utility/calendar.dart' as calendar;
import '../utility/event_bus.dart';
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
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(int.parse(_date));
  }

  Future<void> requestAllData({bool forcedRefresh = false}) async {
    _loading = true;
    notifyListeners();
    // reset each entry to 0 whenever a new request is received.
    for (var k in _healthData.keys) {
      _healthData[k] = 0;
    }

    try {
      _healthData.addAll(await _getBodyData(forcedRefresh: forcedRefresh));
    } on AuthenticationException catch (error) {
      logger.e(error);
      _notify();
      bus.emit("toast_error", "Not authenticated.");
      await userApi.healthDataHandler.authenticate();
    } on InternetConnectionException catch (error) {
      logger.e(error);
      _notify();
      bus.emit("toast_error",
          "Internet connection error, cannot connet to health data handler server.");
    }

    if (userApi.isAndroid) {
      try {
        _healthData.addAll(await _getScreenData());
      } catch (e) {
        logger.e(e);
        _notify();
        bus.emit("app_usage_stats_error",
            "You have not granted the permission to access phone usage, go to preferences of this application to redirect to system settings page");
      }
    }

    _notify();
  }

  /// Only work on Android.
  Future<Map<String, double>> _getScreenData() async {
    // TODO: cache screen time in DB because the screen time data expires after several days
    Map<String, double> res = {};

    res = await userApi.screenTimeDataHandler.getDataMap(
        entry: [""],
        startTime: calendar.intToDateTime(int.parse(date)),
        endTime: calendar
            .intToDateTime(int.parse(date))
            .add(const Duration(days: 1)));

    _screenData.addAll(res);
    logger.i(_screenData);
    return _screenData;
  }

  Future<Map<String, double>> _getBodyData({bool forcedRefresh = false}) async {
    int date = int.parse(_date);
    Map<String, double> res = {};

    res = await userApi.healthDataHandler.getCachedValueMapDay(
        calendar.intToDateTime(date), DataWrapper.dataNameList,
        forcedRefresh: userApi.isAndroid ? forcedRefresh : true);
    logger.d(res);

    return res;
  }

  void _notify() {
    logger.d("loading_done");
    bus.emit("loading_done");
    _loading = false;
    notifyListeners();
  }
}
