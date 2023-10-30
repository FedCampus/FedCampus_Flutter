import 'dart:io';

import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/datahandler/health_factory.dart';
import '../../utility/health_database.dart';
import '../widgets/widget.dart';

class Preferences extends StatefulWidget {
  const Preferences({
    super.key,
  });

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  List<String> list = <String>['English', 'Simplified Chinese', 'Japanese'];
  List<String> dataProviders = <String>['Huawei Health', 'Google Fit'];

  @override
  void initState() {
    super.initState();
  }

  toggleTheme(bool b, BuildContext context) async {
    userApi.prefs.setBool('isDarkModeOn', b);
    Provider.of<MyAppState>(context, listen: false).toggleTheme(b);
  }

  void setLocale(String locale) {
    logger.d(locale);
    switch (locale) {
      case 'English':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));
        userApi.prefs.setString('locale', 'en_US');
      case 'Simplified Chinese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('zh', 'CN'));
        userApi.prefs.setString('locale', 'zh_CN');
      case 'Japanese':
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('ja', 'JP'));
        userApi.prefs.setString('locale', 'ja_JP');
      default:
        Provider.of<MyAppState>(context, listen: false)
            .setLocale(const Locale('en', 'US'));
        userApi.prefs.setString('locale', 'en_US');
    }
  }

  void setDataProvider(String dataProvider) {
    String dataProviderString;
    logger.d(dataProvider);
    switch (dataProvider) {
      case 'Huawei Health':
        dataProviderString = "huawei";
      case 'Google Fit':
        dataProviderString = "google";
      default:
        dataProviderString = "huawei";
    }
    userApi.prefs.setString("service_provider", dataProviderString);
    userApi.healthDataHandler =
        HealthDataHandlerFactory().creatHealthDataHandler(dataProviderString);
  }

  void resetPreferences() async {
    Provider.of<MyAppState>(context, listen: false).resetPreferences();
    HealthDatabase healthDatabase = await HealthDatabase.create();
    healthDatabase.clear();
  }

  void resetPreferencesConfirmDialog() {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content:
              const Text('Are you sure you want to remove all local settings?'),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                resetPreferences();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
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
              SettingsSwitch(
                text: AppLocalizations.of(context)!.dark_mode,
                value: Provider.of<MyAppState>(context, listen: false)
                    .isDarkModeOn,
                callback: toggleTheme,
              ),
              if (false) // TODO: disable language selection
                // ignore: dead_code
                SettingsDropDownMenu(
                  text: AppLocalizations.of(context)!.language,
                  callback: (s) async {
                    setLocale(s);
                  },
                  options: list,
                  defaultValue: switch (
                      Provider.of<MyAppState>(context, listen: false)
                          .locale
                          .languageCode) {
                    'en' => 'English',
                    'zh' => 'Simplified Chinese',
                    'ja' => 'Japanese',
                    _ => "English",
                  },
                ),
              if (Platform.isAndroid)
                SettingsDropDownMenu(
                  text: "Health Data Provider",
                  callback: (s) async {
                    setDataProvider(s);
                  },
                  options: dataProviders,
                  defaultValue: switch (
                      userApi.prefs.getString("service_provider")) {
                    "huawei" => "Huawei Health",
                    "google" => "Google Fit",
                    _ => "Huawei Health"
                  },
                ),
              SettingsButton(
                text: "Phone usage access settings",
                callback: () => userApi.screenTimeDataHandler.authenticate(),
              ),
              SettingsButton(
                  text: AppLocalizations.of(context)!.reset_preferences,
                  callback: resetPreferencesConfirmDialog),
            ],
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
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding:
          EdgeInsets.fromLTRB(30 * pixel, 10 * pixel, 30 * pixel, 10 * pixel),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: callback,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size.zero, // Set this
            padding: EdgeInsets.fromLTRB(
                0 * pixel, 10 * pixel, 0 * pixel, 10 * pixel), // and this
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: pixel * 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatefulWidget {
  const SettingsSwitch({
    super.key,
    required this.text,
    required this.value,
    required this.callback,
  });

  final String text;
  final bool value;
  final void Function(bool, BuildContext) callback;

  @override
  State<SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  bool _value = false;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding:
          EdgeInsets.fromLTRB(30 * pixel, 10 * pixel, 30 * pixel, 10 * pixel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: TextStyle(
                fontSize: pixel * 18,
                color: Theme.of(context).colorScheme.primary),
          ),
          Switch(
            value: _value,
            onChanged: (b) {
              setState(() {
                _value = b;
              });
              widget.callback(b, context);
            },
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
    required this.defaultValue,
  });

  final String text;
  final List<String> options;
  final Future<void> Function(String) callback;
  final String defaultValue;

  @override
  State<SettingsDropDownMenu> createState() => _SettingsDropDownMenuState();
}

class _SettingsDropDownMenuState extends State<SettingsDropDownMenu> {
  String dropdownValue = "";
  late MyAppState appState;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding:
          EdgeInsets.fromLTRB(30 * pixel, 10 * pixel, 30 * pixel, 10 * pixel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontSize: pixel * 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          DropdownButton(
            value: dropdownValue,
            style: TextStyle(
              fontSize: pixel * 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: widget.options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (s) {
              widget.callback(s ?? widget.defaultValue).then((value) {
                setState(() {
                  dropdownValue = s ?? widget.defaultValue;
                });
              }).onError((error, stackTrace) {
                logger.e(error.toString());
              });
            },
          )
        ],
      ),
    );
  }
}
