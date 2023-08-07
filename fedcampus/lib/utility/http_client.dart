import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HTTPClient {
  static const _host = "http://dku-vcm-2630.vm.duke.edu:8005/";

  static const login = "${_host}api/login";

  static const logout = "${_host}auth/token/logout/";

  static const data = "${_host}api/data";

  static const dataDP = "${_host}api/data_dp";

  static const register = "${_host}api/register";

  static var _checkToken = false;

  static var _token = "";

  static void setToken(String token) {
    _token = token;
  }

  static Future<bool> Logout() async {
    final headers = <String, String>{};
    try {
      await HTTPClient.post(logout, headers, null);
      return true;
    } on Exception {
      rethrow;
    } finally {}
  }

  static Future<http.Response> post(
      String url, Map<String, String>? headers, Object? body) async {
    try {
      await getToken(headers);
      return await http.post(Uri.parse(url), headers: headers, body: body);
    } on Exception {
      rethrow;
    } finally {}
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
}
