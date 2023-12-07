import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import '../../utility/calendar.dart' as calendar;

class MockHealthData extends FedHealthData {
  final host = DataApi();
  @override
  bool get canAuth => true;

  @override
  bool get canCancelAuth => true;

  @override
  Future<void> authenticate() async {}

  @override
  Future<void> cancelAuthentication() async {}

  final mockDataTable = {
    "step": 999,
    "calorie": 999,
    "distance": 999,
    "stress": 999,
    "rest_heart_rate": 999,
    "intensity": 999,
    "exercise_heart_rate": 999,
    "step_time": 999,
    "sleep_efficiency": 999,
    "query_time": 999,
    "total_time_foreground": 999,
    "sleep_duration": 999,
    "carbon_emission": 999,
  };

  @override
  Future<Data> getDataInterval(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    {
      return Data(
          name: entry,
          value: mockDataTable[entry] as double,
          startTime: calendar.dateTimeToInt(startTime),
          endTime: calendar.dateTimeToInt(endTime),
          success: true);
    }
  }
}
