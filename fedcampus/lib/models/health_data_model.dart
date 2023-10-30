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
    requestAllData();
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(int.parse(_date));
  }

  void requestAllData({bool forcedRefresh = false}) async {
    _loading = true;
    notifyListeners();
    healthData = HealthData.mapOf();

    try {
      healthData.addAll(await _getBodyData(forcedRefresh: forcedRefresh));
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

    if (Platform.isAndroid) {
      try {
        healthData.addAll(await _getScreenData());
      } catch (e) {
        logger.e(e);
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

    screenData.addAll(res);
    logger.i(screenData);
    healthData.addAll(screenData);
    return screenData;
  }

  Future<Map<String, double>> _getBodyData({bool forcedRefresh = false}) async {
    int date = int.parse(_date);
    Map<String, double> res = {};

    res = await userApi.healthDataHandler.getCachedValueMapDay(
        calendar.intToDateTime(date), DataWrapper.dataNameList,
        forcedRefresh: Platform.isIOS ? true : forcedRefresh);
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
