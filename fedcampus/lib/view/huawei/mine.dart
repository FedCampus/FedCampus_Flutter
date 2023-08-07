import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/view/register.dart';
import 'package:fedcampus/view/signin.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin<MinePage> {
  final methodChannel = const MethodChannel('fed_kit_flutter');

  var log = "";

  @override
  void initState() {
    super.initState();
    setUser();
  }

  void setUser() async {
    final pref = await SharedPreferences.getInstance();
    final iflogin = pref.getBool("login") ?? false;
    if (iflogin) {
      setState(() {
        final nickname = pref.get("nickname");
        final email = pref.get("email");
        log += "nickname : $nickname \n email: $email ";
      });
    }
  }

  getHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    bool ifAuth = await host.getAuthenticate();
    print(ifAuth);
  }

  _cancelHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    bool ifCancel = await host.cancelAuthenticate();
    print("if cancelled $ifCancel");
  }

  Future<void> _loginAndGetResult() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
    if (result != null) {
      //success
      final nickname = result['nickname'];
      final email = result['email'];
      // save the nickname and email in shared preference
      setState(() {
        log += "nickname : $nickname \n email: $email ";
      });

      final pref = await SharedPreferences.getInstance();
      pref.setString("nickname", nickname);
      pref.setString("email", email);
      pref.setBool("login", true);
    }
  }

  void _logout() async {
    try {
      bool ifLogout = await HTTPClient.Logout();
    } on Exception {}

    setState(() {
      log = "";
    });

    final pref = await SharedPreferences.getInstance();
    pref.setBool("login", false);
  }

  void _register() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );

    if (result != null) {
      print(result);
      final nickname = result['nickname'];
      final email = result['email'];
      setState(() {
        log += "nickname : $nickname \n email: $email ";
      });
      final pref = await SharedPreferences.getInstance();
      pref.setString("nickname", nickname);
      pref.setString("email", email);
      pref.setBool("login", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Text("home page"),
            Center(
              child: ElevatedButton(
                child: const Text('Open training page'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrainApp()),
                  );
                },
              ),
            ),
            // test huawei authentication code
            Center(
              child: ElevatedButton(
                child: const Text('Huawei Authenticate'),
                onPressed: () {
                  getHuaweiAuthenticate();
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Cancel Authenticate'),
                onPressed: () {
                  _cancelHuaweiAuthenticate();
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                _loginAndGetResult();
              },
            ),
            ElevatedButton(
              child: const Text('LogOut'),
              onPressed: () {
                _logout();
              },
            ),
            ElevatedButton(
              child: const Text('Register'),
              onPressed: () {
                _register();
              },
            ),
            Text(log),
          ],
        )));
  }

  @override
  bool get wantKeepAlive => true;
}
