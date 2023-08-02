import 'package:fedcampus/view/home.dart';
import 'package:flutter/material.dart';

void main() {
  //make sure you use a context that contains a Navigator instance as parent.
  //https://stackoverflow.com/a/51292613
  runApp(MaterialApp(
    title: 'Fedcampus Flutter',
    theme: ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 229, 85, 85),
          primary: Colors.black,
          primaryContainer: const Color.fromARGB(255, 229, 85, 85),
          secondary: const Color.fromARGB(255, 217, 217, 217),
          tertiary: const Color.fromARGB(102, 0, 0, 0),
          shadow: const Color.fromARGB(38, 229, 85, 85),
          outline: const Color.fromARGB(25, 0, 0, 0),
          surfaceTint: const Color.fromARGB(255, 206, 229, 108),
          tertiaryContainer: const Color.fromARGB(225, 131, 139, 217)),
    ),
    home: const HomeRoute(),
  ));
}
