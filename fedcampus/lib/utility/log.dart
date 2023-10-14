import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

//https://stackoverflow.com/questions/70145480/dart-singleton-with-parameters-global-app-logger

Logger get logger => Log.instance;

class Log extends Logger {
  //TODO: change the log out put to console for production
  // Log._(String filename)
  //     : super(
  //           printer: SimplePrinter(printTime: true),
  //           output: FileOutput(file: File(filename), overrideExisting: true));

  Log._(String filename) : super(printer: PrettyPrinter(printTime: true));

  static final instance = Log._(filePath);

  static String filePath = "";

  static Future<void> initLog() async {
    final directory = await getApplicationDocumentsDirectory();
    filePath = "${directory.path}/log";
  }
}

extension FormattedMessage on Exception {
  // helper extention method to get the message of an exception because exceptions
  // in dart do not have .message property
  String get getMessage {
    String s = toString();
    if (s.startsWith("Exception: ")) {
      return s.substring(11);
    } else if (s.startsWith("(")) {
      // case when throwing multiple exceptions, for example in order to preserve
      // the original exception while throw a new one
      RegExp exp = RegExp(r'Exception: ');
      int start = exp.firstMatch(s)!.start;
      exp = RegExp(r',');
      Iterable<RegExpMatch> matches = exp.allMatches(s);
      List<int> commas = [];
      for (final m in matches) {
        commas.add(m.start);
      }
      int lastCommaPos = 2;
      for (int i = 0; i < commas.length; i++) {
        if (start > commas[i] && start < commas[i + 1]) {
          lastCommaPos = commas[i];
        }
      }
      return s.substring(1, lastCommaPos);
    } else {
      return s;
    }
  }
}
