import 'package:fedcampus/models/googlefit/google_health_data_handler.dart';
import 'package:fedcampus/models/googlefit/huawei_health_handler.dart';
import 'package:fedcampus/models/health.dart';

class HealthFactory {
  FedHealthData creatHealthDataHandler(String serviceProvider) {
    switch (serviceProvider) {
      case "huawei":
        return HuaweiHealth();
      case "google":
        return GoogleFit();
      default:
        return GoogleFit();
    }
  }
}
