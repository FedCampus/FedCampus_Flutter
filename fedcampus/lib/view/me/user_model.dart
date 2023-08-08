import 'dart:convert';

import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:fedcampus/pigeons/loaddata.g.dart';
import 'package:http/http.dart' as http;
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  String log = "";
  String userName = "testName";
  String email = "testEmail";
  String signUpStatus = '';
  bool loggedIn = false;

  void setUser() async {
    final pref = await SharedPreferences.getInstance();
    loggedIn = pref.getBool("login") ?? false;
    logger.d(loggedIn);
    if (loggedIn) {
      userName = pref.getString("userName") ?? "testName";
      email = pref.getString("email") ?? "testEmail";
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> signIn(username, password) async {
    // this method does need to call notifyListeners()
    // >>>>> for test only
    final prefs = await SharedPreferences.getInstance();
    userName = username;
    prefs.setBool("login", true);
    prefs.setString("userName", username);
    prefs.setString("email", email);

    return {"status": true};
    // <<<<< uncomment this

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
        return {"status": false};
      }

      // login success, save token
      logger.i("login success");
      loggedIn = true;
      userName = username;
      final prefs = await SharedPreferences.getInstance();
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];
      HTTPClient.setToken(token);
      prefs.setBool("login", true);
      prefs.setString("username", username);
      prefs.setString("email", email);
      prefs.setString("auth_token", token);
      return {"status": true};
    } on http.ClientException {
      return {"status": false};
    }
  }

  Map<String, String> getLoginStatus() {
    Map<String, String> returnJson = {"user_name": userName};
    return returnJson;
  }

  Future<Map<String, dynamic>> signUp(String email, String netid,
      String password, String passwordConfirm) async {
    // check if email ends in duke.edu
    if (!email.endsWith("@duke.edu")) {
      // showErrorMessage("email has to end with @duke.edu");
      return {"status": false, "message": "email has to end with @duke.edu"};
    }

    if (netid == "") {
      // showErrorMessage("please Enter Your Netid!");
      return {"status": false, "message": "please Enter Your Netid!"};
    }

    if (password.length < 8) {
      // showErrorMessage("password's lengh has to be greater than 8");
      return {
        "status": false,
        "message": "password's lengh has to be greater than 8"
      };
    }

    if (password != passwordConfirm) {
      // showErrorMessage("The two passwords are different!");
      return {"status": false, "message": "The two passwords are different!"};
    }

    // send the request and wait for response

    http.Response response = await HTTPClient.post(
        HTTPClient.register,
        <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        jsonEncode(<String, String>{
          "email": email,
          "password": password,
          "netid": netid
        }));
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['auth_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      HTTPClient.setToken(token);
      return {"status": true};
    } else {
      return {
        "status": false,
        "message": "Please check your network connection."
      };
    }
  }

  logout() async {
    // try {
    //   await HTTPClient.Logout();
    // } on Exception {}
    // final pref = await SharedPreferences.getInstance();
    // pref.setBool("login", false);

    final pref = await SharedPreferences.getInstance();
    pref.setBool("login", false);
    userName = "not logged in";
    email = "not logged in";
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

  loadData() async {
    final host = LoadDataApi();
    bool ifokay = await host.loaddata();
    logger.d("load data is $ifokay");
  }
}
