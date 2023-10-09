// feel free to migrate to json serializable classes such as json_model
class HealthData {
  static Map<String, double> mapOf({
    double step = 0,
    double calorie = 0,
    double distance = 0,
    double stress = 0,
    double restHeartRate = 0,
    double intensity = 0,
    double exerciseHeartRate = 0,
    double stepTime = 0,
    double sleepEfficiency = 0,
    double queryTime = 0,
  }) {
    return {
      "step": step,
      "calorie": calorie,
      "distance": distance,
      "stress": stress,
      "rest_heart_rate": restHeartRate,
      "intensity": intensity,
      "exercise_heart_rate": exerciseHeartRate,
      "step_time": stepTime,
      "sleep_efficiency": sleepEfficiency,
      "query_time": queryTime
    };
  }
}
