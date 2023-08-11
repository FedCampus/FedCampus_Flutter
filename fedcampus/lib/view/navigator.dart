import 'package:fedcampus/view/activity.dart';
import 'package:fedcampus/view/me.dart';
import 'package:flutter/material.dart';
import 'health.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Health(),
    const Activity(),
    const Me()
  ];

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

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundColor: getAppBarColor(_selectedIndex, context),
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: SizedBox(
        height: 75 * pixel,
        child: BottomNavigationBar(
          // https://stackoverflow.com/a/57126622
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          items: [
            BottomNavigationBarItem(
              label: 'Health',
              icon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/health_nav_icon_inactive.png',
                  fit: BoxFit.contain,
                ),
              ),
              activeIcon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/health_nav_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: 'Activity',
              icon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/activity_nav_icon_inactive.png',
                  fit: BoxFit.contain,
                ),
              ),
              activeIcon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/activity_nav_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: 'Me',
              icon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/me_nav_icon_inactive.png',
                  fit: BoxFit.contain,
                ),
              ),
              activeIcon: SizedBox(
                width: 40 * pixel,
                height: 40 * pixel,
                child: Image.asset(
                  'assets/images/me_nav_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (i) => _onItemTapped(i),
          selectedItemColor: Colors.amber[800],
        ),
      ),
    );
  }
}
