import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:intl/intl.dart';

extension DataExtension on Data {
  static final dataList = [
    "step",
    "calorie",
    "distance",
    "stress",
    "rest_heart_rate",
    "intensity",
    "exercise_heart_rate",
    "step_time",
    "sleep_efficiency"
  ];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  Map<String, dynamic> toMapWithTime() {
    return {
      'id': getInt(),
      'name': name,
      'value': value,
      'startTime': int.parse(DateFormat("yyyyMMdd")
          .format(DateTime.fromMillisecondsSinceEpoch(startTime * 1000,
              isUtc: true))
          .toString()),
      'endTime': int.parse(DateFormat("yyyyMMdd")
          .format(
              DateTime.fromMillisecondsSinceEpoch(endTime * 1000, isUtc: true))
          .toString()),
    };
  }

  int getInt() {
    var index = dataList.indexOf(name);
    return endTime * 10 + index;
  }
}
