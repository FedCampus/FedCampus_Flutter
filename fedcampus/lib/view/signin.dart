import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _username = "";
  var _password = "";

  void _login() async {
    logger.i("username: $_username , password: $_password");
    http.Response response = await http.post(
        Uri.parse("http://dku-vcm-2630.vm.duke.edu:8005/auth/token/login/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "username": _username,
          "password": _password,
        }));
    var data = jsonDecode(response.body);
    print(data['auth_token']);
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
