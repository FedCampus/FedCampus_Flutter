import 'dart:async';

import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/my_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fedcampus/view/me/signup.dart';
import 'package:fedcampus/view/widgets/widget.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _username = "";
  String _password = "";
  TextEditingController emailTextEditingController = TextEditingController();

  _signIn() async {
    Map<String, dynamic> user;
    // user =
    //     User.mapOf(userName: 'luyao', email: 'lw337@duke.edu', loggedIn: true);
    // await Provider.of<UserModel>(context, listen: false).setUser(user);
    // return;
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    try {
      user = await HTTPApi.signIn(_username, _password)
          .timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      _showIfDialogNotCancelled(
          e, "Please check your internet connection", loadingDialog);
      return;
    } on MyException catch (e) {
      _showIfDialogNotCancelled(e, e.toString(), loadingDialog);
      return;
    } on Exception catch (e) {
      _showIfDialogNotCancelled(e, "Log in error", loadingDialog);
      return;
    }
    loadingDialog.cancel();
    if (mounted) {
      await Provider.of<UserModel>(context, listen: false).setUser(user);
      if (mounted) {
        showToastMessage('login success', context);
        Navigator.pop(context, true);
      }
    }
  }

  void _showIfDialogNotCancelled(
      Exception e, String message, LoadingDialog loadingDialog) {
    logger.e(e);
    if (mounted && !loadingDialog.cancelled) {
      showToastMessage(message, context);
      loadingDialog.cancel();
    }
  }

  void _toSignUp() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
    if (result == null) {
      return;
    }
    if (result) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: Center(
              child: Column(
            children: <Widget>[
              const Expanded(flex: 1, child: SizedBox()),
              ClipOval(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      width: 100 * pixel,
                      height: 100 * pixel,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                    ),
                    Image.asset(
                      'assets/images/me_nav_icon.png',
                      width: 85 * pixel,
                      height: 85 * pixel,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Text(
                'Sign in',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontSize: pixel * 27,
                ),
              ),
              const Expanded(child: SizedBox()),
              SignInUpTextField(
                ifObscure: false,
                field: _username,
                label: 'Email',
                onChanged: (value) => {_username = value},
              ),
              const Expanded(flex: 2, child: SizedBox()),
              SignInUpTextField(
                ifObscure: true,
                field: _password,
                label: 'Password',
                onChanged: (value) => {_password = value},
              ),
              const Expanded(flex: 1, child: SizedBox()),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Login'),
              ),
              const Expanded(child: SizedBox()),
              TextButton(
                onPressed: () => _toSignUp(),
                child: Text(
                  'No account? Sign up',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontSize: pixel * 18,
                  ),
                ),
              ),
              Spacer(
                flex: (6 / aspectRatio).round(),
              ),
              Text(
                'Welcome to DKU FedCampus',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontSize: pixel * 18,
                ),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          )),
        ));
  }
}
