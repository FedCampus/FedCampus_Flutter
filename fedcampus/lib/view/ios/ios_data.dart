import 'package:flutter/material.dart';
import 'package:health/health.dart';

class IOSDataPage extends StatefulWidget {
  const IOSDataPage({super.key});

  @override
  State<IOSDataPage> createState() => _IOSDataPageState();
}

class _IOSDataPageState extends State<IOSDataPage> {
  var dataValue = {
    "step": 0,
    "distance": 0,
    "calorie": 0,
    "static heart rate": 0,
    "height": 0,
    "sleep_time": 0,
    "weight": 0,
    "heart_rate": 0
  };

  getData() async {
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: false);

    var types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.HEART_RATE,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.WALKING_HEART_RATE,
      HealthDataType.EXERCISE_TIME,
      HealthDataType.SLEEP_IN_BED,
    ];

    bool requested = await health.requestAuthorization(types);

    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day - 1);

    var result = await health.getHealthDataFromTypes(midnight, now, types);
    for (var i in result) {
      print(i);
    }
  }

  @override
  void initState() {
    super.initState();
    // get data

    getData();
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
                initialValue: "20230909",
                // onChanged: (value) => {= value},
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Date',
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Get Data'),
              onPressed: () {},
            ),
            Text(dataValue.toString()),
          ],
        )));
  }
}
