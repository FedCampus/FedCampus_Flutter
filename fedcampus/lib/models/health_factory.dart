import 'package:fedcampus/models/googlefit/google_health_data_handler.dart';
import 'package:fedcampus/models/health.dart';

class HealthFactory {
  FedHealthData creatHealthDataHandler(String serviceProvider) {
    switch (serviceProvider) {
      case "huawei":
        // TODO: implement Huawei Health
        return GoogleFit();
      case "google":
        return GoogleFit();
      default:
        return GoogleFit();
    }
  }
}
