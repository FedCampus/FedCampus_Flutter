import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fedcampus/utility/http_client.dart';
import 'package:fedcampus/utility/log.dart';
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
    await host.getAuthenticate();
  }

  _cancelHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    await host.cancelAuthenticate();
  }

  Future<void> _loginAndGetResult() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
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
      await HTTPClient.logout();
    } on Exception {
      rethrow;
    }

    setState(() {
      log = "";
    });

    final pref = await SharedPreferences.getInstance();
    pref.setBool("login", false);
  }

  void _register() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Register()),
    );

    if (result != null) {
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

  void _loadData() async {
    // final host = LoadDataApi();
    // final input = await host.loaddata();
    // input.forEach((key, value) {
    //   logger.i("input");
    //   printDoubleList(key);
    //   logger.i("sleep: ${value![0].toString()}");
    //   logger.i("------");
    // });
  }

  void printDoubleList(List<List<double?>?>? list) {
    for (final element in list!) {
      logger.i(element.toString());
    }
  }

  void _setAlarm() async {
    final host = AlarmApi();
    await host.setAlarm();
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
            ElevatedButton(
              child: const Text('load data'),
              onPressed: () {
                _loadData();
              },
            ),
            ElevatedButton(
              child: const Text('Set Alarm for training'),
              onPressed: () {
                _setAlarm();
              },
            ),
            Text(log),
          ],
        )));
  }

  @override
  bool get wantKeepAlive => true;
}
