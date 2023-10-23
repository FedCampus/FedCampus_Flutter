import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utility/calendar.dart' as calendar;
import '../../utility/log.dart';
import '../../utility/my_exceptions.dart';

class GoogleFit extends FedHealthData {
  final types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.MOVE_MINUTES,
    HealthDataType.SLEEP_ASLEEP
  ];
  final Map<String, HealthDataType> healthTypeLookupTable = {
    "step": HealthDataType.STEPS,
    "active_energy_burned": HealthDataType.ACTIVE_ENERGY_BURNED,
    "calorie": HealthDataType.ACTIVE_ENERGY_BURNED,
    // no calorie, which is available in google fit but not in flutter health
    "distance": HealthDataType.DISTANCE_DELTA,
    "stress": HealthDataType.HEART_RATE,
    // no stress
    "heart_rate": HealthDataType.HEART_RATE,
    "rest_heart_rate": HealthDataType.HEART_RATE,
    "exercise_heart_rate": HealthDataType.HEART_RATE,
    // no rest_heart_rate, exercise_heart_rate
    "intensity": HealthDataType.HEART_RATE,
    // no intense exercise time
    "step_time": HealthDataType.MOVE_MINUTES,
    "sleep_asleep": HealthDataType.SLEEP_ASLEEP,
    "sleep_efficiency": HealthDataType.SLEEP_ASLEEP,
    // no sleep_efficiency
  };
  final unAvailableDataTypes = [
    "sleep_efficiency",
    "intensity"
  ]; // totally unavailable

  final HealthFactory health =
      HealthFactory(useHealthConnectIfAvailable: false);

  GoogleFit() {
    authenticate();
  }

  @override
  Future<void> authenticate() async {
    // Beacuse this is labled as a dangerous protection level, the permission system will not grant it automaticlly and it requires the user's action. You can prompt the user for it using the permission_handler plugin. Follow the plugin setup instructions and add the following line before requsting the data:
    PermissionStatus permissionStatus =
        await Permission.activityRecognition.request();
    if (!permissionStatus.isGranted) {
      throw Exception("activity recognition permission denied");
    }
    permissionStatus = await Permission.location.request();
    if (!permissionStatus.isGranted) {
      throw Exception("location permission denied");
    }
    Map<String, String> failed = {};
    for (var type in types) {
      try {
        await health.requestAuthorization(types);
      } catch (e) {
        failed.addAll({type.name: e.toString().substring(0, 17)});
      }
    }
    logger.d(failed);
    bool requested = await health.requestAuthorization(types);
    if (!requested) throw Exception("google fit authorization denied");
  }

  @override
  Future<void> cancelAuthentication() async {
    /// TODO: throws [Exception] when failed
    await health.revokePermissions();
  }

  @override
  Future<Data> getDataInterval(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    List<HealthDataPoint> healthDataPoint = [];
    try {
      healthDataPoint = await _getData(
          healthTypeLookupTable[entry] ?? HealthDataType.STEPS,
          startTime,
          endTime);
    } catch (e) {
      logger.e(e);
      throw AuthenticationException("Google Fit error");
    }
    double result = await _aggregateHealthDataPoint(healthDataPoint);
    if (["heart_rate", "rest_heart_rate", "exercise_heart_rate"]
        .contains(entry)) {
      result = await _averageHealthDataPoint(healthDataPoint);
    }
    if (unAvailableDataTypes.contains(entry)) {
      return Data(
          name: entry,
          value: -1,
          startTime: calendar.dateTimeToInt(startTime),
          endTime: calendar.dateTimeToInt(endTime),
          success: false);
    }
    Data data = Data(
        name: entry,
        value: result,
        startTime: calendar.dateTimeToInt(startTime),
        endTime: calendar.dateTimeToInt(endTime));

    return data;
  }

  Future<List<HealthDataPoint>> _getData(
      HealthDataType entry, DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(startTime, endTime, [entry]);

    return healthData;
  }

  Future<double> _aggregateHealthDataPoint(
      List<HealthDataPoint> healthDataPoint) async {
    double result;
    try {
      result = healthDataPoint
          .map((e) => double.parse(e.value.toString()))
          .reduce((value, element) => value + element);
    } on StateError {
      return 0;
    } catch (e) {
      rethrow;
    }
    return result;
  }

  Future<double> _averageHealthDataPoint(
      List<HealthDataPoint> healthDataPoint) async {
    double result;
    try {
      result = healthDataPoint
          .map((e) => double.parse(e.value.toString()))
          .reduce((value, element) => value + element);
    } on StateError {
      return 0;
    } catch (e) {
      rethrow;
    }
    return result / healthDataPoint.length;
  }
}
