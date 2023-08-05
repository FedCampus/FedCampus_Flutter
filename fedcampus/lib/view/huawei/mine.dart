import 'package:fedcampus/pigeons/messages.g.dart';
import 'package:fedcampus/pigeons/huaweiauth.g.dart';

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

  var value = "abcdefg";

  getHuaweiAuthenticate() async {
    final host = HuaweiAuthApi();
    bool ifAuth = await host.getAuthenticate();
    print(ifAuth);
  }

  getData() async {
    final host = DataApi();
    setState(() {
      value = "";
    });
    getDataList(host, "step", 20230802);
    getDataList(host, "calorie", 20230803);
    getDataList(host, "distance", 20230803);
    getDataList(host, "stress", 20230803);
    getDataList(host, "rest_heart_rate", 20230803);
    getDataList(host, "exercise_heart_rate", 20230803);
  }

  getDataList(DataApi host, String name, int time) async {
    var data = await host.getData(name, time, time);

    print(data[0]!.name + " " + data[0]!.value.toString());
    setState(() {
      value += (data[0]!.name + " " + data[0]!.value.toString() + '\n');
    });
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
            Text(value)
          ],
        )));
  }
}
