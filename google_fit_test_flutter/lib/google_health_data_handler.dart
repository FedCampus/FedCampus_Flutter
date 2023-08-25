import 'package:google_fit_test_flutter/health.dart';
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
  final HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  GoogleFit() {}

  @override
  Future<double> getData(
      {required String entry, required DateTime date}) async {
        // TODO: handle exception
    List<HealthDataPoint> healthDataPoint =
        await _getData(healthTypeLookupTable[entry] ?? HealthDataType.STEPS);
    double result = await _aggregateHealthDataPoint(healthDataPoint);

    return result;
  }

  @override
  Future<bool> authenticate() async {
    await _authrorizeOrErr();

    return true;
  }

  Future<List<HealthDataPoint>> _getData(HealthDataType entry) async {
    // requesting access to the data types before reading them
    try {
      await authenticate();
    } catch (e) {
      throw Exception("Authroization Error");
    }

    var now = DateTime.now();

    // fetch health data from the last 24 hourscd
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(const Duration(days: 1)), now, [entry]);

    return healthData;
  }

  Future<double> _aggregateHealthDataPoint(
      List<HealthDataPoint> healthDataPoint) async {
    double result = healthDataPoint
        .map((e) => double.parse(e.value.toString()))
        .reduce((value, element) => value + element);
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
