import 'package:fedcampus/models/datahandler/ios_health_data_handler.dart';
import 'package:fedcampus/pigeon/data_extensions.dart';
import 'package:flutter/material.dart';

class IOSDataPage extends StatefulWidget {
  const IOSDataPage({super.key});

  @override
  State<IOSDataPage> createState() => _IOSDataPageState();
}

class _IOSDataPageState extends State<IOSDataPage> {
  var _date = DataExtension.dateTimeToInt(DateTime.now()).toString();

  var _text = "";

  var dataValue = {
    "step": 0.0,
    "distance": 0.0,
    "calorie": 0.0,
    "rest_heart_rate": 0.0,
    "height": 0.0,
    "sleep_time": 0.0,
    "weight": 0.0,
    "heart_rate": 0.0,
  };

  Future<void> getData(DateTime time) async {
    IOSHealth f = IOSHealth();

    var now = time;
    var end = time.add(const Duration(days: 1));
    var midnight = DateTime(now.year, now.month, now.day);
    for (var entry in dataValue.entries) {
      var data =
          await f.getData(entry: entry.key, startTime: midnight, endTime: end);

      setState(() {
        dataValue.update(entry.key, (value) => data.value);
      });
    }

    var res = await f.getIOSDayDataList();
    _text = "";
    if (res.isEmpty) {
      return;
    }
    for (var i in res) {
      _text = "$_text\n${i!.date.toString()}\n${i.value.toString()}";
    }
    setState(() {
      _text = _text;
    });
  }

  @override
  void initState() {
    super.initState();
    // get data
    getData(DateTime.now());
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
                getData(DataExtension.intToDateTime(int.parse(_date)));
              },
            ),
            Text(dataValue.toString()),
            const Text("-----"),
            Text(_text)
          ],
        )));
  }
}
