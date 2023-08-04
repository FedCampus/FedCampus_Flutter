import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeons/messages.g.dart',
  dartOptions: DartOptions(),
  // cppOptions: CppOptions(namespace: 'pigeon_example'),
  // cppHeaderOut: 'windows/runner/messages.g.h',
  // cppSourceOut: 'windows/runner/messages.g.cpp',
  kotlinOut:
      'android/app/src/main/kotlin/com/cuhk/fedcampus/pigeon/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  // javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  // javaOptions: JavaOptions(),
  // swiftOut: 'ios/Runner/Messages.g.swift',
  // swiftOptions: SwiftOptions(),
  // objcHeaderOut: 'macos/Runner/messages.g.h',
  // objcSourceOut: 'macos/Runner/messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  // objcOptions: ObjcOptions(prefix: 'PGN'),
  // copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'pigeon_example_package',
))
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
