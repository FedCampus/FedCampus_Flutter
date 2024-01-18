import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:fedcampus/models/activity_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/my_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utility/event_bus.dart';

class ActivityDataModel extends ChangeNotifier {
  Map<String, dynamic> activityData = ActivityData.create();
  bool ifSent = false;
  bool _loading = false;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  Map<String, dynamic> filterParams = {
    "status": "all",
    "student": 0,
    "gender": "all"
  };

  final dataList = DataWrapper.dataNameList;

  bool get loading => _loading;

  set date(String date) {
    _date = date;
    ifSent = false;
    getActivityData();
  }

  String get date => _date;

  void _setAndNotify(dynamic jsonValue, String category) {
    /// Update the value based on the catetory
    /// category can be either "average" or "rank"
    /// TODO: breaks Open–closed principle, needs refactor
    final jsonMap = jsonValue as Map<String, dynamic>;
    jsonMap.forEach((key, value) {
      if (activityData[key] != null) {
        if (category == "average") {
          activityData[key]['average'] = value;
        } else if (category == "rank") {
          activityData[key]['rank'] = value;
        } else if (category == "data_points") {
          activityData[key]['data_points'] = value;
        }
      }
      //calculate the average value of carbon emission
      if (category == "average") {
        activityData['carbon_emission']['average'] =
            activityData['distance']['average'] / 1000 * 42;
      } else if (category == "rank") {
        activityData['carbon_emission']['rank'] =
            activityData['distance']['rank'];
      } else if (category == "data_points") {
        activityData['carbon_emission']['data_points'] =
            activityData['distance']['data_points'].map((e) => e / 1000 * 42);
      }
    });
    _notify();
  }

  void _clearAll() {
    activityData = ActivityData.create();
  }

  Future<void> getActivityData({bool forcedRefresh = false}) async {
    forcedRefresh = userApi.isAndroid ? forcedRefresh : true;
    _loading = true;
    notifyListeners();
    _clearAll();
    // get data and send to the server
    final dataNumber = int.parse(_date);

    // send data to the server
    try {
      var dw = DataWrapper();
      await dw.getDayDataAndSendAndTrain(dataNumber);
      logger.i("sending data for FA done");

      // send avg request
      var res = await HTTPApi.post(HTTPApi.average, <String, String>{},
          jsonEncode({"time": dataNumber, "filter": filterParams}));
      logger.i("avg response ${res.body}");
      _setAndNotify(jsonDecode(res.body), "average");
      // send rank request

      res = await HTTPApi.post(HTTPApi.rank, <String, String>{},
          jsonEncode({"time": dataNumber, "filter": filterParams}));
      logger.i("rank response ${res.body}");
      _setAndNotify(jsonDecode(res.body), "rank");

      res = await HTTPApi.post(HTTPApi.dataPoints, <String, String>{},
          jsonEncode({"time": dataNumber}));
      logger.i("dataPoints ${res.body}");
      _setAndNotify(jsonDecode(res.body), "data_points");
    } on PlatformException {
      _notify();
    } on TimeoutException {
      _notify();
    } on SocketException {
      _notify();
      dataWrapperToast("Please connet to internet");
    } on InternetConnectionException {
      _notify();
      dataWrapperToast("Please connet to internet");
    } on AuthenticationException {
      _notify();
      dataWrapperToast("Please authenticate");
    }
  }

  void _notify() {
    _loading = false;
    logger.d(activityData);
    bus.emit("activity_loading_done");
    notifyListeners();
  }
}
