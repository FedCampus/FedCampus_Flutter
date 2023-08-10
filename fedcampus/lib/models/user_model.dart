import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/view/me/user_api.dart';
import 'package:flutter/foundation.dart';

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

  set setUser(Map<String, dynamic> user) {
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
}
