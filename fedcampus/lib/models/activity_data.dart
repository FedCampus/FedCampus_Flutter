// feel free to migrate to json serializable classes such as json_model
import '../utility/global.dart';

class ActivityData {
  static Map<String, dynamic> create() {
    return userApi.isAndroid
        ? {
            "step": {"average": 0, "rank": 0, "simliar_user": []},
            "calorie": {"average": 0, "rank": 0, "simliar_user": []},
            "distance": {"average": 0, "rank": 0, "simliar_user": []},
            "carbon_emission": {"average": 0, "rank": 0, "simliar_user": []},
            "stress": {"average": 0, "rank": 0, "simliar_user": []},
            "intensity": {"average": 0, "rank": 0, "simliar_user": []},
            "step_time": {"average": 0, "rank": 0, "simliar_user": []},
            "sleep_efficiency": {"average": 0, "rank": 0, "simliar_user": []},
          }
        : {
            "step": {"average": 0, "rank": 0, "simliar_user": []},
            "distance": {"average": 0, "rank": 0, "simliar_user": []},
            "carbon_emission": {"average": 0, "rank": 0, "simliar_user": []},
            "calorie": {"average": 0, "rank": 0, "simliar_user": []},
            "sleep_time": {"average": 0, "rank": 0, "simliar_user": []},
          };
  }
}
