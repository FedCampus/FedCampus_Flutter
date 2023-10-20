import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:fedcampus/models/activity_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../utility/event_bus.dart';
import '../utility/fluttertoast.dart';

class ActivityDataModel extends ChangeNotifier {
  Map<String, dynamic> activityData = ActivityData.create();
  bool ifSent = false;
  bool _loading = false;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final String _now = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final dataList = DataWrapper.dataNameList;

  bool get loading => _loading;

  set date(String date) {
    _date = date;
    ifSent = false;
    getActivityData();
  }

  String get date => _date;

  Future<http.Response> _sendFirstRequest() async {
    final dataNumber = int.parse(_date);

    late dynamic bodyJson;

    // get body json
    if (_date == _now) {
      try {
        var dw = DataWrapper();
        final data = await dw.getDataList(dataList, dataNumber);
        bodyJson = jsonDecode(dataListJsonEncode(data));
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.e("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.e("Internet connection Issue");
          FedToast.internetIssue();
        }
        rethrow;
      }
    } else {
      bodyJson = List.empty(growable: true);
    }
    bodyJson.add({"time": dataNumber});
    //send the first request
    late http.Response response;
    try {
      response = await HTTPApi.post(
              HTTPApi.fedAnalysis, <String, String>{}, jsonEncode(bodyJson))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      rethrow;
    }

    return response;
  }

  void _setAndNotify(dynamic jsonValue) {
    final jsonMap = jsonValue as Map<String, dynamic>;
    jsonMap.forEach((key, value) {
      activityData[key]['average'] = value['avg'];
      activityData[key]['rank'] = ("${value['ranking']}%");
    });
    activityData["query_time"] =
        DateTime.now().millisecondsSinceEpoch.toDouble();
    userApi.prefs.setString("activity$date", json.encode(activityData));
    _notify();
  }

  void _clearAll() {
    activityData.forEach((key, value) {
      if (key != "query_time") {
        activityData[key]['average'] = 0.0;
        activityData[key]['rank'] = 0.0;
      }
    });
  }

  Future<void> getActivityData({bool forcedRefresh = false}) async {
    forcedRefresh = Platform.isIOS ? true : forcedRefresh;
    _loading = true;
    notifyListeners();
    String? cachedData = userApi.prefs.getString("activity$date");
    if (!forcedRefresh && (cachedData != null)) {
      logger.d("cached activity data");
      activityData = json.decode(cachedData);
      if (DateTime.now().millisecondsSinceEpoch -
              (activityData["query_time"] ?? 0.0) <
          1800000) {
        _notify();
        return;
      }
    }
    _clearAll();
    // get data and send to the server
    final dataNumber = int.parse(_date);

    late dynamic bodyJson;

    late http.Response response;

    try {
      response = await _sendFirstRequest();
    } on PlatformException {
      _notify();
      return;
    } on TimeoutException {
      _notify();
      return;
    } on SocketException {
      dataWrapperToast("Please Connect To Internet");
      return;
    }

    if (response.statusCode == 200) {
      // if the date is now, then return
      if (_date == _now) {
        _setAndNotify(jsonDecode(response.body));
        return;
      }

      // check if there is data missing
      final responseJson = jsonDecode(response.body);
      List<String> dataMissing = List.empty(growable: true);
      for (final element in dataList) {
        if (responseJson[element] == null) {
          dataMissing.add(element);
        }
      }
      if (dataList.isEmpty) {
        _setAndNotify(jsonDecode(response.body));
        return;
      }

      // if there is data missing, send the second request
      if (ifSent) {
        _setAndNotify(jsonDecode(response.body));
        return;
      }
      try {
        var dw = DataWrapper();
        List<Data?> data = await dw.getDataList(dataMissing, dataNumber);
        bodyJson = jsonDecode(dataListJsonEncode(data));
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
        }
        _notify();
        return;
      }

      List<http.Response> responseArr = await Future.wait([
        HTTPApi.post(HTTPApi.data, <String, String>{}, jsonEncode(bodyJson)),
        // TODO: Data DP Algorithm!!!
        // HTTPApi.post(HTTPApi.dataDP, <String, String>{}, jsonEncode(bodyJson))
      ]);

      logger.i(
          "Data Status Code ${responseArr[0].statusCode} : ${jsonEncode(bodyJson)}");

      if (responseArr[0].statusCode == 200) {
        ifSent = true;
        getActivityData();
      } else {
        logger.d("error");
        _notify();
      }
    } else {
      logger.e(response.statusCode);
      if (response.statusCode == 401) {
        // not authenticated, pop an authenticate reminder signing
        dataWrapperToast("Please Login for federated analysis.");
      }
      _notify();
    }
  }

  void _notify() {
    _loading = false;
    bus.emit("activity_loading_done");
    notifyListeners();
  }
}
