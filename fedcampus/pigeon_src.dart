import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon/generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/com/cuhk/fedcampus/pigeon/generated.g.kt',
  kotlinOptions: KotlinOptions(),
  dartPackageName: 'fedcampus',
))
@HostApi()
abstract class AlarmApi {
  @async
  bool setAlarm();
}

class Data {
  Data(
      {required this.value,
      required this.name,
      required this.startTime,
      required this.endTime});
  String name;
  double value;
  int startTime;
  int endTime;
}

@HostApi()
abstract class DataApi {
  @async
  List<Data> getData(String name, int startTime, int endTime);
}

@HostApi()
abstract class HuaweiAuthApi {
  @async
  bool getAuthenticate();

  @async
  bool cancelAuthenticate();
}

@HostApi()
abstract class LoadDataApi {
  @async
  Map<List<List<double>>, List<double>> loaddata();
}

@HostApi()
abstract class TrainFedmcrnn {
  @async
  void loadData(Map<List<List<double>>, List<double>> data);

  @async
  List<Uint8List> getParameters();

  @async
  void updateParameters(List<Uint8List> parameters);

  bool ready();

  @async
  void fit(int epochs, int batchSize);

  int trainingSize();

  int testSize();

  @async
  Float64List evaluate();
}
