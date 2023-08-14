import 'dart:async';

import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/me/user_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HealthDataModel extends ChangeNotifier {
  Map<String, double> healthData = HealthData.mapOf();
  bool isAuth = false;
  bool _loading = false;
  late final DataApi host;
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

  HealthDataModel() {
    host = DataApi();
  }

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
  }

  Future<void> getData() async {
    int date = 0;
    logger.d(date);
    date = int.parse(_date);

    for (var i in dataList) {
      healthData[i] = 0;
      _loading = true;
      notifyListeners();
    }

    try {
      var dw = DataWrapper();
      healthData = await dw.getDataListToMap(dataList, date);
      _loading = false;
      notifyListeners();
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");
        authAndGetData();
      } else if (error.message == "java.lang.SecurityException: 50030") {
        logger.d("internet issue");
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
    HuaweiAuthApi host = HuaweiAuthApi();
    try {
      await host.getAuthenticate();
      getData();
      final dw = DataWrapper();
      dw.getLastDayDataAndSend();
    } on PlatformException catch (error) {
      logger.e(error);
    }
  }

  Future<Data?> getDataEntry(DataApi host, String name, int time) async {
    List<Data?> dataList;
    try {
      dataList = await host.getData(name, time, time);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");
        // redirect the user to the authenticate page
        isAuthenticated = false;
        await userApi.healthServiceAuthenticate();
        dataList = await host.getData(name, time, time);
      } else if (error.message == "java.lang.SecurityException: 50030") {
        logger.d("internet error");
      } else {
        logger.e(error.toString());
      }
      logger.e("catching error $error");
      return null;
    }
    try {
      return dataList[0];
    } on RangeError {
      logger.i("no data for $name");
      return null;
    }
  }
}
