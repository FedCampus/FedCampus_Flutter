import 'dart:async';

import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/models/screen_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utility/calendar.dart' as calendar;

class HealthDataModel extends ChangeNotifier {
  Map<String, double> healthData = HealthData.mapOf();
  Map<String, double> screenData = ScreenData.mapOf();
  bool isAuth = false;
  bool _loading = false;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  static final dataList = [
    "step",
    "calorie",
    "distance",
    "stress",
    "rest_heart_rate",
    "intensity",
    "exercise_heart_rate",
    "step_time",
    "sleep_efficiency"
  ];

  bool get isAuthenticated => isAuth;

  String get date => _date;

  set isAuthenticated(bool auth) {
    isAuth = auth;
    userApi.prefs.setBool("login", auth);
    notifyListeners();
  }

  bool get loading => _loading;

  set date(String date) {
    _date = date;
    getBodyData();
    getScreenData();
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(int.parse(_date));
  }

  Future<void> getScreenData({bool forcedRefresh = false}) async {
    Map<String, double> res = await userApi.screenTimeDataHandler.getDataMap(
        entry: [""],
        startTime: calendar.intToDateTime(int.parse(date)),
        endTime: calendar
            .intToDateTime(int.parse(date))
            .add(const Duration(days: 1)));
    screenData.addAll(res);
    logger.e(screenData);
    notifyListeners();
  }

  Future<void> getBodyData({bool forcedRefresh = false}) async {
    _loading = true;
    notifyListeners();
    int date = int.parse(_date);
    try {
      healthData = await userApi.healthDataHandler
          .getCachedBodyData(calendar.intToDateTime(date), dataList);
      _loading = false;
      logger.e(healthData);
      notifyListeners();
    } on PlatformException catch (error) {
      logger.e(error);
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");
        _loading = false;
        authAndGetData();
      } else if (error.message == "java.lang.SecurityException: 50030") {
        logger.d("internet issue");
        _loading = false;
        notifyListeners();
        Fluttertoast.showToast(
            msg: "Internet Connection Issue, please connect to Internet.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      return;
    }
  }

  void authAndGetData() async {
    await userApi.healthDataHandler.authenticate();
    await getBodyData();
    // old implementation to be removed
    // HuaweiAuthApi host = HuaweiAuthApi();
    // try {
    //   await host.getAuthenticate();
    //   getData();
    //   final dw = DataWrapper();
    //   dw.getDayDataAndSendAndTrain(int.parse(_date));
    // } on PlatformException catch (error) {
    //   logger.e(error);
    // }
  }
}
