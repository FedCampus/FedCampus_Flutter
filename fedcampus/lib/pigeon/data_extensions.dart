import 'package:fedcampus/pigeon/generated.g.dart';

extension DataExtension on Data {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
