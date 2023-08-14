import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeons/loaddata.g.dart',
  dartOptions: DartOptions(),
  // cppOptions: CppOptions(namespace: 'pigeon_example'),
  // cppHeaderOut: 'windows/runner/messages.g.h',
  // cppSourceOut: 'windows/runner/messages.g.cpp',
  kotlinOut:
      'android/app/src/main/kotlin/com/cuhk/fedcampus/pigeon/loaddata.g.kt',
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
@HostApi()
abstract class LoadDataApi {
  @async
  Map<List<List<double>>, List<double>> loaddata();
}


/*
This part is essential to load data

      var x = replyList[0] as Map<Object?, Object?>;

      Map<List<List<double>>, List<double>> xTrue = {};
      for (var entry in x.entries) {
        final value = entry.value as List<Object?>;
        final key = entry.key as List<Object?>;
        List<List<double>> twoDarrayTrue = List.empty(growable: true);
        for (var onedarray in key) {
          var x1 = (onedarray as List<Object?>);
          List<double> onedarrayList = List.empty(growable: true);
          for (final i in x1) {
            onedarrayList.add(i as double);
          }
          twoDarrayTrue.add(onedarrayList);
        }
        xTrue[twoDarrayTrue] = [value[0]! as double];
      }
      return xTrue;


*/