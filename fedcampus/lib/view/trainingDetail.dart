import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TrainingDetail extends StatefulWidget {
  const TrainingDetail({super.key});

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
    return File('$path/log');
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
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50 * pixel,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        centerTitle: true,
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 200,
            margin: const EdgeInsets.all(15.0),
            // adding padding

            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              // adding borders around the widget
              border: Border.all(
                color: Colors.blueAccent,
                width: 5.0,
              ),
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  contents,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
