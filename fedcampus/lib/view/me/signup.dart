import 'package:fedcampus/view/me/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:fedcampus/view/widgets/widget.dart';

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

  signUp() async {
    var res = await Provider.of<UserModel>(context, listen: false)
        .signUp(_email, _netid, _password, _passwordConfirm);
    if (mounted) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sign up status"),
            content: Text("${res["status"]}2\n${res["message"]}"),
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
    // double width = MediaQuery.of(context).size.width;
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
                color: Theme.of(context).colorScheme.primary,
                fontSize: 27,
              ),
            ),
            const Expanded(flex: 3, child: SizedBox()),
            SignInUpTextField(
              field: _email,
              label: 'Email',
              onChanged: (value) => {_email = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              field: _password,
              label: 'Password',
              onChanged: (value) => {_password = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              field: _passwordConfirm,
              label: 'Password confirm',
              onChanged: (value) => {_passwordConfirm = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              field: _netid,
              label: 'NetID',
              onChanged: (value) => {_netid = value},
            ),
            const Expanded(flex: 1, child: SizedBox()),
            SignInUpTextField(
              field: _password,
              label: 'Password',
              onChanged: (value) => {_password = value},
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
