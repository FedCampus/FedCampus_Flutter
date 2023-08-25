class FedHealthData {
  /// abstract class for health data controller on variery of platforms such as Huawei Health, Google Fit
  Future<bool> authenticate() async {
    throw UnimplementedError();
  }

  Future<double> getData(
      {required String entry, required DateTime date}) async {
    throw UnimplementedError();
  }
}
