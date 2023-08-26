class DataNew {
  /// the reason for using date as [DateTime] externally, and use [int] as data representation when
  /// encoded as [List] is for both the ease of handling this custom data type while keep the compability for codec
  DataNew({
    required this.name,
    required this.value,
    required this.startTime,
    required this.endTime,
  });

  String name;

  double value;

  DateTime startTime;

  DateTime endTime;

  Object encode() {
    return <Object?>[
      name,
      value,
      dateTimeToInt(startTime),
      dateTimeToInt(endTime),
    ];
  }

  static DataNew decode(Object result) {
    result as List<Object?>;
    return DataNew(
      name: result[0]! as String,
      value: result[1]! as double,
      startTime: intToDateTime(result[2]! as int),
      endTime: intToDateTime(result[3]! as int),
    );
  }

  static int dateTimeToInt(DateTime dateTime) {
    return dateTime.year * 10000 + dateTime.month * 100 + dateTime.day;
  }

  static intToDateTime(int dateCode) {
    return DateTime(
        dateCode ~/ 10000, (dateCode % 10000) ~/ 100, dateCode % 100);
  }
}

class FedHealthData {
  /// abstract class for health data controller on variery of platforms such as Huawei Health, Google Fit
  Future<void> authenticate() async {
    /// throws [Exception] when failed
    throw UnimplementedError();
  }

  Future<DataNew> getData({
    required String entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    throw UnimplementedError();
  }

  Future<DataNew> getDataDay({
    required String entry,
    required DateTime date,
  }) async {
    DateTime nextDay = DateTime(date.year, date.month, date.day + 1);
    DataNew data =
        await getData(entry: entry, startTime: date, endTime: nextDay);
    return data;
  }

  Future<Map<String, double?>> getDataMap({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    throw UnimplementedError();
  }
}
