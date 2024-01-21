// feel free to migrate to json serializable classes such as json_model
import '../utility/global.dart';

class ActivityData {
  static Map<String, dynamic> create() {
    return userApi.isAndroid
        ? {
            "step": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "calorie": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "distance": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "stress": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "intensity": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "step_time": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "sleep_efficiency": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "carbon_emission": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
          }
        : {
            "step": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "distance": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "calorie": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "sleep_time": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "sleep_duration": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
            "carbon_emission": {
              "average": 0,
              "rank": 0,
              "data_points": [],
            },
          };
  }
}
