import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/models/user_api.dart';
import 'package:fedcampus/pigeon/generated.g.dart';

class HuaweiHealth extends FedHealthData {
  final host = DataApi();

  @override
  Future<void> authenticate() async {
    await userApi.healthServiceAuthenticate();
  }

  @override
  Future<Data> getData(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    try {
      List<Data?> dataListOne = await host.getData(
          entry, Data.dateTimeToInt(startTime), Data.dateTimeToInt(endTime));
      if (dataListOne.isEmpty) {
        return Data(
            name: entry,
            value: -1,
            startTime: Data.dateTimeToInt(startTime),
            endTime: Data.dateTimeToInt(endTime),
            success: false);
      } else {
        return dataListOne[0]!;
      }
    } on Exception {
      rethrow;
    }
  }
}
