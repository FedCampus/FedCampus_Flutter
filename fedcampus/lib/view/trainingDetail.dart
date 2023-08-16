import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TrainingDetail extends StatefulWidget {
  @override
  State<TrainingDetail> createState() => _TrainingDetailState();
}

class _TrainingDetailState extends State<TrainingDetail> {
  String contents = "";

  @override
  initState() {
    super.initState();
    getFileOutput();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/log.txt');
  }

  void getFileOutput() async {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    setState(() {
      this.contents = contents;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return Center(
        child: Column(
      children: [
        Text(contents),
      ],
    ));
  }
}
