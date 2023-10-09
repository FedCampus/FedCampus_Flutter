import 'dart:convert';

import 'package:fedcampus/pigeon/generated.g.dart';
import '../../utility/global.dart';
import '../../utility/health_database.dart';
import '../../utility/log.dart';
import '../../utility/calendar.dart' as calendar;

class FedHealthData {
  /// abstract class for health data controller on variery of platforms such as Huawei Health, Google Fit
  Future<void> authenticate() async {
    /// throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<void> cancelAuthentication() async {
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
    DateTime nextDay = date.add(const Duration(days: 1));
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
        // -1 is a flag that is used to indicate no data/invalid data
        dataMap.addAll({element: -1});
        logger.e(e);
      }
    }
    return dataMap;
  }

  Future<Map<String, double>> getCachedBodyDataDay(
      DateTime dateTime, List<String> dataList,
      {bool forcedRefresh = false}) async {
    // according to https://github.com/tekartik/sqflite/blob/master/sqflite/doc/usage_recommendations.md#single-database-connection,
    // it is safe to call [openDatabase] every time you need, since the option [singleInstance] ensures single database connection
    HealthDatabase healthDatabase = await HealthDatabase.create();

    Map<String, double> healthData = {};
    List<String> dirtyDataList = [];

    if (forcedRefresh) {
      dirtyDataList = dataList;
    } else {
      // logger.d(await healthDatabase.getDataList());
      // try to get data from DB, if < 30 min
      for (var i in dataList) {
        List<Map<String, Object?>> result =
            await healthDatabase.getData(calendar.dateTimeToInt(dateTime), i);
        logger.e(result);
        if (result.isEmpty) {
          dirtyDataList.add(i);
        } else if ((dateTime.day != DateTime.now().day) ||
            (((DateTime.now().millisecondsSinceEpoch -
                    (result[0]["time_modified"] as int)) <
                1800000))) {
          healthData.addAll({i: result[0]["value"] as double});
        } else {
          logger.e(i);
          dirtyDataList.add(i);
        }
      }
    }
    logger.e(dirtyDataList);

    Map<String, double> dirtyHealthData = await getDataMap(
        entry: dirtyDataList,
        startTime: dateTime,
        endTime: dateTime.add(const Duration(days: 1)));

    // write newly queried data into DB
    for (final e in dirtyHealthData.entries) {
      healthDatabase.insert(
        HealthDBData(
          name: e.key,
          value: e.value,
          time: calendar.dateTimeToInt(dateTime),
          timeModified: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    healthData.addAll(dirtyHealthData);

    return healthData;
  }
}
