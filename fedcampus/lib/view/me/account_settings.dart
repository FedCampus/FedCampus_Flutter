import 'dart:async';

import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/event_bus.dart';
import 'package:fedcampus/view/me/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widget.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({
    super.key,
  });

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  Map<String, int> statuses = {
    "Student": 1,
    "Faculty": 2,
  };

  Map<String, int> grades = {
    "Freshman": 2027,
    "Sophomore": 2026,
    "Junior": 2025,
    "Senior": 2024,
  };

  Map<String, int> genders = {
    "Male": 1,
    "Female": 2,
  };

  Future<void> showLoading() async {
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    bus.on("loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
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
        padding: EdgeInsets.fromLTRB(0, 10 * pixel, 0, 0),
        children: [
          WidgetListWithDivider(
            color: Theme.of(context).colorScheme.primary,
            children: [
              SettingsMultipleChoiceTile(
                key: GlobalKey(),
                text: "Role",
                onChanged: (s) {
                  showLoading();
                  Provider.of<UserModel>(context, listen: false)
                      .myAccountSettings(status: statuses[s]);
                },
                options: statuses.keys.toList(),
                value: (statuses.entries
                    .firstWhere((entry) =>
                        entry.value == Provider.of<UserModel>(context).myStatus)
                    .key),
              ),
              if (Provider.of<UserModel>(context).myStatus == 1)
                SettingsMultipleChoiceTile(
                  key: GlobalKey(),
                  text: "Grade",
                  onChanged: (s) {
                    showLoading();
                    Provider.of<UserModel>(context, listen: false)
                        .myAccountSettings(grade: grades[s]);
                  },
                  options: grades.keys.toList(),
                  value: (grades.entries
                      .firstWhere((entry) =>
                          entry.value ==
                          Provider.of<UserModel>(context).myGrade)
                      .key),
                ),
              SettingsMultipleChoiceTile(
                key: GlobalKey(),
                text: "Gender",
                onChanged: (s) {
                  showLoading();
                  Provider.of<UserModel>(context, listen: false)
                      .myAccountSettings(gender: genders[s]);
                },
                options: genders.keys.toList(),
                value: (genders.entries
                    .firstWhere((entry) =>
                        entry.value == Provider.of<UserModel>(context).myGender)
                    .key),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
