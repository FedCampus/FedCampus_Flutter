import 'package:fedcampus/pigeon/generated.g.dart';
import '../../utility/global.dart';
import '../../utility/health_database.dart';
import '../../utility/log.dart';
import '../../utility/calendar.dart' as calendar;

/// Abstract class for health data controller on variery of platforms such as Huawei Health, Google Fit.
/// The interface provides methods to get [Data] from an interval or a day; it also supports get a list of [Data] from a list of types.
/// The implementations are [List] centered, and [Map] implementations are based on [List], which is inspired from Flutter [Health](https://pub.dev/packages/health)
class FedHealthData {
  Future<void> authenticate() async {
    // throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<void> cancelAuthentication() async {
    // throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<Data> getDataInterval({
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
    Data data =
        await getDataInterval(entry: entry, startTime: date, endTime: nextDay);
    return data;
  }

  /// ~~when some entries went wrong, this method return other fine entries~~
  /// when some entries went wrong, this method throws [Exception] even if some succeeds
  Future<List<Data>> getDataListInterval({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    List<Data> dataList = [];
    for (String element in entry) {
      Data data;
      try {
        data = await getDataInterval(
            entry: element, startTime: startTime, endTime: endTime);
        dataList.add(data);
      } catch (e) {
        logger.e(e);
        rethrow;
      }
    }
    return dataList;
  }

  Future<Map<String, double>> getValueMapInterval({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    throw UnimplementedError();
  }

  /// first try to retrieve from database. If time is today, only allow 30 min cache, otherwise always use cached data unless forced refresh
  /// ~~when some entries went wrong, this method return other fine entries~~
  /// when some entries went wrong, this method throws [Exception] even if some succeeds
  Future<List<Data>> getCachedDataListDay(List<String> nameList, int time,
      {bool forcedRefresh = false}) async {
    DateTime dateTime = calendar.intToDateTime(time);
    // according to https://github.com/tekartik/sqflite/blob/master/sqflite/doc/usage_recommendations.md#single-database-connection,
    // it is safe to call [openDatabase] every time you need, since the option [singleInstance] ensures single database connection
    HealthDatabase healthDatabase = await HealthDatabase.create();
    List<Data> healthData = [];
    List<String> dirtyDataList = [];
    if (forcedRefresh) {
      dirtyDataList = nameList;
    } else {
      for (var i in nameList) {
        List<Map<String, Object?>> re =
            await healthDatabase.getData(calendar.dateTimeToInt(dateTime), i);
        if (re.isEmpty) {
          dirtyDataList.add(i);
        } else if ((dateTime.day != DateTime.now().day) || _isDirtyData(re)) {
          healthData.add(Data(
            name: i,
            value: re[0]["value"] as double,
            startTime: time,
            endTime: calendar.dateTimeToInt(
                calendar.intToDateTime(time).add(const Duration(days: 1))),
          ));
        } else {
          dirtyDataList.add(i);
        }
      }
    }

    List<Data> dirtyHealthData = await userApi.healthDataHandler
        .getDataListInterval(
            entry: dirtyDataList,
            startTime: DateTime(dateTime.year, dateTime.month, dateTime.day),
            endTime: DateTime(dateTime.year, dateTime.month, dateTime.day + 1));

    // write newly queried data into DB
    for (final e in dirtyHealthData) {
      healthDatabase.insert(
        HealthDBData(
          name: e.name,
          value: e.value,
          time: calendar.dateTimeToInt(dateTime),
          timeModified: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    healthData.addAll(dirtyHealthData);

    return healthData;
  }

  bool _isDirtyData(List<Map<String, Object?>> re) {
    return (((DateTime.now().millisecondsSinceEpoch -
            (re[0]["time_modified"] as int)) <
        1800000));
  }

  /// ~~when some entries went wrong, this method return other fine entries~~
  /// when some entries went wrong, this method throws [Exception] even if some succeeds
  Future<Map<String, double>> getCachedValueMapDay(
      DateTime dateTime, List<String> dataList,
      {bool forcedRefresh = false}) async {
    Map<String, double> healthData = {};

    List<Data> result = await getCachedDataListDay(
      dataList,
      calendar.dateTimeToInt(dateTime),
      forcedRefresh: forcedRefresh,
    );
    for (var d in result) {
      if (d.success) healthData.addAll({d.name: d.value});
    }

    return healthData;
  }
}
