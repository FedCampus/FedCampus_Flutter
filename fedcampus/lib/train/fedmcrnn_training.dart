import 'package:fed_kit/train.dart';
import 'package:fedcampus/train/fedmcrnn_client.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/services.dart';

class FedMcrnnTraining {
  final mlClient = FedmcrnnClient();
  late Train train;

  Future<void> prepare(String host, String backendUrl,
      Map<List<List<double>>, List<double>> data,
      {int? deviceId, bool startFresh = false}) async {
    train = Train(backendUrl.toString());
    if (deviceId != null) {
      train.enableTelemetry(deviceId);
    }
    final (model, modelDir) = await train.prepareModel(dataType);
    _logDebug('Prepared model ${model.name} at $modelDir');
    final serverData = await train.getServerInfo(startFresh: startFresh);
    _logDebug('Received server info: $serverData');
    if (serverData.port == null) {
      throw Exception(
          'Flower server port not available", "status ${serverData.status}');
    }
    await mlClient.trainer.initialize(modelDir, model.layers_sizes);
    _logDebug('Initialized trainer');
    await mlClient.trainer.loadData(data);
    _logDebug('Loaded data of size ${data.length}');
    await train.prepare(mlClient, host, serverData.port!);
    _logDebug('Preparation done');
  }

  Future<void> start(Function(String) onInfo) async {
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

  _logDebug(msg) {
    logger.d('FedMcrnnTraining: $msg.');
  }

  _logErr(err, stackTrace) {
    logger.e("FedMcrnnTraining: $err\n$stackTrace");
  }
}

const dataType = 'FedMCRNN_7x8';
