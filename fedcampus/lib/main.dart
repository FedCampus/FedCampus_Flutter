import 'package:fedcampus/view/home.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() {
  //make sure you use a context that contains a Navigator instance as parent.
  //https://stackoverflow.com/a/51292613
  runApp(const MaterialApp(
    title: 'Fedcampus Flutter',
    home: HomeRoute(),
  ));
}
