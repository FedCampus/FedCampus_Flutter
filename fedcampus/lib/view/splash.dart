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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   detectHealthDataServiceProvider().then((value) => Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => const BottomNavigator()),
    //       ));
    // });
  }

  void detectFirstTimeLogin() async {
    if (userApi.prefs.getBool("login") == null) {
      // jump to login page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    }
  }

  void init() {
    serviceProvider = userApi.prefs.getString("service_provider") ?? "huawei";
    userApi.healthDataHandler =
        healthFactory.creatHealthDataHandler(serviceProvider);
  }

  toggleTheme(bool b) async {
    userApi.prefs.setBool('isDarkModeOn', b);
    Provider.of<MyAppState>(context, listen: false).toggleTheme(b);
  }

  Future<void> detectHealthDataServiceProvider() async {
    String? serviceProvider = userApi.prefs.getString("service_provider");
    // TODO: choose manually everytime for now
    serviceProvider = null;
    if (serviceProvider == null) {
      if (mounted) {
        await pickServiceProvider();
      }
    } else {
      userApi.healthDataHandler =
          healthFactory.creatHealthDataHandler(serviceProvider);
    }
  }

  Future<void> pickServiceProvider() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const FirstDialog(),
        );
      },
    );
    if (mounted) {
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return ChooseHealthServiceProviderDialog(
              healthFactory: healthFactory);
        },
      );
    }
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    }
  }

  Future<void> _pickServiceProvider() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        double pixel = MediaQuery.of(context).size.width / 400;
        return AlertDialog(
          title: const Text("Select a health serivice provider"),
          contentPadding:
              EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
          content: SizedBox(
              height: 271 * pixel,
              width: 300 * pixel,
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        userApi.prefs.setString("service_provider", "huawei");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Huawei Health")),
                  TextButton(
                      onPressed: () {
                        userApi.prefs.setString("service_provider", "google");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Google Fit"))
                ],
              )),
        );
      },
    );
  }

  Future<void> _chooseColorMode() async {
    await showDialog<bool>(
        context: context,
        builder: (context) {
          double pixel = MediaQuery.of(context).size.width / 400;
          return AlertDialog(
            title: const Text("Select color mode"),
            contentPadding:
                EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
            content: SizedBox(
                height: 271 * pixel,
                width: 300 * pixel,
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
                )),
          );
        });
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
                    width: 145 * pixel,
                    height: 145 * pixel,
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
            TextButton(
              onPressed: () {
                {
                  init();
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

class FirstDialog extends StatelessWidget {
  const FirstDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return AlertDialog(
      title: const Text("Hello"),
      contentPadding:
          EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
      content: SizedBox(
          height: 271 * pixel,
          width: 300 * pixel,
          child: const Column(
            children: [Text("Let's walk through a few settings")],
          )),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Next"))
      ],
    );
  }
}

class ChooseHealthServiceProviderDialog extends StatelessWidget {
  const ChooseHealthServiceProviderDialog({
    super.key,
    required this.healthFactory,
  });

  final HealthDataHandlerFactory healthFactory;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return AlertDialog(
      title: const Text("Select a health serivice provider"),
      contentPadding:
          EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
      content: SizedBox(
          height: 271 * pixel,
          width: 300 * pixel,
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    userApi.prefs.setString("service_provider", "huawei");
                    userApi.healthDataHandler =
                        healthFactory.creatHealthDataHandler("huawei");
                    Navigator.of(context).pop();
                  },
                  child: const Text("Huawei Health")),
              TextButton(
                  onPressed: () {
                    userApi.prefs.setString("service_provider", "google");
                    userApi.healthDataHandler =
                        healthFactory.creatHealthDataHandler("google");
                    Navigator.of(context).pop();
                  },
                  child: const Text("Google Fit"))
            ],
          )),
    );
  }
}
