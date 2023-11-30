import 'dart:async';

import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/utility/event_bus.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/my_exceptions.dart';
import 'package:flutter/foundation.dart';
import '../../utility/http_api.dart';

class UserModel extends ChangeNotifier {
  Map<String, dynamic> user = User.mapOf(userName: 'userName', email: 'email');
  UserModel() {
    user['loggedIn'] = userApi.prefs.getBool("login") ?? false;
    if (user['loggedIn']) {
      user['userName'] =
          userApi.prefs.getString("userName") ?? "username placeholder";
      user['email'] = userApi.prefs.getString("email") ?? "email placeholder";
    }
  }

  bool get isLogin => user['loggedIn'];

  setUser(Map<String, dynamic> user) async {
    this.user = user;
    userApi.prefs.setBool("login", user['loggedIn']);
    userApi.prefs.setString("userName", user['userName']);
    userApi.prefs.setString("email", user['email']);
    notifyListeners();
  }

  set setLogin(bool loggedIn) {
    user['loggedIn'] = loggedIn;
    userApi.prefs.setBool("login", user['loggedIn']);
    notifyListeners();
  }

  // TODO: verify settings from server
  int _status = userApi.prefs.getInt("status") ?? 1;
  int _grade = userApi.prefs.getInt("grade") ?? 2025;
  int _gender = userApi.prefs.getInt("gender") ?? 1; // 1 male, 2 female

  get myStatus => _status;
  get myGrade => _grade;
  get myGender => _gender;

  Future<void> myAccountSettings({int? status, int? grade, int? gender}) async {
    try {
      final bool isFaculty = (status ?? _status) == 2;
      await HTTPApi.accountSettings({
        "faculty": isFaculty,
        if (!isFaculty) "student": grade ?? _grade,
        "male": (status ?? _status) == 1,
      }).timeout(const Duration(seconds: 5));
      // update corresponding fields
      if (status != null) _status = status;
      if (grade != null) _grade = grade;
      if (gender != null) _gender = gender;
      notifyListeners();
    } on TimeoutException catch (e) {
      _logAndNotify(e, "Please check your internet connection");
      return;
    } on MyException catch (e) {
      _logAndNotify(e, e.toString());
      return;
    } on Exception catch (e) {
      _logAndNotify(e, "Log in error");
      return;
    }
    userApi.prefs.setInt("status", _status);
    userApi.prefs.setInt("grade", _grade);
    userApi.prefs.setInt("gender", _gender);
    bus.emit("toast_success", "Account settings success!");
    bus.emit("loading_done");
  }

  void _logAndNotify(Exception e, String message) {
    logger.e(e);
    bus.emit("toast_error", message);
    bus.emit("loading_done");
  }
}
