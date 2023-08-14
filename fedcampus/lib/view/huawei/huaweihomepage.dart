import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fedcampus/view/huawei/report.dart';
import 'package:fedcampus/view/huawei/mine.dart';
import 'package:fedcampus/view/huawei/activity.dart';

class HuaweiHome extends StatefulWidget {
  const HuaweiHome({super.key});

  @override
  State<HuaweiHome> createState() => _HuaweiHomeState();
}

class _HuaweiHomeState extends State<HuaweiHome> {
  var _selectedIndex = 0;

  late PageController _pageController;

  final List<Widget> _pages = [
    const ReportPage(),
    const ActivityPage(),
    const MinePage()
  ];

  final methodChannel = const MethodChannel('fed_kit_flutter');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FedKit'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(
            () {
              _selectedIndex = index;
              _pageController.jumpToPage(_selectedIndex);
            },
          );
        },
      ),
    );
  }
}
