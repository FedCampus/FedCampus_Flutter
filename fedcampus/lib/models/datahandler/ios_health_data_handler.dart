import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:health/health.dart';
import '../../utility/calendar.dart' as calendar;

class IOSDayData {
  int date = 0;

  Map<String, double> value = {
    "step": 0.0,
    "distance": 0.0,
    "rest_heart_rate": 0.0,
    "heart_rate": 0.0,
    "calorie": 0.0,
  };
}

class IOSHealth extends FedHealthData {
  final _dataEntry = {
    "step": HealthDataType.STEPS,
    "distance": HealthDataType.DISTANCE_WALKING_RUNNING,
    "calorie": HealthDataType.ACTIVE_ENERGY_BURNED,
    "rest_heart_rate": HealthDataType.RESTING_HEART_RATE,
    "height": HealthDataType.HEIGHT,
    "sleep_time": HealthDataType.SLEEP_ASLEEP,
    "sleep_duration": HealthDataType.SLEEP_ASLEEP,
    "weight": HealthDataType.WEIGHT,
    "avg_heart_rate": HealthDataType.HEART_RATE,
    "carbon_emission": HealthDataType.DISTANCE_WALKING_RUNNING
  };

  final HealthFactory _health =
      HealthFactory(useHealthConnectIfAvailable: false);

  late final List<HealthDataType> _types;

  IOSHealth() {
    logger.d("Using IOS Health.");
    _types = _dataEntry.values.toList();
  }

  @override
  bool get canAuth => true;

  @override
  Future<void> authenticate() async {
    bool requested =
        await _health.requestAuthorization(_dataEntry.values.toList());
    logger.d("Authentication requested: $requested");

    return;
  }

  double _sleepDurationToDouble(DateTime start, DateTime end) {
    var time =
        (start.hour * 1e2 + start.minute) * 1e4 + end.hour * 1e2 + end.minute;
    return time;
  }

  @override
  Future<Data> getDataInterval(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    if (entry == "sleep_time" || entry == "sleep_duration") {
      endTime = endTime.add(const Duration(hours: 10));
    }
    await authenticate();
    var res = await _health
        .getHealthDataFromTypes(startTime, endTime, [_dataEntry[entry]!]);
    var health = res
        .map((e) => e.sourceName)
        .toSet()
        .map((e) =>
            _getSum(entry, res.where((element) => element.sourceName == e)))
        .toList();
    double sum = health.isEmpty
        ? 0.0
        : health.reduce((curr, next) => curr > next ? curr : next);

    return Data(
        name: entry,
        value: sum,
        startTime: calendar.dateTimeToInt(startTime),
        endTime: calendar.dateTimeToInt(endTime));
  }

  double _getSum(String entry, Iterable<HealthDataPoint> health) {
    double sum = 0;
    if (entry == "sleep_duration" && health.isNotEmpty) {
      var sortList = health.toList();
      sortList.sort((a, b) => double.parse(a.value.toString())
          .compareTo(double.parse(b.value.toString())));
      sum =
          _sleepDurationToDouble(sortList.last.dateFrom, sortList.last.dateTo);
    } else {
      if (health.isEmpty) {
        sum = -1;
      } else {
        sum = health.fold(0,
            (value, element) => value + double.parse(element.value.toString()));
        sum = (entry == "rest_heart_rate" || entry == "avg_heart_rate")
            ? sum / health.length
            : sum;
        sum = (entry == "carbon_emission") ? sum / 1000 * 42 : sum;
        sum = (sum.isNaN) ? 0 : sum;
      }
    }
    return sum;
  }

  /// get the IOS Day Data from the previous 10 days
  /// TODO: Hard coded the 10 days
  Future<List<IOSDayData?>> getIOSDayDataList() async {
    List<IOSDayData> res = List.empty(growable: true);
    DateTime now = DateTime.now();
    DateTime start =
        DateTime(now.year, now.month, now.day).add(const Duration(days: -10));
    await authenticate();
    var huaweiRes = (await _health.getHealthDataFromTypes(start, now, _types))
        .where((element) => element.sourceId == "com.huawei.iossporthealth");
    for (DateTime i = DateTime(start.year, start.month, start.day);
        i.compareTo(now) < 0;
        i = i.add(const Duration(days: 1))) {
      final dayData = huaweiRes.where((element) =>
          DateTime(element.dateFrom.year, element.dateFrom.month,
                  element.dateFrom.day)
              .compareTo(i) ==
          0);
      IOSDayData iosDayData = IOSDayData();
      iosDayData.date = calendar.dateTimeToInt(i);
      for (var key in iosDayData.value.keys) {
        final res = dayData.where((element) => element.type == _dataEntry[key]);
        double value = (res).fold(
            0.0,
            (previousValue, element) =>
                previousValue + double.parse(element.value.toString()));
        iosDayData.value[key] =
            (key == "rest_heart_rate" || key == "heart_rate")
                ? (value / res.length).isNaN
                    ? 0.0
                    : value / res.length
                : value;
      }
      iosDayData.value['rest_heart_rate'] != 0.0 &&
              iosDayData.value['heart_rate'] != 0.0
          ? res.add(iosDayData)
          : null;
    }
    return res;
  }

  /// Get the start time and end time
}
