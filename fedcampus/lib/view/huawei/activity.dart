import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fedcampus/pigeons/datawrapper.dart';

import 'package:fedcampus/utility/http_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utility/log.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var _date = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  final _now = (DateTime.now().year * 10000 +
          DateTime.now().month * 100 +
          DateTime.now().day)
      .toString();

  var ifSent = false;

  final dataList = [
    "step_time",
    "distance",
    "calorie",
    "intensity",
    "stress",
    "step",
    "sleep_efficiency",
  ];

  var _log = "";

  @override
  void initState() {
    super.initState();
    _getActivityData();
  }

  void _getActivityData() async {
    // get data and send to the server
    final dataNumber = int.parse(_date);

    late dynamic bodyJson;
    if (_date == _now) {
      try {
        final data = await DataWrapper.getDataList(dataList, dataNumber);
        bodyJson = jsonDecode(jsonEncode(data));
        // HTTPClient.post(HTTPClient.fedAnalysis, <String,String>{}, body)
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
        }
        return;
      }
    } else {
      bodyJson = List.empty(growable: true);
    }

    bodyJson.add({"time": dataNumber});

    http.Response response = await HTTPClient.post(
        HTTPClient.fedAnalysis, <String, String>{}, jsonEncode(bodyJson));

    if (response.statusCode == 200) {
      // show the data
      final responseJson = jsonDecode(response.body);
      print(ifSent);
      setState(() {
        _log = dataNumber.toString() + "\n";
        jsonDecode(response.body).forEach((index, value) {
          _log += ("$index - $value \n");
        });
      });

      if (_date == _now) {
        return;
      }

      // check if there is data missing
      List<String> dataMissing = List.empty(growable: true);

      dataList.forEach((element) {
        if (responseJson[element] == null) {
          dataMissing.add(element);
        }
      });

      if (dataList.isEmpty) {
        return;
      }

      try {
        final data = await DataWrapper.getDataList(dataMissing, dataNumber);
        bodyJson = jsonDecode(jsonEncode(data));

        print(bodyJson);
        // HTTPClient.post(HTTPClient.fedAnalysis, <String,String>{}, body)
      } on PlatformException catch (error) {
        if (error.message == "java.lang.SecurityException: 50005") {
          logger.d("not authenticated");
        } else if (error.message == "java.lang.SecurityException: 50030") {
          logger.d("Internet connection Issue");
        }
        return;
      }

      List<http.Response> responseArr = await Future.wait([
        HTTPClient.post(
            HTTPClient.data, <String, String>{}, jsonEncode(bodyJson)),
        // TODO: Data DP Algorithm!!!
        HTTPClient.post(
            HTTPClient.dataDP, <String, String>{}, jsonEncode(bodyJson))
      ]);

      logger.i(
          "Data Status Code ${responseArr[0].statusCode} : ${jsonEncode(bodyJson)}");
      logger.i(
          "Data DP Status Code ${responseArr[1].statusCode} : ${jsonEncode(bodyJson)}");

      if (responseArr[0].statusCode == 200) {
        if (ifSent) {
          return;
        }
        ifSent = true;
        _getActivityData();
      } else {
        logger.d("error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Text("activity page"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                initialValue: _date,
                onChanged: (value) => {_date = value},
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Date',
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Get Data'),
              onPressed: () {
                _getActivityData();
              },
            ),
            Text(_log),
          ],
        )));
  }
}
