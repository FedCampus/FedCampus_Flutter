import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:fed_kit/ml_client.dart';
import 'package:flutter/services.dart';

class FedmcrnnClient extends MLClient {
  final trainer = TrainFedmcrnn();
  final eventChannel =
      const EventChannel('org.eu.fedcampus.train.FedmcrnnClient.EventChannel');
  bool _listening = false;
  Function(List<double> p1)? _onLoss;

  @override
  Future<(double, double)> evaluate() async {
    final lossAccuracy = await trainer.evaluate();
    return (lossAccuracy.loss, lossAccuracy.accuracy);
  }

  @override
  Future<void> fit(
      {int epochs = 1,
      int batchSize = 32,
      Function(List<double> p1)? onLoss}) async {
    _onLoss = onLoss;
    ensureListening();
    await trainer.fit(epochs, batchSize);
  }

  @override
  Future<List<Uint8List>> getParameters() async {
    final parameters = await trainer.getParameters();
    return parameters.cast<Uint8List>();
  }

  @override
  Future<bool> ready() => trainer.ready();

  @override
  Future<int> get testSize => trainer.testSize();

  @override
  Future<int> get trainingSize => trainer.trainingSize();

  @override
  Future<void> updateParameters(List<Uint8List> parameters) =>
      trainer.updateParameters(parameters);

  void ensureListening() {
    if (_listening) return;
    eventChannel.receiveBroadcastStream().listen(_callOnLoss);
    _listening = true;
  }

  void _callOnLoss(loss) {
    _onLoss?.call(loss.cast<double>());
  }
}
