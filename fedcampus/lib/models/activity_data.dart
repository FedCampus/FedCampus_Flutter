// feel free to migrate to json serializable classes such as json_model
class ActivityData {
  static Map<String, dynamic> create() {
    return {
      "step": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "calorie": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "distance": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "stress": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "intensity": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "step_time": {"average": 0, "rank": '0/0', "simliar_user": Null},
      "sleep_efficiency": {"average": 0, "rank": '0/0', "simliar_user": Null},
    };
  }
}
