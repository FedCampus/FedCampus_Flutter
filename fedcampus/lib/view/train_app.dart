import 'package:fedcampus/utility/platform_channel.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrainApp extends StatefulWidget {
  const TrainApp({super.key});

  @override
  State<TrainApp> createState() => _TrainAppState();
}

class _TrainAppState extends State<TrainApp> {
  String _platformVersion = 'Unknown';
  final _channel = TrainChannel();
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
  final logs = [
    StatefulText(text: 'Logs will be shown here.', key: UniqueKey())
  ];

  appendLog(String message) {
    logger.d('appendLog: $message');
    setState(() {
      logs.add(StatefulText(text: message, key: UniqueKey()));
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
    Uri backendUrl;
    try {
      backendPort = int.parse(flServerPortController.text);
      backendUrl = host.replace(port: backendPort);
    } catch (e) {
      return appendLog('Invalid backend server port!');
    }

    canConnect = false;
    appendLog(
        'Connecting with Partition ID: $partitionId, Server IP: $host, Port: $backendPort');

    try {
      final serverPort = await _channel.connect(partitionId, host, backendUrl,
          startFresh: startFresh);
      canTrain = true;
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
      canConnect = true;
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
      InputView(
          clientPartitionIdController: clientPartitionIdController,
          flServerIPController: flServerIPController,
          flServerPortController: flServerPortController,
          startFresh: startFresh,
          callback: (checked) {
            setState(() => startFresh = checked!);
          }),
      ButtonsView(
          canConnect: canConnect,
          canTrain: canTrain,
          connectCallback: connect,
          trainCallback: train),
      LogView(scrollController: scrollController, logs: logs),
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

class StatefulText extends StatefulWidget {
  //when manupulating a collection of stateful widgets, if you are going to add,
  //remove, or reorder the widgets, it is recommended to add a key.
  //state is not necessary here, while for more complex use case, a local state is needed.
  //https://youtu.be/kn0EOS-ZiIc
  //https://book.flutterchina.club/chapter2/flutter_widget_intro.html
  const StatefulText({required Key key, required this.text}) : super(key: key);
  final String text;
  @override
  State<StatefulText> createState() => _StatefulTextState();
}

class _StatefulTextState extends State<StatefulText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text);
  }
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
  Widget build(BuildContext context) {
    return Column(
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
  final void Function(bool?) callback;

  @override
  Widget build(BuildContext context) {
    return Column(
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
}

class LogView extends StatelessWidget {
  const LogView({
    super.key,
    required this.scrollController,
    required this.logs,
  });

  final ScrollController scrollController;
  final List<StatefulText> logs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 32.0, left: 12.0, right: 12.0),
        itemCount: logs.length,
        itemBuilder: (context, index) => logs[logs.length - index - 1],
      ),
    );
  }
}
