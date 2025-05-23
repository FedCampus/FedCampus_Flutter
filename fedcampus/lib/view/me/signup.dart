import 'dart:async';

import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';

import 'package:fedcampus/view/widgets/widget.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var _email = "";
  var _password = "";
  var _passwordConfirm = "";
  var _netid = "";

  signUp() async {
    late Map<String, dynamic> user;
    try {
      user = await HTTPApi.signUp(_email, _netid, _password, _passwordConfirm)
          .timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      logger.e(e);
      if (mounted) {
        showToastMessage("Please check your internet connection", context);
      }
      return;
    } on Exception catch (e) {
      if (mounted) showToastMessage(e.getMessage, context);
      return;
    }
    if (mounted) showToastMessage('sign up sucess', context);
    if (mounted) {
      await Provider.of<UserModel>(context, listen: false).setUser(user);
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign up'),
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Column(
          children: <Widget>[
            const Expanded(flex: 2, child: SizedBox()),
            Text(
              'Sign up',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontSize: pixel * 27,
              ),
            ),
            const Expanded(flex: 3, child: SizedBox()),
            SignInUpTextField(
              ifObscure: false,
              field: _email,
              label: 'Email',
              onChanged: (value) => {_email = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              ifObscure: true,
              field: _password,
              label: 'Password',
              onChanged: (value) => {_password = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              ifObscure: true,
              field: _passwordConfirm,
              label: 'Password confirm',
              onChanged: (value) => {_passwordConfirm = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              ifObscure: false,
              field: _netid,
              label: 'NetID',
              onChanged: (value) => {_netid = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),
            Spacer(flex: (7 / aspectRatio).round()),
          ],
        )));
  }
}
