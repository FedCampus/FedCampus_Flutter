import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/pigeons/messages.g.dart';
import 'package:http/http.dart';

import '../signin.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  var _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  var _log = "";

  var isAuth = false;

  var isInternetIssue = false;

  final dataList = [
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

  final dataLength = 9;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    _getLastDayDataAndSend();
  }

  @override
  Widget build(BuildContext context) {
    // throw UnimplementedError();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Text("report page"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                initialValue: _date,
                onChanged: (value) => {_date = value},
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Date',
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Get Data'),
              onPressed: () {
                _getData();
              },
            ),
            Text(_log)
          ],
        )));
  }

  void _getLastDayDataAndSend() async {
    // get the data from the last day
    final now = DateTime.now();
    final yeasterday = now.add(const Duration(days: -1));
    final yeasterdayDate =
        yeasterday.year * 10000 + yeasterday.month * 100 + yeasterday.day;

    final host = DataApi();
    final date = yeasterdayDate;

    List<Future<Data?>> list = List.empty(growable: true);

    dataList.forEach((element) {
      list.add(getDataListWithNoLog(host, element, date));
    });

    final data = await Future.wait(list);
    data.removeWhere((element) => element == null);

    try {
      List<http.Response> responseArr = await Future.wait([
        HTTPClient.post(
            HTTPClient.data,
            <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            jsonEncode(data)),
        // TODO: Data DP Algorithm!!!
        HTTPClient.post(
            HTTPClient.dataDP,
            <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            jsonEncode(data))
      ]);

      logger.i(
          "Data Status Code ${responseArr[0].statusCode} : ${jsonEncode(data)}");
      logger.i(
          "Data DP Status Code ${responseArr[1].statusCode} : ${jsonEncode(data)}");
      if (responseArr[0].statusCode == 401) {
        // user login
        Fluttertoast.showToast(
            msg: "Please Login for federated analysis.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on ClientException catch (error) {
      Fluttertoast.showToast(
          msg: "Please make sure you are connected to DKU network!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _getData() async {
    final host = DataApi();

    int date = 0;
    try {
      date = int.parse(_date);
      setState(() {
        _log = "$_date \n";
      });

      for (var i = 0; i < dataList.length; i++) {
        getDataList(host, dataList[i], date);
      }
    } on Exception catch (e) {
      logger.e(e);
      return;
    }
  }

  void authAndGetData() async {
    if (isAuth) {
      return;
    }
    isAuth = true;
    HuaweiAuthApi host = HuaweiAuthApi();
    try {
      bool ifAuth = await host.getAuthenticate();
      isAuth = false;
      _getData();
    } on PlatformException catch (error) {
      logger.e(error);
    }
  }

  Future<Data?> getDataList(DataApi host, String name, int time) async {
    List<Data?> data;

    try {
      data = await host.getData(name, time, time);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");

        // redirect the user to the authenticate page
        authAndGetData();
      } else {
        logger.e(error.toString());
      }
      logger.e("catching error $error");
      return null;
    }

    setState(() {
      try {
        _log += "${data[0]!.name} ${data[0]!.value.toString()} \n";
      } on RangeError {
        _log += "$name 0\n";
      }
    });

    try {
      return data[0];
    } on RangeError {
      print("no data for $name");
      return null;
    }
  }

  Future<Data?> getDataListWithNoLog(
      DataApi host, String name, int time) async {
    List<Data?> data;

    try {
      data = await host.getData(name, time, time);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");

        // redirect the user to the authenticate page
        authAndGetData();
      } else if (error.message == "java.lang.SecurityException: 50030") {
        // network issue
        if (isInternetIssue) {
          return null;
        }
        isInternetIssue = true;
        Fluttertoast.showToast(
            msg: "Internet Connection Issue, please connect to Internet.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        logger.e(error.toString());
      }
      logger.e("catching error $error");
      return null;
    }
    try {
      return data[0];
    } on RangeError {
      print("no data for $name");
      return null;
    }
  }
}
