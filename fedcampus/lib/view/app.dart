import 'package:fedcampus/utility/platform_channel.dart';
import 'package:fedcampus/utility/api.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _MyAppState();
}

class _MyAppState extends State<TrainPage> {
  String _platformVersion = 'Unknown';
  final _channel = PlatformChannel();
  final fedAPI = FedAPI();
  var canConnect = true;
  var canTrain = false;
  var startFresh = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _channel.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      appendLog('Running on: $_platformVersion.');
    });

    const EventChannel('fed_kit_flutter_events')
        .receiveBroadcastStream()
        .listen((event) {
      appendLog('$event');
    });
  }

  late int partitionId;
  late Uri host;
  late int backendPort;

  final scrollController = ScrollController();
  final clientPartitionIdController = TextEditingController();
  final flServerIPController = TextEditingController();
  final flServerPortController = TextEditingController();

  final logs = [const Text('Logs will be shown here.')];

  appendLog(String message) {
    logger.d('appendLog: $message');
    setState(() {
      logs.add(Text(message));
    });
  }

  connect() async {
    try {
      partitionId = int.parse(clientPartitionIdController.text);
    } catch (e) {
      return appendLog('Invalid client partition id!');
    }
    try {
      host = Uri.parse('http://${flServerIPController.text}');
      if (!host.hasEmptyPath || host.host.isEmpty || host.hasPort) {
        throw Exception();
      }
    } catch (e) {
      return appendLog('Invalid backend server host!');
    }
    try {
      backendPort = int.parse(flServerPortController.text);
    } catch (e) {
      return appendLog('Invalid backend server port!');
    }

    bool canConnectLocal;
    bool canTrainLocal;
    List<String> logsLocal;
    (canConnectLocal, canTrainLocal, logsLocal) = switch (
        await fedAPI.connectAPI(partitionId, host, backendPort, startFresh)) {
      (bool b1, bool b2, List<String> i) => (b1, b2, i),
      final v => throw Exception('$v did not match'),
    };

    setState(() {
      canConnect = canConnectLocal;
      canTrain = canTrainLocal;

      for (String debugMessage in logsLocal) {
        logs.add(Text(debugMessage));
      }
      fedAPI.clearLog();
    });
  }

  train() async {
    setState(() {
      canTrain = false;
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
      canTrain = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      // input,
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
          Checkbox(
              value: startFresh,
              onChanged: (checked) {
                setState(() => startFresh = checked!);
              }),
          const Text('Start Fresh')
        ],
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: canConnect ? connect : null,
          child: const Text('Connect'),
        ),
        ElevatedButton(
          onPressed: canTrain ? train : null,
          child: const Text('Train'),
        ),
      ]),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
      Expanded(
        child: ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.only(
              top: 16.0, bottom: 32.0, left: 12.0, right: 12.0),
          itemCount: logs.length,
          itemBuilder: (context, index) => logs[logs.length - index - 1],
        ),
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FedCampus'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    });
  }
}
