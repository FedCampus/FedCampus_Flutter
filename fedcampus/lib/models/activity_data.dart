// feel free to migrate to json serializable classes such as json_model
class ActivityData {
  static Map<String, dynamic> create() {
    return {
      "step": {"average": 0, "rank": 0, "simliar_user": []},
      "calorie": {"average": 0, "rank": 0, "simliar_user": []},
      "distance": {"average": 0, "rank": 0, "simliar_user": []},
      "stress": {"average": 0, "rank": 0, "simliar_user": []},
      "intensity": {"average": 0, "rank": 0, "simliar_user": []},
      "step_time": {"average": 0, "rank": 0, "simliar_user": []},
      "sleep_efficiency": {"average": 0, "rank": 0, "simliar_user": []},
    };
  }
}
