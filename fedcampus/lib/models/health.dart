import 'package:fedcampus/pigeon/generated.g.dart';

class FedHealthData {
  /// abstract class for health data controller on variery of platforms such as Huawei Health, Google Fit
  Future<void> authenticate() async {
    /// throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<Data> getData({
    required String entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    throw UnimplementedError();
  }

  Future<Data> getDataDay({
    required String entry,
    required DateTime date,
  }) async {
    DateTime nextDay = DateTime(date.year, date.month, date.day + 1);
    Data data = await getData(entry: entry, startTime: date, endTime: nextDay);
    return data;
  }

  Future<List<Data>> getDataList({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    List<Data> dataList = [];
    for (String element in entry) {
      Data data;
      try {
        data = await getData(
            entry: element, startTime: startTime, endTime: endTime);
        dataList.add(data);
      } catch (e) {
        // add nothing
      }
    }
    return dataList;
  }

  Future<Map<String, double?>> getDataMap({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    Map<String, double?> dataMap = {};
    for (String element in entry) {
      Data data;
      try {
        data = await getData(
            entry: element, startTime: startTime, endTime: endTime);
        dataMap.addAll({data.name: data.value});
      } catch (e) {
        dataMap.addAll({element: null});
      }
    }
    return dataMap;
  }
}
