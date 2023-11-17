// feel free to migrate to json serializable classes such as json_model
import '../utility/global.dart';

class ActivityData {
  static Map<String, dynamic> create() {
    return userApi.isAndroid
        ? {
            "step": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "calorie": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "distance": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "stress": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "intensity": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "step_time": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "sleep_efficiency": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "carbon_emission": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
          }
        : {
            "step": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "distance": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "calorie": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "sleep_time": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
            "carbon_emission": {
              "average": 0,
              "rank": 0,
              "simliar_user": [],
              "valid_data": false
            },
          };
  }
}
