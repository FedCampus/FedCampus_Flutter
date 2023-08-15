import 'dart:async';
import 'dart:convert';

import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/train/fedmcrnn_training.dart';
import 'package:fedcampus/utility/database.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/pigeon/data_extensions.dart';
import 'package:http/http.dart';
import 'package:sample_statistics/sample_statistics.dart';

class DataWrapper {
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

  Future<List<Data?>> getDataList(List<String> nameList, int time) async {
    List<Future<Data?>> list = List.empty(growable: true);
    final host = DataApi();
    for (final element in nameList) {
      list.add(_getData(host, element, time));
    }
    try {
      final data = await Future.wait(list);
      data.removeWhere((element) => element == null);
      return data;
    } on PlatformException {
      rethrow;
    }
  }

  Future<Map<String, double>> getDataListToMap(
      List<String> nameList, int time) async {
    try {
      List<Data?>? data = await getDataList(nameList, time);
      Map<String, double> res = {};
      // turn the data to a map
      for (var d in data) {
        res.addAll({d!.name: d.value});
      }
      return res;
    } on PlatformException {
      rethrow;
    }
  }

  Future<Data?> _getData(DataApi host, String name, int time) async {
    try {
      List<Data?> dataListOne = await host.getData(name, time, time);
      if (dataListOne.isEmpty) {
        return null;
      } else {
        return dataListOne[0]!;
      }
    } on Exception {
      rethrow;
    }
  }

  Future<Data?> getData(String name, int time) async {
    final host = DataApi();
    List<Data?> dataListOne = await host.getData(name, time, time);
    logger.i(dataListOne[0]!.value);
    if (dataListOne.isEmpty) {
      return null;
    } else {
      return dataListOne[0]!;
    }
  }

  void fuzzData(List<Data?>? data) {
    List<double> error = truncatedNormalSample(data!.length, -10, 10, 0, 1);
    for (var i = 0; i < data.length; i++) {
      data[i] = Data(
          name: data[i]!.name,
          value: data[i]!.value + error[i] * 10,
          startTime: data[i]!.startTime,
          endTime: data[i]!.startTime);
    }
  }

  void _saveToDataBaseAndStartTraining(List<Data?> data, int date) async {
    final dbapi = DataBaseApi();
    final database = await dbapi.getDataBase();
    await dbapi.saveToDB(data, database);

    //start Training

    //1. load data
    final dataList = await dbapi.getDataList(database, date);
    logger.i(dataListJsonEncode(dataList));

    //2. Perform data windowing and start Training.
    final loadDataApi = LoadDataApi();
    Map<List<List<double>>, List<double>> result = _wrap2DArrayInput(
        await loadDataApi.loaddata(dataList, dbapi.startTime, date));
    logger.i(result);
    final id = await deviceId();
    final training = FedmcrnnTraining();
    const host = '10.200.102.167'; // TODO: Remove hardcode.
    const backendUrl = 'http://$host:8000';
    await training.prepare(host, backendUrl, result, deviceId: id);
    training
        .start((info) => logger.d('_saveToDataBaseAndStartTraining: $info'));
  }

  Map<List<List<double>>, List<double>> _wrap2DArrayInput(
      Map<Object?, Object?> result) {
    Map<List<List<double>>, List<double>> xTrue = {};
    for (var entry in result.entries) {
      final value = entry.value as List<Object?>;
      final key = entry.key as List<Object?>;
      List<List<double>> twoDarrayTrue = List.empty(growable: true);
      for (var onedarray in key) {
        var x1 = (onedarray as List<Object?>);
        List<double> onedarrayList = List.empty(growable: true);
        for (final i in x1) {
          onedarrayList.add(i as double);
        }
        twoDarrayTrue.add(onedarrayList);
      }
      xTrue[twoDarrayTrue] = [value[0]! as double];
    }
    return xTrue;
  }

  void getDayDataAndSendAndTrain(int date) async {
    // get the data from the last day
    final now = DateTime.now();
    final dateNumber = now.year * 10000 + now.month * 100 + now.day;
    final yeasterday = now.add(const Duration(days: -1));
    final yeasterdayDate =
        yeasterday.year * 10000 + yeasterday.month * 100 + yeasterday.day;
    if (dateNumber == date) {
      //get the last day
      date = yeasterdayDate;
    }

    late final List<Data?>? data;
    try {
      data = await getDataList(dataList, date);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");
        // authAndGetData();
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
    List<Data> dataFuzz = List<Data>.from(data);

    _saveToDataBaseAndStartTraining(data, yeasterdayDate);

    fuzzData(dataFuzz);

    final dataJson = dataListJsonEncode(data);
    final dataFuzzJson = dataListJsonEncode(dataFuzz);

    try {
      List<http.Response> responseArr = await Future.wait([
        HTTPClient.post(HTTPClient.data, <String, String>{}, dataJson),
        // TODO: Data DP Algorithm!!!
        HTTPClient.post(HTTPClient.dataDP, <String, String>{}, dataFuzzJson)
      ]).timeout(const Duration(seconds: 5));
      // TODO: Time out for 5 seconds.

      logger.i("Data Status Code ${responseArr[0].statusCode} : $dataJson");
      logger.i(
          "Data DP Status Code ${responseArr[1].statusCode} : $dataFuzzJson");
      if (responseArr[0].statusCode == 401) {
        // user login
        dataWrapperToast("Please Login for federated analysis.");
      }
    } on ClientException {
      remindDkuNetwork();
    } on TimeoutException {
      logger.d("internet issue");
      remindDkuNetwork();
      return;
    } catch (err, stackTrace) {
      logger.e("$err\n$stackTrace");
      dataWrapperToast("Unknown issue: $err. Please try again later.");
    }
  }

  void test() async {
    final host = DataApi();
    final x = await host.getData("step", 20230809, 20230809);
    logger.i(x[0]!.value);
  }
}

void remindDkuNetwork() =>
    dataWrapperToast("Please make sure you are connected to DKU network!");

void dataWrapperToast(String msg) => Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0);

/// Manually calls `.toJson` on `Data` since the dynamic call from `jsonEncode`
/// could not find extension methods.
String dataListJsonEncode(List<Data?> data) =>
    jsonEncode(data.map((e) => e!.toJson()).toList());
