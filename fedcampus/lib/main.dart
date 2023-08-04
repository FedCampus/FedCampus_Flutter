import 'package:fedcampus/view/home.dart';
import 'package:flutter/material.dart';

void main() {
  //make sure you use a context that contains a Navigator instance as parent.
  //https://stackoverflow.com/a/51292613
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ThemeMode _themeMode = ThemeMode.system;
  // TODO: default to light in development; should be set to systemwide preference in release
  ThemeMode _themeMode = ThemeMode.light;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fedcampus Flutter',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 229, 85, 85),
          primary: Colors.black,
          primaryContainer: const Color.fromARGB(255, 229, 85, 85),
          secondary: const Color.fromARGB(255, 217, 217, 217),
          secondaryContainer: const Color.fromARGB(255, 206, 229, 109),
          tertiary: const Color.fromARGB(102, 0, 0, 0),
          tertiaryContainer: const Color.fromARGB(255, 174, 197, 242),
          surfaceTint: const Color.fromARGB(255, 249, 255, 231),
          shadow: const Color.fromARGB(38, 229, 85, 85),
          outline: const Color.fromARGB(25, 0, 0, 0),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: _themeMode,
      home: HomeRoute(changeThemeCallback: changeTheme),
    );
  }
}
