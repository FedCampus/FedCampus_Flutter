import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/pigeon/data_extensions.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:health/health.dart';

class IOSHealth extends FedHealthData {
  final _dataEntry = {
    "step": HealthDataType.STEPS,
    "distance": HealthDataType.DISTANCE_WALKING_RUNNING,
    "calorie": HealthDataType.ACTIVE_ENERGY_BURNED,
    "rest_heart_rate": HealthDataType.RESTING_HEART_RATE,
    "height": HealthDataType.HEIGHT,
    "sleep_time": HealthDataType.SLEEP_IN_BED,
    "weight": HealthDataType.WEIGHT,
    "heart_rate": HealthDataType.HEART_RATE,
  };

  final HealthFactory _health =
      HealthFactory(useHealthConnectIfAvailable: false);

  late final List<HealthDataType> _types;

  IOSHealth() {
    _types = _dataEntry.values.toList();
  }

  @override
  Future<void> authenticate() async {
    return;
  }

  @override
  Future<void> cancelAuthentication() async {
    return;
  }

  @override
  Future<Data> getData(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    var res = await _health
        .getHealthDataFromTypes(startTime, endTime, [_dataEntry[entry]!]);
    var appleHealth =
        res.where((element) => element.sourceId == "com.huawei.iossporthealth");
    double sum = appleHealth.fold(
        0, (value, element) => value + double.parse(element.value.toString()));
    sum = (entry == "rest_heart_rate" || entry == "heart_rate")
        ? sum / appleHealth.length
        : sum;
    return Data(
        name: entry,
        value: sum,
        startTime: DataExtension.dateTimeToInt(startTime),
        endTime: DataExtension.dateTimeToInt(endTime));
  }
}
