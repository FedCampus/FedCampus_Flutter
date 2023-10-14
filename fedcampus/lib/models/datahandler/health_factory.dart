import 'package:fedcampus/models/datahandler/google_health_data_handler.dart';
import 'package:fedcampus/models/datahandler/huawei_health_handler.dart';
import 'package:fedcampus/models/datahandler/health.dart';
import 'package:fedcampus/models/datahandler/ios_health_data_handler.dart';

class HealthDataHandlerFactory {
  FedHealthData creatHealthDataHandler(String serviceProvider) {
    switch (serviceProvider) {
      case "huawei":
        return HuaweiHealth();
      case "google":
        return GoogleFit();
      case "ios":
        return IOSHealth();
      default:
        return GoogleFit();
    }
  }
}
