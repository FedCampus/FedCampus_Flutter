import 'package:fedcampus/models/health.dart';
import 'package:fedcampus/models/health_factory.dart';
import 'package:fedcampus/view/activity.dart';
import 'package:fedcampus/view/me.dart';
import 'package:fedcampus/models/user_api.dart';
import 'package:flutter/material.dart';
import 'health.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;
  HealthFactory healthFactory = HealthFactory();
  late final FedHealthData healthDataHandler;
  final List<Widget> _widgetOptions = <Widget>[
    const Health(),
    const Activity(),
    const Me()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detectFirstTimeLogin();
    });
  }

  Color getAppBarColor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return Theme.of(context).colorScheme.primaryContainer;
      case 1:
        return Theme.of(context).colorScheme.secondaryContainer;
      case 2:
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void detectFirstTimeLogin() async {
    String? serviceProvider = userApi.prefs.getString("service_provider");
    if (serviceProvider == null) {
      if (mounted) {
        showDialog<bool>(
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
                          onPressed: () => userApi.prefs
                              .setString("service_provider", "huawei"),
                          child: const Text("Huawei Health")),
                      TextButton(
                          onPressed: () => userApi.prefs
                              .setString("service_provider", "google"),
                          child: const Text("Google Fit"))
                    ],
                  )),
              // actions: <Widget>[
              //   TextButton(
              //     child: const Text("Confirm"),
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //       widget.onDateChange(_date);
              //     },
              //   ),
              // ],
            );
          },
        );
      }
    } else {
      userApi.healthDataHandler = healthFactory.creatHealthDataHandler(serviceProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    TextStyle textStyle = TextStyle(
      fontSize: 13 * pixel,
      fontFamily: 'Noto Sans',
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50 * pixel,
        backgroundColor: getAppBarColor(_selectedIndex, context),
        centerTitle: true,
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      // https://stackoverflow.com/a/55174433
      bottomNavigationBar: SizedBox(
        height: 65 * pixel,
        child: BottomNavigationBar(
          unselectedLabelStyle: textStyle,
          selectedLabelStyle: textStyle,
          // https://stackoverflow.com/a/57126622
          items: const [
            BottomNavigationBarItem(
              label: 'Health',
              icon: NavIcon(
                imagePath: 'assets/images/health_nav_icon.png',
                color: Colors.grey,
              ),
              activeIcon:
                  NavIcon(imagePath: 'assets/images/health_nav_icon.png'),
            ),
            BottomNavigationBarItem(
              label: 'Activity',
              icon: NavIcon(
                imagePath: 'assets/images/activity_nav_icon.png',
                color: Colors.grey,
              ),
              activeIcon:
                  NavIcon(imagePath: 'assets/images/activity_nav_icon.png'),
            ),
            BottomNavigationBarItem(
              label: 'Me',
              icon: NavIcon(
                imagePath: 'assets/images/me_nav_icon.png',
                color: Colors.grey,
              ),
              activeIcon: NavIcon(imagePath: 'assets/images/me_nav_icon.png'),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (i) => _onItemTapped(i),
          selectedItemColor: getAppBarColor(_selectedIndex, context),
        ),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  const NavIcon({
    super.key,
    required this.imagePath,
    this.color,
  });

  final String imagePath;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return SizedBox(
      width: 32 * pixel,
      height: 32 * pixel,
      child: Image.asset(
        imagePath,
        color: color,
        fit: BoxFit.contain,
      ),
    );
  }
}
