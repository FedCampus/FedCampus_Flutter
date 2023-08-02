import 'package:fedcampus/view/train_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  final methodChannel = const MethodChannel('fed_kit_flutter');

  getHuaweiAuthenticate() async {
    String s;
    try {
      s = await methodChannel.invokeMethod<String>("huawei_authenticate") ??
          "not good";
    } on PlatformException catch (e) {
      print(e);
      print(11111);
      s = "shiting";
    }
    print(s);
  }

  @override
  build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Center(
          child: Column(
            children: [
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
              Center(
                child: ElevatedButton(
                  child: const Text('Huawei Authenticate'),
                  onPressed: () {
                    getHuaweiAuthenticate();
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
