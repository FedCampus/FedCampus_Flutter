import 'package:flutter/material.dart';

import '../pigeon/generated.g.dart';
import '../utility/log.dart';
import '../../utility/calendar.dart' as calendar;

class AppUsageStatsTest extends StatefulWidget {
  const AppUsageStatsTest({
    super.key,
  });

  @override
  State<AppUsageStatsTest> createState() => _AppUsageStatsTestState();
}

class _AppUsageStatsTestState extends State<AppUsageStatsTest> {
  String _log = "";
  String _startDate = (calendar.dateTimeToInt(DateTime.now()) - 1).toString();
  String _endDate = (calendar.dateTimeToInt(DateTime.now())).toString();

  @override
  void initState() {
    super.initState();
  }

  void _appendLog(String log) {
    setState(() {
      _log += "\n$log";
    });
  }

  test() async {
    final host = AppUsageStats();
    Data? data;
    try {
      data = (await host.getData(
          "calorie", int.parse(_startDate), int.parse(_endDate)))[0]!;
      _appendLog(data.value.toString());
    } catch (e) {
      logger.e(e);
      _appendLog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("App Usage Stats Test"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    {
                      final host = AppUsageStats();
                      await host.getAuthenticate();
                    }
                  },
                  child: const Text("Open permission settings")),
              TextField(
                controller: TextEditingController()..text = _startDate,
                onChanged: (value) => {_startDate = value},
              ),
              TextField(
                controller: TextEditingController()..text = _endDate,
                onChanged: (value) => {_endDate = value},
              ),
              Text(
                _log,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => test(),
        tooltip: 'Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}
