import 'dart:convert';
import 'package:fedcampus/view/me/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/view/register.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:fedcampus/utility/log.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _username = "";
  String _password = "";
  String _signUpStatus = '';
  TextEditingController emailTextEditingController = TextEditingController();

  void signIn() async {
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
      if (mounted) Navigator.pop(context, responseJson);
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

  void _register() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Register()),
    );
    if (result != null) {
      setState(() {
        _signUpStatus = 'success';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double width = MediaQuery.of(context).size.width;
    logger.d(aspectRatio);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Column(
          children: <Widget>[
            const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 1,
                )),
            CircleAvatar(
              foregroundImage: const AssetImage(
                'assets/images/me_nav_icon.png',
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              maxRadius: width / 7,
              minRadius: width / 8,
            ),
            const Expanded(
                child: SizedBox(
              height: 1,
            )),
            Text(
              'Sign in',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 27,
              ),
            ),
            const Expanded(
                child: SizedBox(
              height: 1,
            )),
            SignInUpTextField(
              field: _username,
              label: 'Email',
              onChanged: (value) => {_username = value},
            ),
            const Expanded(flex: 2, child: SizedBox()),
            SignInUpTextField(
              field: _password,
              label: 'Password',
              onChanged: (value) => {_password = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                Provider.of<UserModel>(context, listen: false)
                    .signIn(_username, _password);
                ;
              },
            ),
            const Expanded(
                child: SizedBox(
              height: 1,
            )),
            GestureDetector(
              onTap: _register,
              child: Text(
                'No account? Sign up',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  fontSize: 18,
                ),
              ),
            ),
            Spacer(
              flex: (6 / aspectRatio).round(),
            ),
            Text(
              'Welcome to DKU FedCampus',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surfaceVariant,
                fontSize: 18,
              ),
            ),
            const Spacer(
              flex: 1,
            ),
          ],
        )));
  }
}
