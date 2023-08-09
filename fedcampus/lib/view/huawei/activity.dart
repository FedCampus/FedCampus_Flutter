import 'dart:convert';

import 'package:fedcampus/pigeons/datawrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utility/log.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final _now = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  @override
  void initState() {
    super.initState();
    _getActivityData();
  }

  void _getActivityData() async {
    if (_date == _now) {
      // get data and send to the server
      final dataNumber = int.parse(_date);
      // final host = DataApi();
      final dataList = [
        "step_time",
        "distance",
        "calorie",
        "intensity",
        "stress"
      ];
      try {
        final data = await DataWrapper.getDataList(dataList, dataNumber);
        logger.i(jsonEncode(data));
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Text("activity page"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                initialValue: _date,
                onChanged: (value) => {_date = value},
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Date',
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Get Data'),
              onPressed: () {
                _getActivityData();
              },
            ),
          ],
        )));
  }
}
