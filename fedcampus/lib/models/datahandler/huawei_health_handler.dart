import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/pigeon/data_extensions.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';

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
      List<Data?> dataListOne = await host.getData(
          entry,
          DataExtension.dateTimeToInt(startTime),
          DataExtension.dateTimeToInt(endTime));
      if (dataListOne.isEmpty) {
        return Data(
            name: entry,
            value: -1,
            startTime: DataExtension.dateTimeToInt(startTime),
            endTime: DataExtension.dateTimeToInt(endTime),
            success: false);
      } else {
        return dataListOne[0]!;
      }
    } on Exception {
      rethrow;
    }
  }
}
