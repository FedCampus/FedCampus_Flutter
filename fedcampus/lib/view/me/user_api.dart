import 'dart:convert';

import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:fedcampus/pigeons/loaddata.g.dart';
import 'package:http/http.dart' as http;
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserApi get userApi => UserApi.instance;

class UserApi {
  // this model handles all the logic related to user: it communicates with backend
  // server (via http_client). The model is created in main() with lazy set to false.
  // final User user = User(login: 'userName', email: 'email');
  UserApi._();

  static final instance = UserApi._();

  late SharedPreferences _pref;

  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  Future<User> signIn(localUserName, password) async {
    // this method does need to call notifyListeners()
    // >>>>> for test only
    // User user = User(
    //   userName: 'nickname',
    //   email: 'email',
    // );
    // user.loggedIn = true;
    // return user;

    // <<<<< comment this

    logger.d("$localUserName, $password");
    try {
      http.Response response = await HTTPClient.post(
          HTTPClient.login,
          <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          jsonEncode(<String, String>{
            "username": localUserName,
            "password": password,
          }));
      if (response.statusCode == 400) {
        // login failed
        return Future.error('Error');
      }

      // login success, save token
      logger.i("login success");
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];

      HTTPClient.setToken(token);
      User user = User(
          userName: responseJson['nickname'], email: responseJson['email']);
      user.loggedIn = true;
      return user;
    } on http.ClientException {
      return Future.error('Error');
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String netid,
      String password, String passwordConfirm) async {
    // this method does need to call notifyListeners()
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
      _pref.setString("auth_token", token);
      HTTPClient.setToken(token);
      return {"status": true};
    } else {
      return {
        "status": false,
        "message": "Please check your network connection."
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    // >>>>> for test only
    // pref.setBool("login", false);
    // userName = "not logged in";
    // email = "not logged in";
    // notifyListeners();
    // return {"status": true};
    // <<<<< comment this

    try {
      await HTTPClient.Logout();
    } on Exception {
      return {"status": false, "message": "HTTP exception"};
    }
    _pref.setBool("login", false);
    return {"status": true};
  }

  getHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    await host.getAuthenticate();
  }

  cancelHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    await host.cancelAuthenticate();
  }

  loadData() async {
    final host = LoadDataApi();
    bool ifokay = await host.loaddata();
    logger.d("load data is $ifokay");
  }
}
