import 'package:fedcampus/models/datahandler/google_health_data_handler.dart';
import 'package:fedcampus/models/datahandler/huawei_health_handler.dart';
import 'package:fedcampus/models/datahandler/health_handler.dart';
import 'package:fedcampus/models/datahandler/ios_health_data_handler.dart';
import 'package:fedcampus/utility/log.dart';

class HealthDataHandlerFactory {
  FedHealthData creatHealthDataHandler(String serviceProvider) {
    switch (serviceProvider) {
      case "huawei":
        logger.d("Using Huawei Health.");
        return HuaweiHealth();
      case "google":
        logger.d("Using Google Fit.");
        return GoogleFit();
      case "ios":
        return IOSHealth();
      default:
        logger.d("Using Google Fit.");
        return GoogleFit();
    }
  }
}
