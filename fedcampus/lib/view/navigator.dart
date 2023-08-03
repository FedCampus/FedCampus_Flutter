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
    const Healthy(),
    const Text('2'),
    const Text('3')
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: TopBar(fem: fem),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Image.asset(
          'assets/images/title.png',
          height: 35,
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: 'Health',
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/health_nav_icon_inactive.png',
                fit: BoxFit.contain,
              ),
            ),
            activeIcon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/health_nav_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Activity',
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/activity_nav_icon_inactive.png',
                fit: BoxFit.contain,
              ),
            ),
            activeIcon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/activity_nav_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Me',
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/me_nav_icon_inactive.png',
                fit: BoxFit.contain,
              ),
            ),
            activeIcon: SizedBox(
              width: 40,
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
    );
  }
}
