import 'package:flutter/services.dart';

import 'messages.g.dart';

class DataWrapper {
  static Future<List<Data?>?> getDataList(
      List<String> nameList, int time) async {
    List<Future<Data?>> list = List.empty(growable: true);
    final host = DataApi();
    nameList.forEach((element) {
      list.add(_getData(host, element, time));
    });
    try {
      final data = await Future.wait(list);
      data.removeWhere((element) => element == null);
      return data;
    } on PlatformException {
      rethrow;
    }
  }

  static Future<Map<String, double>> getDataListToMap(
      List<String> nameList, int time) async {
    try {
      List<Data?>? data = await getDataList(nameList, time);
      Map<String, double> res = {};
      // turn the data to a map
      for (var d in data!) {
        res.addAll({d!.name: d.value});
      }
      return res;
    } on PlatformException {
      rethrow;
    }
  }

  static Future<Data?> _getData(DataApi host, String name, int time) async {
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
    print(dataListOne[0]!.value);
    if (dataListOne.length == 0) {
      return null;
    } else {
      return dataListOne[0]!;
    }
  }

  void test() async {
    final host = DataApi();
    final x = await host.getData("step", 20230809, 20230809);
    print(x[0]!.value);
  }
}
