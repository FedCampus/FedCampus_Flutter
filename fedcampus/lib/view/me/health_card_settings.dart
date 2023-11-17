import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/view/health.dart';
import 'package:fedcampus/view/me/preferences.dart';
import 'package:flutter/material.dart';
import '../widgets/widget.dart';

class HealthCardSettings extends StatefulWidget {
  const HealthCardSettings({
    super.key,
  });

  @override
  State<HealthCardSettings> createState() => _HealthCardSettingsState();
}

class _HealthCardSettingsState extends State<HealthCardSettings> {
  late final List<String> entries;

  @override
  void initState() {
    super.initState();
    entries = healthEntries.map((e) => (e["entry_name"]) as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50 * pixel,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        centerTitle: true,
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
      ),
      body: ListView(
        children: [
          WidgetListWithDivider(
            color: Theme.of(context).colorScheme.primary,
            children: [
              for (var e in entries)
                SettingsSwitch(
                  text: snakeCaseToTitleCase(e),
                  value: userApi.prefs.getBool(e) ?? true,
                  callback: (bool b) {
                    userApi.prefs.setBool(e, b);
                  },
                )
            ],
          ),
        ],
      ),
    );
  }
}

String snakeCaseToTitleCase(String snakeCaseString) {
  List<String> words = snakeCaseString.split('_');
  List<String> titleCaseWords = words.map((word) => word.capitalize()).toList();
  String titleCaseString = titleCaseWords.join(' ');
  return titleCaseString;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
