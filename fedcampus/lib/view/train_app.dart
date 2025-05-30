import 'package:fedcampus/train/fedmcrnn_training.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrainApp extends StatefulWidget {
  const TrainApp({super.key});

  @override
  createState() => _TrainAppState();
}

class _TrainAppState extends State<TrainApp> {
  final _training = FedmcrnnTraining();
  final _scrollController = ScrollController();
  final _flServerIPController = TextEditingController();
  final _flServerPortController = TextEditingController();
  final _logs = [const Text('Logs will be shown here.')];
  var _canPrepare = true;
  var _canTrain = false;
  var _startFresh = false;

  appendLog(String message) {
    logger.d('appendLog: $message');
    setState(() {
      _logs.add(Text(message));
    });
  }

  @override
  build(BuildContext context) => LayoutBuilder(builder: buildLayout);

  prepare() async {
    Uri host;
    try {
      host = Uri.parse('http://${_flServerIPController.text}');
      if (!host.hasEmptyPath || host.host.isEmpty || host.hasPort) {
        throw Exception();
      }
    } catch (e) {
      return appendLog('Invalid backend server host!');
    }
    Uri backendUrl;
    int backendPort;
    try {
      backendPort = int.parse(_flServerPortController.text);
      backendUrl = host.replace(port: backendPort);
    } catch (e) {
      return appendLog('Invalid backend server port!');
    }

    _canPrepare = false;
    appendLog('Connecting with Server IP: $host, Port: $backendPort');

    try {
      await _prepare(host, backendUrl);
    } on PlatformException catch (error, stacktrace) {
      _canPrepare = true;
      appendLog('Request failed: ${error.message}.');
      logger.e('$error\n$stacktrace.');
    } catch (error, stacktrace) {
      _canPrepare = true;
      appendLog('Request failed: $error.');
      logger.e(stacktrace);
    }
  }

  _prepare(Uri host, Uri backendUrl) async {
    final id = await deviceId();
    logger.d('Device ID: $id');
    // TODO: Provide data.
    _training.infoStream().listen(appendLog);
    await _training.prepare(host.host, backendUrl.toString(), {},
        deviceId: id, startFresh: _startFresh);
    _canTrain = true;
    appendLog('Ready to train.');
  }

  startTrain() {
    try {
      _training.start(appendLog);
      _canTrain = false;
    } on PlatformException catch (error, stacktrace) {
      _canTrain = true;
      appendLog('Training failed: ${error.message}.');
      logger.e('$error\n$stacktrace.');
    } catch (error, stacktrace) {
      _canTrain = true;
      appendLog('Failed to start training: $error.');
      logger.e(stacktrace);
    }
  }

  Widget buildLayout(BuildContext _, BoxConstraints __) => Scaffold(
        appBar: AppBar(
          title: const Text('FedCampus'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputView(
                flServerIPController: _flServerIPController,
                flServerPortController: _flServerPortController,
                startFresh: _startFresh,
                callback: (checked) {
                  setState(() => _startFresh = checked!);
                }),
            ButtonsView(
                canConnect: _canPrepare,
                canTrain: _canTrain,
                connectCallback: prepare,
                trainCallback: startTrain),
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
      required this.flServerIPController,
      required this.flServerPortController,
      required this.startFresh,
      required this.callback});

  final TextEditingController flServerIPController;
  final TextEditingController flServerPortController;
  final bool startFresh;
  final Function(bool?) callback;

  @override
  build(BuildContext context) => Column(
        children: [
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
