import 'dart:convert';

import 'package:fedcampus/utility/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _username = "";
  var _password = "";

  void _login() async {
    logger.i("username: $_username , password: $_password");
    try {
      http.Response response = await HTTPClient.post(
          HTTPClient.login,
          <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          jsonEncode(<String, String>{
            "username": _username,
            "password": _password,
          }));
      if (response.statusCode == 400) {
        // login failed
        _showLogInFailed();
        return;
      }

      // login success, save token
      logger.i("login success");
      final prefs = await SharedPreferences.getInstance();
      final responseJson = jsonDecode(response.body);
      String token = responseJson['auth_token'];
      HTTPClient.setToken(token);
      await prefs.setString("auth_token", token);
      Navigator.pop(context, responseJson);
    } on http.ClientException {
      _showLogInError();
    }
  }

  void _showLogInError() {
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
        msg: "Login Error, Please Check your Internet Connection.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showLogInFailed() {
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
        msg: "Bad Credentials, please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            initialValue: _username,
            onChanged: (value) => {_username = value},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'UserName',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            initialValue: _password,
            obscureText: true,
            onChanged: (value) => {_password = value},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        ElevatedButton(
          child: const Text('Login'),
          onPressed: () {
            _login();
          },
        ),
      ],
    )));
  }
}
