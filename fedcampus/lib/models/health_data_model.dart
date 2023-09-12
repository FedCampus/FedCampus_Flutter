import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HealthDataModel extends ChangeNotifier {
  Map<String, double> healthData = HealthData.mapOf();
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
    getData();
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(int.parse(_date));
  }

  Future<void> getData({bool forcedRefresh = false}) async {
    _loading = true;
    notifyListeners();
    int date = 0;
    logger.d(date);
    date = int.parse(_date);

    try {
      var dw = DataWrapper();
      String? cachedData = userApi.prefs.getString("health$date");
      if (!forcedRefresh && (cachedData != null)) {
        healthData = Map.castFrom<String, dynamic, String, double>(
            json.decode(cachedData));
        logger.e(healthData["query_time"]);
        if (DateTime.now().millisecondsSinceEpoch -
                (healthData["query_time"] ?? 0.0) <
            1800000) {
          _loading = false;
          notifyListeners();
          return;
        }
      }
      healthData = await dw.getDataListToMap(dataList, date);
      healthData["query_time"] =
          DateTime.now().millisecondsSinceEpoch.toDouble();
      userApi.prefs.setString("health$date", json.encode(healthData));
      _loading = false;
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
    await getData();
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
