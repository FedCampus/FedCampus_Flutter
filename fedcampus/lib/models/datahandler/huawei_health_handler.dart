import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
import '../../utility/calendar.dart' as calendar;

class HuaweiHealth extends FedHealthData {
  final host = DataApi();

  @override
  Future<void> authenticate() async {
    logger.d('authenticating');
    final host = HuaweiAuthApi();
    await host.getAuthenticate();
  }

  @override
  Future<void> cancelAuthentication() async {
    /// TODO: throws [Exception] when failed
    final host = HuaweiAuthApi();
    await host.cancelAuthenticate();
  }

  @override
  Future<Data> getData(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    try {
      List<Data?> dataListOne = await host.getData(entry,
          calendar.dateTimeToInt(startTime), calendar.dateTimeToInt(endTime));
      if (dataListOne.isEmpty) {
        return Data(
            name: entry,
            value: -1,
            startTime: calendar.dateTimeToInt(startTime),
            endTime: calendar.dateTimeToInt(endTime),
            success: false);
      } else {
        return dataListOne[0]!;
      }
    } on Exception {
      rethrow;
    }
  }
}
