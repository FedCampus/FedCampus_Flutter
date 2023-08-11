import 'package:fedcampus/models/health_data.dart';
import 'package:fedcampus/pigeons/messages.g.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/me/user_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HealthDataModel extends ChangeNotifier {
  Map<String, double> healthData = HealthData.mapOf();
  bool isAuth = false;
  late final DataApi host;
  String _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final dataList = [
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

  HealthDataModel() {
    host = DataApi();
  }

  bool get isAuthenticated => isAuth;

  set isAuthenticated(bool auth) {
    isAuth = auth;
    userApi.prefs.setBool("login", auth);
    notifyListeners();
  }

  set date(String date) {
    _date = date;
    getData();
  }

  Future<void> getData() async {
    int date = 0;
    logger.d(date);
    try {
      date = int.parse(_date);
      for (var i = 0; i < dataList.length; i++) {
        healthData[dataList[i]] =
            (await getDataEntry(host, dataList[i], date))?.value ?? 0;
      }
      notifyListeners();
    } on Exception catch (e) {
      logger.e(e);
      return;
    }
  }

  Future<Data?> getDataEntry(DataApi host, String name, int time) async {
    List<Data?> dataList;
    try {
      dataList = await host.getData(name, time, time);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");
        // redirect the user to the authenticate page
        isAuthenticated = false;
        await userApi.healthServiceAuthenticate();
        dataList = await host.getData(name, time, time);
      } else if (error.message == "java.lang.SecurityException: 50030") {
        logger.d("internet error");
      } else {
        logger.e(error.toString());
      }
      logger.e("catching error $error");
      return null;
    }
    try {
      return dataList[0];
    } on RangeError {
      logger.i("no data for $name");
      return null;
    }
  }
}
