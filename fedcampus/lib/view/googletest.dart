import 'package:flutter/material.dart';

import '../models/datahandler/google_health_data_handler.dart';
import '../models/datahandler/health_handler.dart';
import '../pigeon/generated.g.dart';

class GoogleTestPage extends StatelessWidget {
  const GoogleTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(title: 'Flutter Demo Home Page');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _log = "";

  init() async {
    FedHealthData myHealth = GoogleFit();
    DateTime now = DateTime.now();
    Data result = await myHealth.getDataInterval(
        entry: "step",
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now());
    _appendLog("steps last 24 hours: ${result.value}");
    Data result1 = await myHealth.getDataDay(
        entry: "step", date: DateTime(now.year, now.month, now.day - 1));
    _appendLog("steps yesterday: ${result1.value}");
    Data result2 = await myHealth.getDataDay(
        entry: "heart_rate", date: DateTime(now.year, now.month, now.day));
    _appendLog("avereg heart rate today: ${result2.value}");
    Data result3 = await myHealth.getDataDay(
        entry: "active_energy_burned",
        date: DateTime(now.year, now.month, now.day));
    _appendLog("active_energy_burned today: ${result3.value}");
    try {
      Data result4 = await myHealth.getDataDay(
          entry: "distance", date: DateTime(now.year, now.month, now.day + 1));
      _appendLog("distance today: ${result4.value}");
    } catch (e) {
      _appendLog("distance today: $e");
    }
    Data result5 = await myHealth.getDataDay(
        entry: "step_time", date: DateTime(now.year, now.month, now.day));
    _appendLog("step_time today: ${result5.value}");

    // Map<String, double?> dataMap = await myHealth.getDataMap(
    //     entry: [
    //       "step",
    //       "heart_rate",
    //       "active_energy_burned",
    //       "distance",
    //       "step_time"
    //     ],
    //     startTime: DateTime(now.year, now.month, now.day),
    //     endTime: DateTime(now.year, now.month, now.day + 1));
    // _appendLog(dataMap.toString());

    List<Data?> dataList = await myHealth.getDataListInterval(
        entry: [
          "step",
          "heart_rate",
          "active_energy_burned",
          "distance",
          "step_time"
        ],
        startTime: DateTime(now.year, now.month, now.day),
        endTime: DateTime(now.year, now.month, now.day + 1));
    for (var data in dataList) {
      _appendLog(data!.value.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void _appendLog(String log) {
    setState(() {
      _log += "\n$log";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _log,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _appendLog("1212"),
        tooltip: 'Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}
