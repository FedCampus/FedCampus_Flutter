import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/me/user_api.dart';
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
    // user = User.mapOf(userName: 'luyao', email: 'lw337@duke.edu', loggedIn: true);
    try {
      user = await userApi.signIn(_username, _password);
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
      return;
    }
    if (mounted) {
      await Provider.of<UserModel>(context, listen: false).setUser(user);
      showToastMessage('login success', context);
      Navigator.pop(context, true);
    }
  }

  void _toSignUp() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );

    if (result) {
      Navigator.pop(context, true);
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
                  children: [
                    Container(
                      width: 100 * pixel,
                      height: 100 * pixel,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Image.asset(
                      'assets/images/me_nav_icon.png',
                      width: 100 * pixel,
                      height: 100 * pixel,
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
