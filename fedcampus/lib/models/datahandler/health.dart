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
        logger.e(e);
      }
    }
    return dataMap;
  }

  Future<Map<String, double>> getCachedBodyDataLegacy(
      DateTime dateTime, List<String> dataList,
      {bool forcedRefresh = false}) async {
    // deprecated, old implementation which uses [SharedPreferences]
    Map<String, double> healthData;
    String? cachedData = userApi.prefs.getString("health$dateTime");
    if (cachedData != null) {
      healthData = Map.castFrom<String, dynamic, String, double>(
          json.decode(cachedData));
      logger.e(healthData["query_time"]);
      if (DateTime.now().millisecondsSinceEpoch -
              (healthData["query_time"] ?? 0.0) >
          1800000) {
        healthData = await getDataMap(
            entry: dataList,
            startTime: dateTime,
            endTime: dateTime.add(const Duration(days: 1)));
      }
    } else {
      healthData = await getDataMap(
          entry: dataList,
          startTime: dateTime,
          endTime: dateTime.add(const Duration(days: 1)));
    }
    return healthData;
  }

  Future<Map<String, double>> getCachedBodyData(
      DateTime dateTime, List<String> dataList,
      {bool forcedRefresh = false}) async {
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
        if (result.isEmpty) {
          dirtyDataList.add(i);
        } else if ((DateTime.now().millisecondsSinceEpoch -
                (result[0]["time_modified"] as int)) <
            1800000) {
          healthData.addAll({i: result[0]["value"] as double});
        } else {
          logger.e(i);
          dirtyDataList.add(i);
        }
      }
    }

    Map<String, double> additionalHealthData = await getDataMap(
        entry: dirtyDataList,
        startTime: dateTime,
        endTime: dateTime.add(const Duration(days: 1)));

    // write newly queried data into DB
    for (final e in additionalHealthData.entries) {
      healthDatabase.insert(
        HealthDBData(
          name: e.key,
          value: e.value,
          time: calendar.dateTimeToInt(dateTime),
          timeModified: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    healthData.addAll(additionalHealthData);

    return healthData;
  }
}
