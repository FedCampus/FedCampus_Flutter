import 'package:fedcampus/view/huawei/huaweihomepage.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key, required this.changeThemeCallback});

  final void Function(ThemeMode) changeThemeCallback;

  void toggleTheme(int i) {
    switch (i) {
      case 0:
        changeThemeCallback(ThemeMode.light);
      case 1:
        changeThemeCallback(ThemeMode.dark);
      default:
        changeThemeCallback(ThemeMode.light);
    }
  }

  @override
  build(BuildContext context) => Scaffold(
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
              child: const Text('Open Health page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavigator()),
                );
              },
            ),
            ToggleButtons(
                isSelected: const [true, false],
                onPressed: (i) => toggleTheme(i),
                children: const [Text('light'), Text('dark')]),
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
