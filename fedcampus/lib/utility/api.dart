import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/platform_channel.dart';
import 'package:flutter/services.dart';

class FedAPI {
  final _channel = TrainChannel();
  final List<String> logs = ['logs from FedAPI'];

  appendLog(String message) {
    logger.d('appendLog: $message');
    logs.add(message);
  }

  clearLog() {
    logs.clear();
  }

  Future<(bool, bool, List<String>)?> connectAPI(
      int partitionId, Uri host, int backendPort, bool startFresh) async {
    var canConnect = true;
    var canTrain = false;
    final backendUrl = host.replace(port: backendPort);

    appendLog(
        'Connecting with Partition ID: $partitionId, Server IP: $host, Port: $backendPort');
    try {
      final serverPort = await _channel.connect(partitionId, host, backendUrl,
          startFresh: startFresh);
      canTrain = true;
      appendLog(
          'Connected to Flower server on port $serverPort and loaded data set.');
    } on PlatformException catch (error, stacktrace) {
      appendLog('Request failed: ${error.message}.');
      logger.e('$error\n$stacktrace.');
    } catch (error, stacktrace) {
      appendLog('Request failed: $error.');
      logger.e(stacktrace);
    }
    canConnect = true;

    return (canConnect, canTrain, logs);
  }
}
