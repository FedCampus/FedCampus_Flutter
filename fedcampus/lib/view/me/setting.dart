import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  final List<bool> _selectedThemes = [true, false];

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  toggleTest(int i) async {
    if (i == 1) {
      await prefs.setBool('test', true);
      setState(() {
        _selectedThemes[0] = false;
        _selectedThemes[1] = true;
      });
    } else {
      await prefs.setBool('test', false);
      setState(() {
        _selectedThemes[0] = true;
        _selectedThemes[1] = false;
      });
    }
  }

  void initSettings() async {
    prefs = await SharedPreferences.getInstance();
    logger.d(prefs.getBool('test') ?? false);
    if (prefs.getBool('test') ?? false) {
      setState(() {
        logger.d(1);
        _selectedThemes[0] = false;
        _selectedThemes[1] = true;
      });
    } else {
      setState(() {
        logger.d(2);
        _selectedThemes[0] = true;
        _selectedThemes[1] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ToggleButtons(
              isSelected: _selectedThemes,
              onPressed: (i) => toggleTest(i),
              children: const [Text('false'), Text('true')]),
        ],
      ),
    );
  }
}
