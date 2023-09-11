import 'dart:async';

import 'package:app_set_id/app_set_id.dart';
import 'package:fed_kit/train.dart';
import 'package:fedcampus/train/fedmcrnn_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/services.dart';

class FedmcrnnTraining {
  final _streamCtl = StreamController<String>();
  final mlClient = FedmcrnnClient();
  late Train train;

  Stream<String> infoStream() => _streamCtl.stream;

  Future<void> prepare(String host, String backendUrl,
      Map<List<List<double>>, List<double>> data,
      {int? deviceId, bool startFresh = false}) async {
    train = Train(backendUrl.toString());
    if (deviceId != null) {
      train.enableTelemetry(deviceId);
    }
    final (model, modelDir) = await train.prepareModel(dataType);
    _sendInfo('Prepared model ${model.name} at $modelDir');
    final serverData = await train.getServerInfo(startFresh: startFresh);
    _sendInfo('Received server info: $serverData');
    if (serverData.port == null) {
      throw Exception(
          'Flower server port not available", "status ${serverData.status}');
    }
    // TODO:Make another function call if on iOS.
    await mlClient.trainer.initialize(modelDir, model.tflite_layers!);
    _sendInfo('Initialized trainer');
    await mlClient.trainer.loadData(data);
    _sendInfo('Loaded data of size ${data.length}');
    await train.prepare(mlClient, host, serverData.port!);
    _sendInfo('Preparation done');
  }

  void start(Function(String) onInfo) {
    try {
      train.start().listen(onInfo,
          onDone: () => onInfo('Training done'),
          onError: (e) => onInfo('Training failed: $e'),
          cancelOnError: true);
      onInfo('Started training');
    } on PlatformException catch (err, stackTrace) {
      onInfo('Training failed: ${err.message}');
      _logErr(err, stackTrace);
    } catch (err, stackTrace) {
      onInfo('Failed to start training: $err');
      _logErr(err, stackTrace);
    }
  }

  _sendInfo(msg) {
    _streamCtl.add(msg);
    _logDebug(msg);
  }

  _logDebug(msg) {
    logger.d('FedMcrnnTraining: $msg.');
  }

  _logErr(err, stackTrace) {
    logger.e("FedMcrnnTraining: $err\n$stackTrace");
  }
}

Future<int> deviceId() async => (await AppSetId().getIdentifier()).hashCode;

const dataType = 'FedMCRNN_7x8';
