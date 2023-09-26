import '../../pigeon/generated.g.dart';
import '../../utility/calendar.dart' as calendar;
import '../../utility/log.dart';

class ScreenTimeData {
  final host = AppUsageStats();

  Future<Data> getData({
    required String entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    Data? data;

    data = (await host.getData("calorie", calendar.dateTimeToInt(startTime),
        calendar.dateTimeToInt(endTime)))[0]!;
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
      } on StateError {
        // do nothing
      } catch (e) {
        logger.e(e);
      }
    }
    return dataList;
  }

  Future<Map<String, double>> getDataMap({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    Map<String, double> dataMap = {};
    for (String element in entry) {
      Data data;
      try {
        data = await getData(
            entry: element, startTime: startTime, endTime: endTime);
        dataMap.addAll({data.name: data.value});
      } catch (e) {
        logger.e(e);
      }
    }
    return dataMap;
  }
}
