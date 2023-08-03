import 'dart:math';

import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fedcampus/view/train_app.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  final methodChannel = const MethodChannel('fed_kit_flutter');

  getHuaweiAuthenticate() async {
    String s;
    try {
      s = await methodChannel.invokeMethod<String>("huawei_authenticate") ??
          "not good";
    } on PlatformException catch (e) {
      print(e);
      s = "shiting";
    }
  }

  getData() async {
    String s;
    try {
      s = await methodChannel.invokeMethod<String>("get_data") ?? "no data";
    } on PlatformException catch (e) {
      logger.i(e);
      s = "error";
    }
    print(s);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            Text("home page"),
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
            // get data code
            Center(
              child: ElevatedButton(
                child: const Text('Get Data'),
                onPressed: () {
                  getData();
                },
              ),
            ),
          ],
        )));
  }
}
