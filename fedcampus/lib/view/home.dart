import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/view/app_usage_stats_test.dart';
import 'package:fedcampus/view/googletest.dart';
import 'package:fedcampus/view/ios/ios_data.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:fedcampus/view/splash.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});
  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
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
              MaterialPageRoute(builder: (context) {
                String? splashScreenPolicy =
                    userApi.prefs.getString("slpash_screen");
                switch (splashScreenPolicy) {
                  case "always":
                    return const Splash();
                  case "is_logged_in":
                    return userApi.prefs.getBool("login") == null
                        ? const Splash()
                        : const BottomNavigator();
                  case "never":
                    return const BottomNavigator();
                  default:
                    return const Splash();
                }
              }),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoogleTestPage()),
            ),
            child: const Text('Test Google Fit Getting Data'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const IOSDataPage()),
            ),
            child: const Text('ios'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppUsageStatsTest()),
            ),
            child: const Text('Open App Usage Stats Test Page'),
          ),
          Text('current language: ${appState.locale}'),
        ]),
      ),
    );
  }
}
