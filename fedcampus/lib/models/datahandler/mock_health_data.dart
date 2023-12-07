import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
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
    "step": 888.0,
    "calorie": 888.0,
    "distance": 888.0,
    "stress": 888.0,
    "rest_heart_rate": 888.0,
    "avg_heart_rate": 888.0,
    "intensity": 888.0,
    "exercise_heart_rate": 888.0,
    "step_time": 888.0,
    "sleep_efficiency": 888.0,
    "query_time": 888.0,
    "total_time_foreground": 888.0,
    "sleep_duration": 1500540.0,
    "carbon_emission": 888.0,
    "sleep_time": 888.0,
  };

  @override
  Future<Data> getDataInterval(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    {
      logger.e(entry);
      return Data(
          name: entry,
          value: mockDataTable[entry]!,
          startTime: calendar.dateTimeToInt(startTime),
          endTime: calendar.dateTimeToInt(endTime),
          success: true);
    }
  }
}
