import 'package:fedcampus/utility/train_channel.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrainApp extends StatefulWidget {
  const TrainApp({super.key});

  @override
  createState() => _TrainAppState();
}

class _TrainAppState extends State<TrainApp> {
  final _channel = TrainChannel();
  final _scrollController = ScrollController();
  final _clientPartitionIdController = TextEditingController();
  final _flServerIPController = TextEditingController();
  final _flServerPortController = TextEditingController();
  final _logs = [const Text('Logs will be shown here.')];
  var _platformVersion = 'Unknown';
  var _canConnect = true;
  var _canTrain = false;
  var _startFresh = false;

  @override
  initState() {
    super.initState();
    initPlatformState();
    const EventChannel('fed_kit_flutter_events')
        .receiveBroadcastStream()
        .listen((event) {
      appendLog('$event');
    });
  }

  initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _channel.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    setState(() {
      _platformVersion = platformVersion;
      appendLog('Running on: $_platformVersion.');
    });
  }

  appendLog(String message) {
    logger.d('appendLog: $message');
    setState(() {
      _logs.add(Text(message));
    });
  }

  @override
  build(BuildContext context) => LayoutBuilder(builder: buildLayout);

  connect() async {
    int partitionId;
    try {
      partitionId = int.parse(_clientPartitionIdController.text);
    } catch (e) {
      return appendLog('Invalid client partition id!');
    }
    Uri host;
    try {
      host = Uri.parse('http://${_flServerIPController.text}');
      if (!host.hasEmptyPath || host.host.isEmpty || host.hasPort) {
        throw Exception();
      }
    } catch (e) {
      return appendLog('Invalid backend server host!');
    }
    int backendPort;
    try {
      backendPort = int.parse(_flServerPortController.text);
    } catch (e) {
      return appendLog('Invalid backend server port!');
    }
    Uri backendUrl = host.replace(port: backendPort);

    _canConnect = false;
    appendLog(
        'Connecting with Partition ID: $partitionId, Server IP: $host, Port: $backendPort');

    try {
      final serverPort = await _channel.connect(partitionId, host, backendUrl,
          startFresh: _startFresh);
      _canTrain = true;
      return appendLog(
          'Connected to Flower server on port $serverPort and loaded data set.');
    } on PlatformException catch (error, stacktrace) {
      appendLog('Request failed: ${error.message}.');
      logger.e('$error\n$stacktrace.');
    } catch (error, stacktrace) {
      appendLog('Request failed: $error.');
      logger.e(stacktrace);
    }

    setState(() {
      _canConnect = true;
    });
  }

  train() async {
    setState(() {
      _canTrain = false;
    });
    try {
      await _channel.train();
      return appendLog('Started training.');
    } on PlatformException catch (error, stacktrace) {
      appendLog('Training failed: ${error.message}.');
      logger.e('$error\n$stacktrace.');
    } catch (error, stacktrace) {
      appendLog('Failed to start training: $error.');
      logger.e(stacktrace);
    }
    setState(() {
      _canTrain = true;
    });
  }

  Widget buildLayout(BuildContext _, BoxConstraints __) => Scaffold(
        appBar: AppBar(
          title: const Text('FedCampus'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputView(
                clientPartitionIdController: _clientPartitionIdController,
                flServerIPController: _flServerIPController,
                flServerPortController: _flServerPortController,
                startFresh: _startFresh,
                callback: (checked) {
                  setState(() => _startFresh = checked!);
                }),
            ButtonsView(
                canConnect: _canConnect,
                canTrain: _canTrain,
                connectCallback: connect,
                trainCallback: train),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 32.0, left: 12.0, right: 12.0),
                itemCount: _logs.length,
                itemBuilder: (context, index) =>
                    _logs[_logs.length - index - 1],
              ),
            ),
          ],
        ),
      );
}

class ButtonsView extends StatelessWidget {
  const ButtonsView(
      {super.key,
      required this.canConnect,
      required this.canTrain,
      required this.connectCallback,
      required this.trainCallback});
  final bool canConnect;
  final bool canTrain;
  final Function() connectCallback;
  final Function() trainCallback;

  @override
  build(BuildContext context) => Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: canConnect ? connectCallback : null,
              child: const Text('Connect'),
            ),
            ElevatedButton(
              onPressed: canTrain ? trainCallback : null,
              child: const Text('Train'),
            ),
          ]),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(context);
            },
            child: const Text('Go back!'),
          ),
        ],
      );
}

class InputView extends StatelessWidget {
  const InputView(
      {super.key,
      required this.clientPartitionIdController,
      required this.flServerIPController,
      required this.flServerPortController,
      required this.startFresh,
      required this.callback});

  final TextEditingController clientPartitionIdController;
  final TextEditingController flServerIPController;
  final TextEditingController flServerPortController;
  final bool startFresh;
  final Function(bool?) callback;

  @override
  build(BuildContext context) => Column(
        children: [
          TextFormField(
            controller: clientPartitionIdController,
            decoration: const InputDecoration(
              labelText: 'Client Partition ID (1-10)',
              filled: true,
            ),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: flServerIPController,
            decoration: const InputDecoration(
              labelText: 'Backend Server Host',
              filled: true,
            ),
            keyboardType: TextInputType.text,
          ),
          TextFormField(
            controller: flServerPortController,
            decoration: const InputDecoration(
              labelText: 'Backend Server Port',
              filled: true,
            ),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Checkbox(value: startFresh, onChanged: callback),
              const Text('Start Fresh')
            ],
          ),
        ],
      );
}
