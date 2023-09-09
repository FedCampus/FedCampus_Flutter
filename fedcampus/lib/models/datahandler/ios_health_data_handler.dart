import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/view/health.dart';
import 'package:health/health.dart';

class IOSHealth extends FedHealthData {
  final dataEntry = {
    "step": HealthDataType.STEPS,
    "distance": HealthDataType.DISTANCE_WALKING_RUNNING,
    "calorie": HealthDataType.ACTIVE_ENERGY_BURNED,
    "rest_heart_rate": HealthDataType.RESTING_HEART_RATE,
    "height": HealthDataType.HEIGHT,
    "sleep_time": HealthDataType.SLEEP_IN_BED,
    "weight": HealthDataType.WEIGHT,
    "heart_rate": HealthDataType.HEART_RATE,
  };

  @override
  Future<void> authenticate() async {
    return;
  }

  @override
  Future<void> cancelAuthentication() async {
    return;
  }

  // @override
  // Future<Data> getData(
  //     {required String entry,
  //     required DateTime startTime,
  //     required DateTime endTime}) async {
  //   HealthFactory health = HealthFactory(useHealthConnectIfAvailable: false);
  // }
}
