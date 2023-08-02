import 'package:flutter/material.dart';
import 'health.dart';

class TrueHome extends StatefulWidget {
  const TrueHome({super.key});

  @override
  State<TrueHome> createState() => _TrueHomeState();
}

class _TrueHomeState extends State<TrueHome> {
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
          'assets/page-1/images/-Q8H.png',
          height: 35,
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/noun-heart-59-0272-2-1-tLh.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/noun-heart-590-2272-1-Mvh.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/edge-intelligence-logo-1-guF.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (i) => _onItemTapped(i),
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}
