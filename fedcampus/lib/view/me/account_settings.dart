import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({
    super.key,
  });

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
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
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));

      case 'Simplified Chinese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('zh', 'CN'));

      case 'Japanese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('ja', 'JP'));

      default:
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          SettingsSwitch(callback: toggleTheme),
          const SettingsDivider(),
          SettingsDropDownMenu(callback: setLocale, options: list),
        ],
      ),
    );
  }
}

class SettingsSwitch extends StatefulWidget {
  const SettingsSwitch({super.key, required this.callback});

  final void Function(bool, BuildContext) callback;

  @override
  State<SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)!.dark_mode,
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.onTertiaryContainer)),
          Switch(
              value: appState.isDarkModeOn,
              onChanged: (b) => widget.callback(b, context)),
        ],
      ),
    );
  }
}

class SettingsDropDownMenu extends StatefulWidget {
  const SettingsDropDownMenu(
      {super.key, required this.callback, required this.options});

  final void Function(String, BuildContext) callback;
  final List<String> options;

  @override
  State<SettingsDropDownMenu> createState() => _SettingsDropDownMenuState();
}

class _SettingsDropDownMenuState extends State<SettingsDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).colorScheme.onTertiaryContainer),
          ),
          DropdownButton(
              value: 'English',
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.onTertiaryContainer),
              items:
                  widget.options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (s) => widget.callback(s ?? 'en', context))
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
