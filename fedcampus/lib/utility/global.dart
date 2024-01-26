import 'dart:io';

import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/models/datahandler/health_factory.dart';
// import 'package:fedcampus/models/datahandler/mock_health_data.dart';
import 'package:fedcampus/models/datahandler/screen_time_data_handler.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

Global get userApi => Global.instance;

class Global {
  Global._();

  static final instance = Global._();

  late SharedPreferences _prefs;

  // No need to healthDataHandler final. The previous one is over-design and error-prone,
  // which the ability to change healthDataHandler in settings
  late FedHealthData healthDataHandler;

  final ScreenTimeData screenTimeDataHandler = ScreenTimeData();

  late final String version;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    //TODO: init log
    await Log.initLog();
    // if logged in, initialize healthDataHandler here and skip [Splash], otherwise initialize that in [Splash]
    healthDataHandler = isAndroid
        ? HealthDataHandlerFactory().creatHealthDataHandler(
            _prefs.getString("service_provider") ?? "huawei")
        : HealthDataHandlerFactory().creatHealthDataHandler("ios");
    // healthDataHandler = MockHealthData();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = "${Platform.isAndroid ? "android" : "ios"}${packageInfo.version}";
  }

  SharedPreferences get prefs => _prefs;

  bool get isAndroid => Platform.isAndroid;
}
