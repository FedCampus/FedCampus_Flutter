import 'package:fedcampus/main.dart';
import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/view/googletest.dart';
import 'package:fedcampus/view/huawei/huaweihomepage.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});
  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  void testHealthData() async {
    // await Provider.of<HealthDataModel>(context, listen: false).init();
    Provider.of<HealthDataModel>(context, listen: false).getData();
  }

  void testGoogleHealthData() async {
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: false);

    var types = [
      HealthDataType.STEPS,
      // HealthDataType.BASAL_ENERGY_BURNED,
    ];
    print("-----start auth--------");
    bool requested = await health.requestAuthorization(types);

    var now = DateTime.now();
    print("-----auth finished--------");

    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(Duration(days: 1)), now, types);

    print(healthData.toString());
    print("-----------------");

    var midnight = DateTime(now.year, now.month, now.day);
    int? steps = await health.getTotalStepsInInterval(midnight, now);
    print(steps);
  }

  @override
  build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
      ),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            child: const Text('Open training page'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrainApp()),
            ),
          ),
          ElevatedButton(
            child: const Text('Open FedCampus App'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavigator()),
            ),
          ),
          ElevatedButton(
            child: const Text('Open Huawei Test Page'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HuaweiHome()),
            ),
          ),
          ElevatedButton(
            onPressed: testHealthData,
            child: const Text('Test health model'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoogleTestPage()),
            ),
            child: const Text('Test Google Fit Getting Data'),
          ),
          Text('current language: ${appState.locale}'),
        ]),
      ),
    );
  }
}
