import 'dart:async';
import 'dart:io' show Platform;

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
  Map<String, double> healthData = HealthData.mapOf();
  Map<String, double> screenData = ScreenData.mapOf();
  bool isAuth = false;
  bool _loading = false;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  String get date => _date;

  bool get loading => _loading;

  set date(String date) {
    _date = date;
    getBodyData();
    getScreenData();
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(int.parse(_date));
  }

  Future<void> getScreenData({bool forcedRefresh = false}) async {
    Map<String, double> res = {};
    try {
      res = await userApi.screenTimeDataHandler.getDataMap(
          entry: [""],
          startTime: calendar.intToDateTime(int.parse(date)),
          endTime: calendar
              .intToDateTime(int.parse(date))
              .add(const Duration(days: 1)));
    } catch (e) {
      // logger.e(e);
      // bus.emit("app_usage_stats_error", "Not authenticated.");
    }
    screenData.addAll(res);
    logger.i(screenData);
    notifyListeners();
  }

  Future<void> getBodyData({bool forcedRefresh = false}) async {
    _loading = true;
    notifyListeners();
    int date = int.parse(_date);
    try {
      healthData = await userApi.healthDataHandler.getCachedValueMapDay(
          calendar.intToDateTime(date), DataWrapper.dataNameList,
          forcedRefresh: Platform.isIOS ? true : forcedRefresh);
      logger.d(healthData);
      _notify();
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
  }

  void _notify() {
    logger.d("loading_done");
    bus.emit("loading_done");
    _loading = false;
    notifyListeners();
  }
}
