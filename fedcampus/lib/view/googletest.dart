import 'package:flutter/material.dart';

import '../models/googlefit/google_health_data_handler.dart';
import '../models/health.dart';

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
    DataNew result = await myHealth.getData(
        entry: "step",
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now());
    _appendLog("steps last 24 hours: ${result.value}");
    DataNew result1 = await myHealth.getDataDay(
        entry: "step", date: DateTime(now.year, now.month, now.day - 1));
    _appendLog("steps yesterday: ${result1.value}");
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
