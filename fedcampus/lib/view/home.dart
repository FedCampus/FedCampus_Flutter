import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fedcampus/view/report.dart';
import 'package:fedcampus/view/mine.dart';
import 'package:fedcampus/view/activity.dart';
import 'package:fedcampus/view/train_app.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  var _selectedIndex = 0;

  final methodChannel = const MethodChannel('fed_kit_flutter');

  getHuaweiAuthenticate() async {
    String s;
    try {
      s = await methodChannel.invokeMethod<String>("huawei_authenticate") ??
          "not good";
    } on PlatformException catch (e) {
      print(e);
      s = "shiting";
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = ReportPage();
        break;
      case 1:
        page = ActivityPage();
        break;
      case 2:
        page = MinePage();
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
            // Center(
            //   child: ElevatedButton(
            //     child: const Text('Open training page'),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => const TrainApp()),
            //       );
            //     },
            //   ),
            // ),
            // // test huawei authentication code
            // Center(
            //   child: ElevatedButton(
            //     child: const Text('Huawei Authenticate'),
            //     onPressed: () {
            //       getHuaweiAuthenticate();
            //     },
            //   ),
            // ),
            // cancel authentication code
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
