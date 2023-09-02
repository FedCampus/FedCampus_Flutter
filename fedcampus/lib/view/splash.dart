import 'package:fedcampus/main.dart';
import 'package:fedcampus/models/datahandler/health_factory.dart';
import 'package:fedcampus/models/user_api.dart';
import 'package:fedcampus/view/me.dart';
import 'package:fedcampus/view/me/signin.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  HealthDataHandlerFactory healthFactory = HealthDataHandlerFactory();
  String serviceProvider = "huawei";

  @override
  void initState() {
    super.initState();
  }

  void createHealthDataHandler() {
    userApi.prefs.setString("service_provider", serviceProvider);
    userApi.healthDataHandler =
        healthFactory.creatHealthDataHandler(serviceProvider);
  }

  void toggleTheme(bool b) async {
    userApi.prefs.setBool('isDarkModeOn', b);
    Provider.of<MyAppState>(context, listen: false).toggleTheme(b);
  }

  Future<void> _splashDialog({required Widget dialogContent}) async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        double pixel = MediaQuery.of(context).size.width / 400;
        return AlertDialog(
          title: const Text("Select a health serivice provider"),
          contentPadding:
              EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 13),
          content: dialogContent,
        );
      },
    );
  }

  Future<void> _pickServiceProvider() async {
    double pixel = MediaQuery.of(context).size.width / 400;
    _splashDialog(
        dialogContent: SizedBox(
      height: 110 * pixel,
      child: Column(
        children: [
          TextButton(
              onPressed: () {
                serviceProvider = "huawei";
                Navigator.of(context).pop();
              },
              child: const Text("Huawei Health")),
          TextButton(
              onPressed: () {
                serviceProvider = "google";
                Navigator.of(context).pop();
              },
              child: const Text("Google Fit"))
        ],
      ),
    ));
  }

  Future<void> _chooseColorMode() async {
    double pixel = MediaQuery.of(context).size.width / 400;
    _splashDialog(
      dialogContent: SizedBox(
        height: 110 * pixel,
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  toggleTheme(false);
                  Navigator.of(context).pop();
                },
                child: const Text("light")),
            TextButton(
                onPressed: () {
                  toggleTheme(true);
                  Navigator.of(context).pop();
                },
                child: const Text("dark"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Text("Welcome to",
                style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 30 * pixel,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                )),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Image.asset(
              'assets/images/title.png',
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              height: 60 * pixel,
            ),
            const Expanded(
              flex: 3,
              child: SizedBox(),
            ),
            ClipOval(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    width: 145 * pixel,
                    height: 145 * pixel,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                  ),
                  Image.asset(
                    'assets/images/me_nav_icon.png',
                    width: 120 * pixel,
                    height: 120 * pixel,
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 3,
              child: SizedBox(),
            ),
            const MeDivider(),
            MeText(
              text: 'Data Provider',
              callback: _pickServiceProvider,
            ),
            const MeDivider(),
            MeText(
              text: 'Color Mode',
              callback: _chooseColorMode,
            ),
            const MeDivider(),
            MeText(
              text: 'Sign in',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignIn()),
              ),
            ),
            const MeDivider(),
            TextButton(
              onPressed: () {
                {
                  createHealthDataHandler();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNavigator()),
                  );
                }
              },
              child: Text(
                'click to continue',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontSize: pixel * 18,
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: SizedBox(),
            ),
            Text(
              'Powered by DKU EdgeIntelligence',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontSize: pixel * 18,
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
