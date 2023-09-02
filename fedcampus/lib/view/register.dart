import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:fedcampus/utility/http_api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var _email = "";
  var _password = "";
  var _passwordConfirm = "";
  var _netid = "";

  void showErrorMessage(String msg) {
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _signUp() async {
    // check if email ends in duke.edu
    if (!_email.endsWith("@duke.edu")) {
      showErrorMessage("email has to end with @duke.edu");
      return;
    }

    if (_netid == "") {
      showErrorMessage("please Enter Your Netid!");
      return;
    }

    if (_password.length < 8) {
      showErrorMessage("password's lengh has to be greater than 8");
      return;
    }

    if (_password != _passwordConfirm) {
      showErrorMessage("The two passwords are different!");
      return;
    }

    // send the request and wait for response

    http.Response response = await HTTPApi.post(
        HTTPApi.register,
        <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        jsonEncode(<String, String>{
          "email": _email,
          "password": _password,
          "netid": _netid
        }));
    if (response.statusCode == 200) {
      // good
      final token = jsonDecode(response.body)['auth_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      HTTPApi.setToken(token);
      if (mounted) {
        Navigator.pop(context, {"nickname": _netid, "email": _email});
      }
    } else {
      showErrorMessage(jsonDecode(response.body)['error'][0]);
    }
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
            initialValue: _email,
            onChanged: (value) => {_email = value},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            initialValue: _netid,
            onChanged: (value) => {_netid = value},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Netid',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            initialValue: _passwordConfirm,
            obscureText: true,
            onChanged: (value) => {_passwordConfirm = value},
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password Confirm',
            ),
          ),
        ),
        ElevatedButton(
          child: const Text('Sign Up'),
          onPressed: () {
            _signUp();
          },
        ),
      ],
    )));
  }
}
