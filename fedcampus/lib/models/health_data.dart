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
  }) {
    return {
      "step": step,
      "calorie": calorie,
      "distance": distance,
      "stress": stress,
      "restHeartRate": restHeartRate,
      "intensity": intensity,
      "exerciseHeartRate": exerciseHeartRate,
      "stepTime": stepTime,
      "sleepEfficiency": sleepEfficiency,
    };
  }
}
