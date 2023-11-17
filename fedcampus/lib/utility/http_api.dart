import 'dart:async';
import 'dart:convert';

import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/my_exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HTTPApi {
  // TODO: make the _host in the production mode
  static const _host = "http://10.201.8.29:8006/";

  static const login = "${_host}api/login";

  static const logoutURL = "${_host}auth/token/logout/";

  static const data = "${_host}api/data";

  static const dataDP = "${_host}api/data_dp";

  static const register = "${_host}api/register";

  static const fedAnalysis = "${_host}api/fedanalysis";

  static const account = "${_host}api/account";

  static const status = "${_host}api/status";

  static const average = "${_host}api/avg";

  static const rank = "${_host}api/rank";

  static var _checkToken = false;

  static var _token = "";

  static void setToken(String token) {
    _token = token;
    _setTokenPreference(token);
  }

  static void _setTokenPreference(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("auth_token", token);
  }

  static Future<http.Response> post(
      String url, Map<String, String>? headers, Object? body) async {
    try {
      await getToken(headers);
      headers!.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
      });

      return await http.post(Uri.parse(url), headers: headers, body: body);
    } catch (e, stackTrace) {
      logger.e("$e $stackTrace");
      rethrow;
    }
  }

  static Future<bool> getToken(Map<String, String>? headers) async {
    if (_checkToken == false) {
      // check the token from preference store
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";
      _token = token;
      _checkToken = true;
    }
    headers?.addAll({"Authorization": " Token $_token"});
    return true;
  }

  static Future<bool> logout() async {
    final headers = <String, String>{};
    try {
      await HTTPApi.post(logoutURL, headers, null);
      return true;
    } on http.ClientException catch (e) {
      logger.e('Logout Error, Please Check your Internet Connection');
      throw ('Logout Error, Please Check your Internet Connection', e);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> signUp(String email, String netid,
      String password, String passwordConfirm) async {
    // check if email ends in duke.edu
    if (!email.endsWith("@duke.edu")) {
      throw ClientException("Email has to end with @duke.edu");
    }
    if (netid == "") {
      throw ClientException("Please Enter Your Netid!");
    }
    if (password.length < 8) {
      throw ClientException("Password's lengh has to be greater than 8");
    }
    if (password != passwordConfirm) {
      throw ClientException("The two passwords are different!");
    }

    final http.Response response;
    // send the request and wait for response
    try {
      response = await HTTPApi.post(
          HTTPApi.register,
          <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          jsonEncode(<String, String>{
            "email": email,
            "password": password,
            "netid": netid
          }));
    } catch (e) {
      logger.e(e);
      throw ('Please Check your Internet Connection', e);
    }

    final responseJson = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token = responseJson['auth_token'];
      HTTPApi.setToken(token);
      final user = User.mapOf(userName: netid, email: email, loggedIn: true);
      return user;
    } else {
      logger.e(Exception(responseJson['error'][0]));
      throw Exception(responseJson['error'][0]);
    }
  }

  static Future<Map<String, dynamic>> signIn(
      String localUserName, String password) async {
    if (localUserName.isEmpty) {
      throw ClientException('Username should not be empty');
    }
    if (password.length < 8) {
      throw ClientException("Password's lengh has to be greater than 8");
    }
    logger.d(localUserName);
    try {
      http.Response response = await HTTPApi.post(
          HTTPApi.login,
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
        throw ClientException('Bad Credentials, please try again');
      }

      // login success, save token
      logger.i("login success");
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];

      HTTPApi.setToken(token);
      Map<String, dynamic> user = User.mapOf(
          userName: responseJson['nickname'],
          email: responseJson['email'],
          loggedIn: true);
      return user;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  static Future<void> accountSettings(int status, int grade, int gender) async {
    bool isFaculty = status == 2;
    bool isMale = gender == 1;
    try {
      var params = <String, dynamic>{
        "faculty": isFaculty,
        "student": grade,
        "male": isMale,
      };
      logger.d(params);
      http.Response response = await HTTPApi.post(
          HTTPApi.account, <String, String>{}, jsonEncode(params));
      if (response.statusCode == 400) {
        logger.e('Bad Credentials, please try again');
        throw ClientException('Bad Credentials, please try again');
      }
      logger.i("account setting success");
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
