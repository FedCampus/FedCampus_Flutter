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
    // throw Exception('exceptions in initialization');
  }

  SharedPreferences get prefs => _pref;

  Future<Map<String, dynamic>> signIn(
      String localUserName, String password) async {
    // >>>>> for test only
    // User user = User(
    //   userName: 'nickname',
    //   email: 'email',
    // );
    // user.loggedIn = true;
    // return user;
    // <<<<< comment this
    if (localUserName.isEmpty) {
      throw Exception('Username should not be empty');
    }
    if (password.length < 8) {
      throw Exception("Password's lengh has to be greater than 8");
    }
    logger.d(localUserName);
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
        logger.e('Bad Credentials, please try again');
        throw Exception('Bad Credentials, please try again');
      }

      // login success, save token
      logger.i("login success");
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];

      HTTPClient.setToken(token);
      Map<String, dynamic> user = User.mapOf(
          userName: responseJson['nickname'],
          email: responseJson['email'],
          loggedIn: true);
      return user;
    } on http.ClientException catch (e) {
      logger.e(e);
      throw ('Login Error, Please Check your Internet Connection', e);
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String netid,
      String password, String passwordConfirm) async {
    // check if email ends in duke.edu
    if (!email.endsWith("@duke.edu")) {
      throw Exception("Email has to end with @duke.edu");
    }
    if (netid == "") {
      throw Exception("Please Enter Your Netid!");
    }
    if (password.length < 8) {
      throw Exception("Password's lengh has to be greater than 8");
    }
    if (password != passwordConfirm) {
      throw Exception("The two passwords are different!");
    }

    // send the request and wait for response
    try {
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
      final responseJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = responseJson['auth_token'];
        HTTPClient.setToken(token);
        final user = User.mapOf(userName: netid, email: email, loggedIn: true);
        return user;
      } else {
        logger.e(Exception(responseJson['error'][0]));
        throw Exception(responseJson['error'][0]);
      }
    } on http.ClientException catch (e) {
      logger.e(e);
      throw ('Login Error, Please Check your Internet Connection', e);
    }
  }

  Future<void> logout() async {
    try {
      await HTTPClient.Logout();
    } on http.ClientException catch (e) {
      logger.e('Logout Error, Please Check your Internet Connection');
      throw ('Logout Error, Please Check your Internet Connection', e);
    }
  }

  healthServiceAuthenticate() async {
    logger.d('authenticating');
    final host = HuaweiAuthApi();
    await host.getAuthenticate();
  }

  healthServiceCancel() async {
    final host = HuaweiAuthApi();
    await host.cancelAuthenticate();
  }

  loadData() async {
    // TODO:
    final host = LoadDataApi();
    final input = await host.loaddata();
  }
}
