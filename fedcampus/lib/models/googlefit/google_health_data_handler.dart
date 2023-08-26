import 'package:fedcampus/models/health.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utility/log.dart';

class GoogleFit extends FedHealthData {
  final types = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.ELECTRODERMAL_ACTIVITY,
    HealthDataType.HEART_RATE,
    HealthDataType.HEIGHT,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.PERIPHERAL_PERFUSION_INDEX,
    HealthDataType.STEPS,
    HealthDataType.WAIST_CIRCUMFERENCE,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.MOVE_MINUTES,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.MINDFULNESS,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_OUT_OF_BED,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WATER,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
    HealthDataType.HIGH_HEART_RATE_EVENT,
    HealthDataType.LOW_HEART_RATE_EVENT,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.HEADACHE_NOT_PRESENT,
    HealthDataType.HEADACHE_MILD,
    HealthDataType.HEADACHE_MODERATE,
    HealthDataType.HEADACHE_SEVERE,
    HealthDataType.HEADACHE_UNSPECIFIED,
    HealthDataType.AUDIOGRAM,
    HealthDataType.ELECTROCARDIOGRAM,
  ];
  final Map<String, HealthDataType> healthTypeLookupTable = {
    "step": HealthDataType.STEPS,
    "heart_rate": HealthDataType.HEART_RATE,
    // no rest_heart_rate, exercise_heart_rate
    "active_energy_burned": HealthDataType.ACTIVE_ENERGY_BURNED,
    // no calorie, which is available in google fit but not in flutter health
    "step_time": HealthDataType.MOVE_MINUTES,
    "distance": HealthDataType.DISTANCE_DELTA,
    "sleep_asleep": HealthDataType.SLEEP_ASLEEP,

    // no intense exercise time
    // no stress
    // no sleep_efficiency
  };
  final HealthFactory health =
      HealthFactory(useHealthConnectIfAvailable: false);

  @override
  Future<void> authenticate() async {
    // Beacuse this is labled as a dangerous protection level, the permission system will not grant it automaticlly and it requires the user's action. You can prompt the user for it using the permission_handler plugin. Follow the plugin setup instructions and add the following line before requsting the data:
    // TODO: handle situations and throw exceptions where permissions are not granted
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
  Future<DataNew> getData(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    // TODO: handle exception
    List<HealthDataPoint> healthDataPoint = await _getData(
        healthTypeLookupTable[entry] ?? HealthDataType.STEPS,
        startTime,
        endTime);
    logger.d(healthDataPoint);
    double result = await _aggregateHealthDataPoint(healthDataPoint);
    if (entry == "heart_rate") {
      result = await _averageHealthDataPoint(healthDataPoint);
    }
    DataNew data = DataNew(
        name: entry, value: result, startTime: startTime, endTime: endTime);

    return data;
  }

  @override
  Future<Map<String, double?>> getDataMap({
    required List<String> entry,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    Map<String, double?> dataMap = {};
    for (String element in entry) {
      DataNew data;
      try {
        data = await getData(
            entry: element, startTime: startTime, endTime: endTime);
        dataMap.addAll({data.name: data.value});
      } catch (e) {
        dataMap.addAll({element: null});
      }
    }
    return dataMap;
  }

  Future<List<HealthDataPoint>> _getData(
      HealthDataType entry, DateTime startTime, DateTime endTime) async {
    await authenticate();

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
    } catch (e) {
      rethrow;
    }
    return result / healthDataPoint.length;
  }
}
