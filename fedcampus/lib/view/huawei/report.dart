import 'package:flutter/material.dart';

import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/pigeons/messages.g.dart';

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
      getDataList(host, "sleep_efficiency", date);
      getDataList(host, "step_time", date);
    } on Exception catch (e) {
      logger.e(e);
      return;
    }
  }

  void getDataList(DataApi host, String name, int time) async {
    var data = await host.getData(name, time, time);

    setState(() {
      try {
        _log += "${data[0]!.name} ${data[0]!.value.toString()} \n";
      } on RangeError catch (error) {
        _log += "$name 0\n";
      }
    });
  }

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
}
