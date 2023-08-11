import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  User user = User(userName: 'userName', email: 'email');
  late SharedPreferences _pref;

  UserModel() {
    init().then(
      (value) => {logger.d('user model init finished')},
    );
  }

  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
    user.loggedIn = _pref.getBool("login") ?? false;
    if (user.loggedIn) {
      user.userName = _pref.getString("userName") ?? "username placeholder";
      user.email = _pref.getString("email") ?? "email placeholder";
    }
  }

  bool get isLogin => user.loggedIn;

  set setUser(User user) {
    this.user = user;
    _pref.setBool("login", user.loggedIn);
    _pref.setString("userName", user.userName);
    _pref.setString("email", user.email);
    notifyListeners();
  }

  set setLogin(bool loggedIn) {
    user.loggedIn = loggedIn;
    _pref.setBool("login", user.loggedIn);
    notifyListeners();
  }
}
