import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/models/datahandler/health_factory.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

Global get userApi => Global.instance;

class Global {
  Global._();

  static final instance = Global._();

  late SharedPreferences _prefs;

  late final FedHealthData healthDataHandler;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    //TODO: init log
    await Log.initLog();
    // if logged in, initialize healthDataHandler here and skip [Splash], otherwise initialize that in [Splash]
    if (_prefs.getBool("login") != null) {
      String serviceProvider = _prefs.getString("service_provider") ?? "huawei";
      healthDataHandler =
          HealthDataHandlerFactory().creatHealthDataHandler(serviceProvider);
    }
    // throw Exception('exceptions in initialization');
  }

  SharedPreferences get prefs => _prefs;
}
