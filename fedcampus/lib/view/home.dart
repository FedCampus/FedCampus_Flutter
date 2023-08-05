import 'package:fedcampus/view/huawei/huaweihomepage.dart';
import 'package:fedcampus/view/train_app.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.changeThemeCallback});
  final void Function(ThemeMode) changeThemeCallback;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final List<bool> _selectedThemes = [true, false];

  void toggleTheme(int i) {
    setState(() {
      switch (i) {
        case 0:
          widget.changeThemeCallback(ThemeMode.light);
          _selectedThemes[0] = true;
          _selectedThemes[1] = false;
        case 1:
          widget.changeThemeCallback(ThemeMode.dark);
          _selectedThemes[0] = false;
          _selectedThemes[1] = true;
        default:
          widget.changeThemeCallback(ThemeMode.light);
          _selectedThemes[0] = true;
          _selectedThemes[1] = false;
      }
    });
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
                isSelected: _selectedThemes,
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
