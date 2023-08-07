import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;

  List<String> list = <String>['English', 'Simplified Chinese', 'Japanese'];

  @override
  void initState() {
    super.initState();
    initSettings(context);
  }

  toggleTheme(bool b, BuildContext context) async {
    prefs.setBool('isDarkModeOn', b);
    Provider.of<MyAppState>(context, listen: false).toggleTheme(b);
  }

  void initSettings(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    MyAppState myAppState = Provider.of<MyAppState>(context, listen: false);
    bool theme = prefs.getBool('isDarkModeOn') ?? false;
    myAppState.isDarkModeOn = theme;
    myAppState.toggleTheme(theme);
  }

  void setLocale(String locale, BuildContext context) {
    logger.d(locale);
    switch (locale) {
      case 'English':
        {
          Provider.of<MyAppState>(context, listen: false)
              .setLocale(const Locale('en', 'US'));
        }
      case 'Simplified Chinese':
        {
          Provider.of<MyAppState>(context, listen: false)
              .setLocale(const Locale('zh', 'CN'));
        }
      case 'Japanese':
        {
          Provider.of<MyAppState>(context, listen: false)
              .setLocale(const Locale('ja', 'JP'));
        }
      default:
        {
          Provider.of<MyAppState>(context, listen: false)
              .setLocale(const Locale('en', 'US'));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.dark_mode),
                Switch(
                    value: appState.isDarkModeOn,
                    onChanged: (b) => toggleTheme(b, context)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.language),
                DropdownButton(
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (s) => setLocale(s ?? 'en', context))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
