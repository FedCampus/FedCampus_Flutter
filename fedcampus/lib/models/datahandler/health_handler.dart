import 'package:fedcampus/pigeon/generated.g.dart';
import '../../utility/global.dart';
import '../../utility/health_database.dart';
import '../../utility/log.dart';
import '../../utility/calendar.dart' as calendar;

/// The abstract class provided serves as a health data controller that facilitates the integration of health data from different platforms, including Huawei Health and Google Fit.
/// It provides a set of methods that enable the retrieval of data within a specific time interval or for a particular day.
/// Additionally, it supports obtaining a list of data by specifying the desired types.
///
/// The implementations of this abstract class primarily utilize lists as the underlying data structure.
/// Map implementations are derived from these lists, allowing for efficient data retrieval and manipulation.
/// The design and structure of this abstract class were influenced by Flutter [Health](https://pub.dev/packages/health)
class FedHealthData {
  /// `false` by default.
  bool get canAuth => false;

  /// `false` by default.
  bool get canCancelAuth => false;

  Future<void> authenticate() async {
    // throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<void> cancelAuthentication() async {
    // throws [Exception] when failed
    throw UnimplementedError();
  }

  /// Retrieves data for the given [entry] between the [startTime] and [endTime].
  Future<Data> getDataInterval({
    required String entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    throw UnimplementedError();
  }

  /// Gets data of type [entry] on [date].
  Future<Data> getDataDay({
    required String entry,
    required DateTime date,
  }) async {
    DateTime nextDay = date.add(const Duration(days: 1));
    Data data =
        await getDataInterval(entry: entry, startTime: date, endTime: nextDay);
    return data;
  }

  /// Retrieves data for each type in [entry] within the time range defined by [startTime] and [endTime].
  /// Returns a list of [Data] objects representing the retrieved data.
  ///
  /// Throws an [Exception] if any individual data retrieval fails, even if some succeed.
  Future<List<Data>> getDataListInterval({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    List<Data> dataList = [];
    for (String element in entry) {
      Data data = await getDataInterval(
          entry: element, startTime: startTime, endTime: endTime);
      dataList.add(data);
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

  /// Retrieves data from the database. If the time is today, it allows only 30 minutes cache,
  /// otherwise, it always uses cached data unless [forcedRefresh] is enabled.
  ///
  /// When some entries encounter errors, this method throws an [Exception] even if some succeed.
  ///
  /// Subclasses should throw an [AuthenticationException] if not authenticated,
  /// which will cause [HealthDataModel] to call `authenticate()`.
  ///
  /// Subclass implementation:
  ///   1. Huawei: good
  ///   2. Google: not perfect because Flutter Health only throws exceptions when the data is not available on the platform,
  ///      but when the data is not requested by [requestAuthorization], Flutter Health does not throw exceptions.
  ///      Specifically, native code prints the error, but the method channel does not throw a [PlatformException] in ways like `callback(Result.failure(err))`,
  ///      and what we can see is just logging info in the console.
  ///      Therefore, GoogleFit has to call `authenticate()` upon instantiation.
  ///      Luckily, unlike Huawei, this process does not redirect to another page, which is acceptable.
  ///   3. iOS: good
  Future<List<Data>> getCachedDataListDay(List<String> nameList, int time,
      {bool forcedRefresh = false}) async {
    DateTime dateTime = calendar.intToDateTime(time);
    logger.e(time);
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
        if (re.isEmpty ||
            (re[0]["value"] == -1) ||
            (_isDirtyData(dateTime, re[0]))) {
          dirtyDataList.add(i);
        } else {
          healthData.add(Data(
            name: i,
            value: re[0]["value"] as double,
            startTime: time,
            endTime: calendar.dateTimeToInt(
                calendar.intToDateTime(time).add(const Duration(days: 1))),
          ));
        }
      }
    }

    List<Data> dirtyHealthData = await userApi.healthDataHandler
        .getDataListInterval(
            entry: dirtyDataList,
            startTime: DateTime(dateTime.year, dateTime.month, dateTime.day),
            endTime: userApi.isAndroid
                ? DateTime(dateTime.year, dateTime.month, dateTime.day)
                : DateTime(dateTime.year, dateTime.month, dateTime.day + 1));

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

  /// Whether [Data] in database is considered dirty
  /// Data is dirty only if the query date is the current day and if the data has been present in the database for at least 30 minutes.
  bool _isDirtyData(DateTime queryDay, Map<String, Object?> queryData) {
    return (queryDay.day == DateTime.now().day) &&
        ((DateTime.now().millisecondsSinceEpoch -
                (queryData["time_modified"] as int)) >
            1800000);
  }

  /// When some entries encounter errors, this method throws an [Exception] even if some succeed.
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
