class ScreenData {
  static Map<String, double> mapOf({
    double totalTimeForeGround = 0,
    double queryTime = 0,
  }) {
    return {
      "total_time_foreground": totalTimeForeGround,
      "query_time": queryTime
    };
  }
}
