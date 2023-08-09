import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Preferences extends StatefulWidget {
  const Preferences({
    super.key,
  });

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  late SharedPreferences prefs;

  List<String> list = <String>['English', 'Simplified Chinese', 'Japanese'];

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  toggleTheme(bool b, BuildContext context) async {
    prefs.setBool('isDarkModeOn', b);
    Provider.of<MyAppState>(context, listen: false).toggleTheme(b);
  }

  void initSettings() async {
    prefs = await SharedPreferences.getInstance();
  }

  void setLocale(String locale) {
    logger.d(locale);
    switch (locale) {
      case 'English':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));
        prefs.setString('locale', 'en_US');
      case 'Simplified Chinese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('zh', 'CN'));
        prefs.setString('locale', 'zh_CN');

      case 'Japanese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('ja', 'JP'));
        prefs.setString('locale', 'ja_JP');

      default:
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));
        prefs.setString('locale', 'en_US');
    }
  }

  void resetPreferences() {
    Provider.of<MyAppState>(context, listen: false).resetPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          SettingsSwitch(
            text: AppLocalizations.of(context)!.dark_mode,
            callback: toggleTheme,
          ),
          const SettingsDivider(),
          SettingsDropDownMenu(
            text: AppLocalizations.of(context)!.language,
            callback: setLocale,
            options: list,
          ),
          const SettingsDivider(),
          SettingsButton(
            text: AppLocalizations.of(context)!.reset_preferences,
            callback: resetPreferences,
          ),
        ],
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    required this.text,
    required this.callback,
  });

  final String text;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    Future<bool?> removeSettingsDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirmation"),
            content: const Text(
                'Are you sure you want to remove all local settings?'),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  callback();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: removeSettingsDialog,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size.zero, // Set this
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10), // and this
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.text,
    required this.callback,
  });

  final String text;
  final void Function(bool, BuildContext) callback;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).colorScheme.primary),
          ),
          Switch(
            value: appState.isDarkModeOn,
            onChanged: (b) => callback(b, context),
          ),
        ],
      ),
    );
  }
}

class SettingsDropDownMenu extends StatefulWidget {
  const SettingsDropDownMenu({
    super.key,
    required this.text,
    required this.callback,
    required this.options,
  });

  final String text;
  final List<String> options;
  final void Function(String) callback;

  @override
  State<SettingsDropDownMenu> createState() => _SettingsDropDownMenuState();
}

class _SettingsDropDownMenuState extends State<SettingsDropDownMenu> {
  late String dropdownValue;
  late MyAppState appState;

  @override
  void initState() {
    super.initState();
    appState = Provider.of<MyAppState>(context, listen: false);
    var languageCode = appState.locale.languageCode;
    switch (languageCode) {
      case 'en':
        dropdownValue = 'English';
      case 'zh':
        dropdownValue = 'Simplified Chinese';
      case 'ja':
        dropdownValue = 'Japanese';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          DropdownButton(
            value: dropdownValue,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: widget.options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (s) => widget.callback(s ?? 'en'),
          )
        ],
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 40,
      endIndent: 40,
      color: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}
