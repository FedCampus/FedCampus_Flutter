import 'package:google_fit_test_flutter/health.dart';
import 'package:google_fit_test_flutter/log.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleFit extends FedHealthData {
  final Map<String, HealthDataType> healthTypeLookupTable = {
    "step": HealthDataType.STEPS,
    "heart_rate": HealthDataType.HEART_RATE,
    // no rest_heart_rate, exercise_heart_rate
    "active_energy_burned": HealthDataType.ACTIVE_ENERGY_BURNED,
    // no calorie, which is available in google fit but not in flutter health
    "step_time": HealthDataType.MOVE_MINUTES,
    "distance": HealthDataType.DISTANCE_DELTA,
    "sleep_asleep": HealthDataType.SLEEP_ASLEEP,
    "sleep_awake": HealthDataType.SLEEP_AWAKE,
    "sleep_in_bed": HealthDataType.SLEEP_IN_BED,

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
    // if (!permissionStatus.isGranted) {
    //   throw Exception("location permission denied");
    // }
    bool requested = await health.requestAuthorization([HealthDataType.STEPS, HealthDataType.SLEEP_AWAKE, HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP]);
    if (!requested) throw Exception("google fit authorization denied");
  }

  @override
  Future<Map<String, String>> testAvailability() async {
    Map<String, String> testresult = {};
    for (var type in types) {
      try {
        await health.requestAuthorization([type]);
        testresult.addAll({type.name: "availavle"});
      } catch (e) {
        testresult.addAll({type.name: e.toString().substring(0, 17)});
      }
    }
    logger.d(testresult);
    return testresult;
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
