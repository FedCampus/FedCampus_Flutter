import 'package:fedcampus/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() {
  //make sure you use a context that contains a Navigator instance as parent.
  //https://stackoverflow.com/a/51292613
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My app',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 6, 102, 255)),
        ),
        home: const HomeRoute(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}
