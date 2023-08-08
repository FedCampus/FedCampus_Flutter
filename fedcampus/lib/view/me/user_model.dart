import 'dart:convert';

import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:http/http.dart' as http;
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  String log = "";
  String _username = "";
  String _password = "";
  String _signUpStatus = '';
  bool loggedIn = false;

  void setUser() async {
    final pref = await SharedPreferences.getInstance();
    final iflogin = pref.getBool("login") ?? false;
    if (iflogin) {
      final nickname = pref.get("nickname");
      final email = pref.get("email");
      log += "nickname : $nickname \n email: $email ";
    }
    notifyListeners();
  }

  getHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    await host.getAuthenticate();
    notifyListeners();
  }

  cancelHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    await host.cancelAuthenticate();
    notifyListeners();
  }

  Future<void> _loginAndGetResult(nickname, email) async {
    logger.d(nickname);
    final pref = await SharedPreferences.getInstance();
    pref.setString("nickname", nickname);
    pref.setString("email", email);
    pref.setBool("login", true);
  }

  Future<bool> signIn(username, password) async {
    logger.d("$username, $password");
    try {
      http.Response response = await HTTPClient.post(
          HTTPClient.login,
          <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          jsonEncode(<String, String>{
            "username": username,
            "password": password,
          }));
      if (response.statusCode == 400) {
        // login failed
        return false;
      }

      // login success, save token
      logger.i("login success");
      loggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];
      HTTPClient.setToken(token);
      await prefs.setString("auth_token", token);
      return true;
    } on http.ClientException {
      return false;
    }
  }

  bool getLoginStatus() {
    return true;
  }

  Future<bool> signUp(String _email, String _netid, String _password,
      String _passwordConfirm) async {
    // check if email ends in duke.edu
    if (!_email.endsWith("@duke.edu")) {
      // showErrorMessage("email has to end with @duke.edu");
      return false;
    }

    if (_netid == "") {
      // showErrorMessage("please Enter Your Netid!");
      return false;
    }

    if (_password.length < 8) {
      // showErrorMessage("password's lengh has to be greater than 8");
      return false;
    }

    if (_password != _passwordConfirm) {
      // showErrorMessage("The two passwords are different!");
      return false;
    }

    // send the request and wait for response

    http.Response response = await HTTPClient.post(
        HTTPClient.register,
        <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        jsonEncode(<String, String>{
          "email": _email,
          "password": _password,
          "netid": _netid
        }));
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['auth_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      HTTPClient.setToken(token);
      return true;
    } else {
      return false;
    }
  }
}
