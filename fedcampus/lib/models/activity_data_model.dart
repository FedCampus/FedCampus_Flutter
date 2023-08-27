import 'dart:async';
import 'dart:convert';

import 'package:fedcampus/models/activity_data.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/models/user_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ActivityDataModel extends ChangeNotifier {
  Map<String, dynamic> activityData = ActivityData.create();
  bool isAuth = false;
  bool ifSent = false;
  bool _loading = true;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final String _now = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final dataList = [
    "step_time",
    "distance",
    "calorie",
    "intensity",
    "stress",
    "step",
    "sleep_efficiency",
  ];

  bool get isAuthenticated => isAuth;

  bool get loading => _loading;

  set isAuthenticated(bool auth) {
    isAuth = auth;
    userApi.prefs.setBool("login", auth);
    notifyListeners();
  }

  set date(String date) {
    _date = date;
    // _getActivityData();
    // getActivityDataTest();
    getActivityData();
  }

  String get date => _date;

  Future<void> getActivityDataTest() async {
    _loading = false;
    for (final dataEntryName in dataList) {
      activityData[dataEntryName]["average"] = 15110.045;
      activityData[dataEntryName]["rank"] = '100%';
    }
    notifyListeners();
  }

  Future<http.Response> _sendFirstRequest() async {
    final dataNumber = int.parse(_date);

    late dynamic bodyJson;

    // get body json
    if (_date == _now) {
      try {
        var dw = DataWrapper();
        final data = await dw.getDataList(dataList, dataNumber);
        bodyJson = jsonDecode(dataListJsonEncode(data));
        // HTTPClient.post(HTTPClient.fedAnalysis, <String,String>{}, body)
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
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
      response = await HTTPClient.post(
              HTTPClient.fedAnalysis, <String, String>{}, jsonEncode(bodyJson))
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
    _loading = false;
    notifyListeners();
  }

  void _clearAll() {
    for (final s in dataList) {
      activityData[s]["average"] = 0;
      activityData[s]["rank"] = "0";
    }
  }

  Future<void> getActivityData() async {
    _loading = true;
    notifyListeners();

    _clearAll();
    // get data and send to the server
    final dataNumber = int.parse(_date);

    late dynamic bodyJson;

    late http.Response response;

    try {
      response = await _sendFirstRequest();
    } on PlatformException catch (error) {
      logger.e(error);
      _loading = false;
      notifyListeners();
      return;
    } on TimeoutException {
      _loading = false;
      notifyListeners();
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
        final data = await dw.getDataList(dataMissing, dataNumber);
        bodyJson = jsonDecode(jsonEncode(data));
        // HTTPClient.post(HTTPClient.fedAnalysis, <String,String>{}, body)
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
        }
        _loading = false;
        notifyListeners();
        return;
      }

      List<http.Response> responseArr = await Future.wait([
        HTTPClient.post(
            HTTPClient.data, <String, String>{}, jsonEncode(bodyJson)),
        // TODO: Data DP Algorithm!!!
        HTTPClient.post(
            HTTPClient.dataDP, <String, String>{}, jsonEncode(bodyJson))
      ]);

      logger.i(
          "Data Status Code ${responseArr[0].statusCode} : ${jsonEncode(bodyJson)}");
      logger.i(
          "Data DP Status Code ${responseArr[1].statusCode} : ${jsonEncode(bodyJson)}");

      if (responseArr[0].statusCode == 200) {
        ifSent = true;
        getActivityData();
      } else {
        logger.d("error");
      }
    }
  }
}
