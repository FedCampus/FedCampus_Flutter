import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/models/datahandler/health_factory.dart';
import 'package:fedcampus/models/datahandler/ios_health_data_handler.dart';
import 'package:fedcampus/models/datahandler/screen_time_data_handler.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

Global get userApi => Global.instance;

class Global {
  Global._();

  static final instance = Global._();

  late SharedPreferences _prefs;

  late FedHealthData healthDataHandler;

  final ScreenTimeData screenTimeDataHandler = ScreenTimeData();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    //TODO: init log
    await Log.initLog();
    // if logged in, initialize healthDataHandler here and skip [Splash], otherwise initialize that in [Splash]
    String splashScreenPolicy =
        userApi.prefs.getString("slpash_screen") ?? "always";
    healthDataHandler = Platform.isAndroid
        ? HealthDataHandlerFactory().creatHealthDataHandler(
            _prefs.getString("service_provider") ?? "huawei")
        : IOSHealth();
    switch (splashScreenPolicy) {
      case "always":
        break;
      case "is_logged_in":
        if (_prefs.getBool("login") ?? false) {}
      case "never":
    }
    // throw Exception('exceptions in initialization');
    return;
  }

  SharedPreferences get prefs => _prefs;
}
