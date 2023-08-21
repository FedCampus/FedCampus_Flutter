import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:path_provider/path_provider.dart';
import 'package:sample_statistics/sample_statistics.dart';
import 'package:sqflite/sqflite.dart';

class DataWrapper {
  final dataNameList = [
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

  ///Get all the data given the list of tag on the specific datetime number.
  ///Throw an exception if data fetching get some error.
  ///50005 if the user is not authenticated, 50030 if the internet connection is down.
  ///If there is no data for that specifc date, the only data will be {step_time: value: 0}
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

  ///get all the data from Huawei from the time period.
  ///50005 if the user is not authenticated, 50030 if the internet connection is down.
  Future<List<Data?>> _getDataListTimePeriod(
      List<String> nameList, List<int> time) async {
    List<Future<List<Data?>>> getDataTimePeriod = List.empty(growable: true);
    for (var i in time) {
      getDataTimePeriod.add(getDataList(dataNameList, i));
    }
    final temp = await Future.wait(getDataTimePeriod);
    final res = temp.expand((element) => element).toList();
    return res;
  }

  ///call getDataList, wrap that into a map.
  ///50005 if the user is not authenticated, 50030 if the internet connection is down.
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

  ///Get Data Channel.
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

  /// fuzz the data with DP algorithm
  List<Data> fuzzData(List<Data?>? data) {
    List<double> error = truncatedNormalSample(data!.length, -10, 10, 0, 1);
    List<Data> res = List.empty(growable: true);
    for (var i = 0; i < data.length; i++) {
      res.add(Data(
          name: data[i]!.name,
          value: data[i]!.value + error[i] * 10,
          startTime: data[i]!.startTime,
          endTime: data[i]!.startTime));
    }
    return res;
  }

  /// **date** is the training end date, usually is the yeasterday date
  /// This function will save the data to database and start Tranining
  /// TODO: Modify this function
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
    logger.i("start Training");
    try {
      await training.prepare(host, backendUrl, result, deviceId: id);
    } on Exception catch (error) {
      logger.e(error);
    }
    training
        .start((info) => logger.d('_saveToDataBaseAndStartTraining: $info'));
  }

  /// start Training given the databaseapi, database, and date
  void _startTraining(DataBaseApi dbapi, Database database, int date) async {
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
    logger.i("start Training");
    try {
      await training.prepare(host, backendUrl, result, deviceId: id);
    } on Exception catch (error) {
      logger.e(error);
    }
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

  // TODO: input function when the app starts, date is set to be yeasterday
  void getDataAndTrain(int date) async {
    final dbapi = DataBaseApi();
    final database = await dbapi.getDataBase();
    // final res = await Future.wait(getListData);
    final res = await dbapi.getDataList(database, date);

    final dayMissing = _findMissingData(res, date, dbapi);

    final newData = await _getDataListTimePeriod(dataNameList, dayMissing);

    await dbapi.saveToDB(newData, database);

    //Training
    final dataList = await dbapi.getDataList(database, date);
    final loadDataApi = LoadDataApi();
    Map<List<List<double>>, List<double>> result = _wrap2DArrayInput(
        await loadDataApi.loaddata(dataList, dbapi.startTime, date));
    // logger.i(result);
    final id = await deviceId();
    const host = '10.201.8.66'; // TODO: Remove hardcode.
    const backendUrl = 'http://$host:8000';
    //iteration loop
    while (true) {
      final training = FedmcrnnTraining();
      final completer = Completer();
      try {
        await training.prepare(host, backendUrl, result, deviceId: id);
      } on Exception catch (error) {
        logger.e(error);
      }
      training.train.start().listen(
          (info) => logger.d('_saveToDataBaseAndStartTraining: $info'),
          onDone: () => completer.complete());
      await completer.future;
      await Future.delayed(tenSeconds);
      // TODO: send log file to server here
      sendLogFileToServer();
    }
  }

  Future<void> sendLogFileToServer() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/log";
    File file = File(path);
    //TODO: send log file to server
  }

  List<int> _findMissingData(List<Data> res, int date, DataBaseApi dbapi) {
    var i = dbapi.startTime;
    const duration = Duration(days: 1);
    List<int> resMissing = List.empty(growable: true);
    while (i < date) {
      if (res.where((element) => element.endTime == i).isEmpty) {
        resMissing.add(i);
      }
      final temp = (DateTime.parse(i.toString()).add(duration));
      i = temp.year * 10000 + temp.month * 100 + temp.day;
    }
    return resMissing;
  }

  /// TODO: change the function
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
      data = await getDataList(dataNameList, date);
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
    final dataFuzz = fuzzData(data);

    final dataJson = dataListJsonEncode(data);
    final dataFuzzJson = dataListJsonEncode(dataFuzz);

    try {
      List<http.Response> responseArr = await Future.wait([
        HTTPClient.post(HTTPClient.data, <String, String>{}, dataJson),
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

const tenSeconds = Duration(seconds: 10);
