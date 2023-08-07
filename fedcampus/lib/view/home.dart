import 'package:fedcampus/main.dart';
import 'package:fedcampus/view/huawei/huaweihomepage.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.changeThemeCallback});
  final void Function(ThemeMode) changeThemeCallback;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/title.png',
          height: 35,
        ),
      ),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            child: const Text('Open training page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainApp()),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Open FedCampus App'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavigator()),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Open Huawei Test Page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HuaweiHome()),
              );
            },
          ),
        ]),
      ),
    );
  }
}
