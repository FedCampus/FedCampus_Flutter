import 'package:fedcampus/pigeons/huaweiauth.g.dart';
import 'package:flutter/material.dart';

import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/pigeons/messages.g.dart';
import 'package:flutter/services.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  var _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  var _log = "";

  var isAuth = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    // throw UnimplementedError();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Text("report page"),
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
                _getData();
              },
            ),
            Text(_log)
          ],
        )));
  }

  void _getData() {
    final host = DataApi();

    int date = 0;
    try {
      date = int.parse(_date);
      setState(() {
        _log = "$_date \n";
      });

      getDataList(host, "step", date);
      getDataList(host, "calorie", date);
      getDataList(host, "distance", date);
      getDataList(host, "stress", date);
      getDataList(host, "rest_heart_rate", date);
      getDataList(host, "intensity", date);
      getDataList(host, "exercise_heart_rate", date);
      getDataList(host, "step_time", date);
      getDataList(host, "sleep_efficiency", date);
    } on Exception catch (e) {
      logger.e(e);
      return;
    }
  }

  void authAndGetData() async {
    if (isAuth) {
      return;
    }
    isAuth = true;
    HuaweiAuthApi host = HuaweiAuthApi();
    try {
      bool ifAuth = await host.getAuthenticate();
      isAuth = false;
      _getData();
    } on PlatformException catch (error) {
      logger.e(error);
    }
  }

  void getDataList(DataApi host, String name, int time) async {
    List<Data?> data;

    try {
      data = await host.getData(name, time, time);
    } on PlatformException catch (error) {
      if (error.message == "java.lang.SecurityException: 50005") {
        logger.d("not authenticated");

        // redirect the user to the authenticate page
        authAndGetData();
      } else {
        logger.e(error.toString());
      }
      logger.e("catching error $error");
      return;
    }

    setState(() {
      try {
        _log += "${data[0]!.name} ${data[0]!.value.toString()} \n";
      } on RangeError {
        _log += "$name 0\n";
      }
    });
  }
}
