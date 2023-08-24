import 'package:flutter/material.dart';
import 'package:google_fit_test_flutter/health.dart';
import 'package:google_fit_test_flutter/log.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

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
    testHealth();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void _appendLog(String log) {
    setState(() {
      _log += "\n$log";
    });
  }

  testHealth() async {
    // Beacuse this is labled as a dangerous protection level, the permission system will not grant it automaticlly and it requires the user's action. You can prompt the user for it using the permission_handler plugin. Follow the plugin setup instructions and add the following line before requsting the data:
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

    // define the types to get
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP
      // HealthDataType.BLOOD_GLUCOSE,
    ];

    // requesting access to the data types before reading them
    bool requested = await health.requestAuthorization(types);

    _appendLog("requested: $requested");

    var now = DateTime.now();

    // fetch health data from the last 24 hours
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(Duration(days: 1)), now, types);

    _appendLog("healthData: $healthData");
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
