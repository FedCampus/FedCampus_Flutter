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

  final methodChannel = const MethodChannel('fed_kit_flutter');

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = const ReportPage();
        break;
      case 1:
        page = const ActivityPage();
        break;
      case 2:
        page = const MinePage();
        break;
      default:
        throw UnimplementedError("no widget for $_selectedIndex");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FedKit'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
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
          // switch (index) {
          //   case 0:
          //     // only scroll to top when current index is selected.
          //     if (_selectedIndex == index) {
          //       // _homeController.animateTo(
          //       //   0.0,
          //       //   duration: const Duration(milliseconds: 500),
          //       //   curve: Curves.easeOut,
          //       // );
          //     }
          //   case 1:
          //   // showModal(context);
          // }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }
}
