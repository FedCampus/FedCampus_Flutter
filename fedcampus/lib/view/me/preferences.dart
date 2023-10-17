import 'dart:io';

import 'package:fedcampus/main.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/datahandler/health_factory.dart';
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

  void resetPreferences() {
    Provider.of<MyAppState>(context, listen: false).resetPreferences();
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
                callback: toggleTheme,
              ),
              if (false) // TODO: disable language selection
                // ignore: dead_code
                SettingsDropDownMenu(
                  text: AppLocalizations.of(context)!.language,
                  callback: setLocale,
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
                  callback: setDataProvider,
                  options: dataProviders,
                  defaultValue: switch (
                      userApi.prefs.getString("service_provider")) {
                    "huawei" => "Huawei Health",
                    "google" => "Google Fit",
                    _ => "Huawei Health"
                  },
                ),
              SettingsButton(
                text: AppLocalizations.of(context)!.reset_preferences,
                callback: resetPreferences,
              ),
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

    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding:
          EdgeInsets.fromLTRB(30 * pixel, 10 * pixel, 30 * pixel, 10 * pixel),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: removeSettingsDialog,
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
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding:
          EdgeInsets.fromLTRB(30 * pixel, 10 * pixel, 30 * pixel, 10 * pixel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: pixel * 18,
                color: Theme.of(context).colorScheme.primary),
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
    required this.defaultValue,
  });

  final String text;
  final List<String> options;
  final void Function(String) callback;
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
    logger.e(dropdownValue);
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
            onChanged: (s) => widget.callback(s ?? widget.defaultValue),
          )
        ],
      ),
    );
  }
}
