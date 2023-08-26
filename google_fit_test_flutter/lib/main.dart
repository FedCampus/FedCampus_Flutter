import 'package:flutter/material.dart';
import 'package:google_fit_test_flutter/health.dart';
import 'package:google_fit_test_flutter/google_health_data_handler.dart';
import 'package:google_fit_test_flutter/log.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
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
    // myHealth.testAvailability();
    DataNew result = await myHealth.getData(
        entry: "step",
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now());
    logger.d(result.encode());
    _appendLog("steps last 24 hours: ${result.value}");
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
