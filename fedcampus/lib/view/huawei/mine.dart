import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:fedcampus/view/signin.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fedcampus/view/train_app.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final methodChannel = const MethodChannel('fed_kit_flutter');

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

  @override
  Widget build(BuildContext context) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
            ),
          ],
        )));
  }
}
