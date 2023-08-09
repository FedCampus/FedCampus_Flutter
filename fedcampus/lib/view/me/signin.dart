import 'package:fedcampus/models/user.dart';
import 'package:fedcampus/models/user_model.dart';
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

  void _register() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
    if (result != null) {
      setState(() {});
    }
  }

  signIn() async {
    var res = await userApi.signIn(_username, _password);
    User user;
    if (mounted) {
      user = res;
      Provider.of<UserModel>(context, listen: false).setUser = user;

      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login status"),
            content: Text(res.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double width = MediaQuery.of(context).size.width;
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
                onPressed: signIn,
                child: const Text('Login'),
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
          )),
        ));
  }
}
