import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/my_exceptions.dart';
import 'package:flutter/services.dart';
import '../../utility/calendar.dart' as calendar;

class HuaweiHealth extends FedHealthData {
  final host = DataApi();
  @override
  bool get canAuth => true;

  @override
  bool get canCancelAuth => true;

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
  Future<Data> getDataInterval(
      {required String entry,
      required DateTime startTime,
      required DateTime endTime}) async {
    try {
      List<Data?> dataListOne = await host.getData(entry,
          calendar.dateTimeToInt(startTime), calendar.dateTimeToInt(endTime));
      if (dataListOne.isEmpty) {
        // the program does not go wrong, but no valid data, and thus should be omitted in FA
        return Data(
            name: entry,
            value: -1,
            startTime: calendar.dateTimeToInt(startTime),
            endTime: calendar.dateTimeToInt(endTime),
            success: false);
      } else {
        return Data(
            name: entry,
            value: dataListOne[0]!.value,
            startTime: calendar.dateTimeToInt(startTime),
            endTime: calendar.dateTimeToInt(endTime),
            success: true);
      }
    } on PlatformException catch (error) {
      logger.e(error);
      if (error.message == "java.lang.SecurityException: 50005") {
        throw AuthenticationException("java.lang.SecurityException: 50005");
      } else if (error.message == "java.lang.SecurityException: 50030" ||
          error.message == "java.lang.SecurityException: 50008") {
        throw InternetConnectionException(
            "Internet Connection Issue, please connect to Internet");
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
