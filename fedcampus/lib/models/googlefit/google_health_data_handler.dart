import 'package:fedcampus/models/health.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleFit extends FedHealthData {
  final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP
  ];
  final Map<String, HealthDataType> healthTypeLookupTable = {
    "step": HealthDataType.STEPS
  };
  final HealthFactory health =
      HealthFactory(useHealthConnectIfAvailable: false);
  GoogleFit() {}

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
    double result = await _aggregateHealthDataPoint(healthDataPoint);
    DataNew data = DataNew(
        name: entry, value: result, startTime: startTime, endTime: endTime);

    return data;
  }

  @override
  Future<bool> authenticate() async {
    await _authrorizeOrErr();

    return true;
  }

  Future<List<HealthDataPoint>> _getData(
      HealthDataType entry, DateTime startTime, DateTime endTime) async {
    // requesting access to the data types before reading them
    try {
      await authenticate();
    } catch (e) {
      throw Exception("Authroization Error");
    }

    // fetch health data from the last 24 hourscd
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

  Future<void> _authrorizeOrErr() async {
    // Beacuse this is labled as a dangerous protection level, the permission system will not grant it automaticlly and it requires the user's action. You can prompt the user for it using the permission_handler plugin. Follow the plugin setup instructions and add the following line before requsting the data:
    // TODO: handle situations and throw exceptions where permissions are not granted
    await Permission.activityRecognition.request();
    await Permission.location.request();
    await health.requestAuthorization(types);
  }
}
