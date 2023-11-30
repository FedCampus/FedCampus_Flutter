import 'dart:async';

import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/view/me/preferences.dart';
import 'package:flutter/material.dart';
import '../../utility/http_api.dart';
import '../../utility/my_exceptions.dart';
import '../widgets/widget.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({
    super.key,
  });

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  int _status = userApi.prefs.getInt("status") ?? 1;
  int _grade = userApi.prefs.getInt("grade") ?? 2025;
  int _gender = userApi.prefs.getInt("gender") ?? 1; // 1 male, 2 female
  late final Map<String, Future<void> Function(int)> accountSettingsStrategies;

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

  @override
  void initState() {
    super.initState();
    accountSettingsStrategies = {
      "status": (int value) =>
          HTTPApi.accountSettings({..._baseParams, "faculty": value == 2}),
      "grade": (int value) =>
          HTTPApi.accountSettings({..._baseParams, "student": value}),
      "gender": (int value) =>
          HTTPApi.accountSettings({..._baseParams, "male": value == 1}),
    };
  }

  Map<String, dynamic> get _baseParams => {
        "faculty": _status == 2,
        "student": _grade,
        "male": _gender == 1,
      };

  Future<void> commitChanges(
      Future<void> Function() accountSettingsStrategy) async {
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    try {
      await accountSettingsStrategy().timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      loadingDialog.showIfDialogNotCancelled(
          e, "Please check your internet connection");
      rethrow;
    } on MyException catch (e) {
      loadingDialog.showIfDialogNotCancelled(e, e.toString());
      rethrow;
    } on Exception catch (e) {
      loadingDialog.showIfDialogNotCancelled(e, "Log in error");
      rethrow;
    }
    if (mounted && !loadingDialog.cancelled) {
      userApi.prefs.setInt("status", _status);
      userApi.prefs.setInt("grade", _grade);
      userApi.prefs.setInt("gender", _gender);
      showToastMessage('Account setting success', context);
    }
    loadingDialog.cancel();
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
                  commitChanges(() async =>
                          accountSettingsStrategies["status"]!(statuses[s]!))
                      .then((v) => setState(() => _status = statuses[s]!));
                },
                options: statuses.keys.toList(),
                value: (statuses.entries
                    .firstWhere((entry) => entry.value == _status)
                    .key),
              ),
              if (_status == 1)
                SettingsMultipleChoiceTile(
                  key: GlobalKey(),
                  text: "Grade",
                  onChanged: (s) {
                    commitChanges(() async =>
                            accountSettingsStrategies["grade"]!(grades[s]!))
                        .then((v) => setState(() => _grade = grades[s]!));
                  },
                  options: grades.keys.toList(),
                  value: (grades.entries
                      .firstWhere((entry) => entry.value == _grade)
                      .key),
                ),
              SettingsMultipleChoiceTile(
                key: GlobalKey(),
                text: "Gender",
                onChanged: (s) {
                  commitChanges(() async =>
                          accountSettingsStrategies["gender"]!(genders[s]!))
                      .then((v) => setState(() => _gender = genders[s]!));
                },
                options: genders.keys.toList(),
                value: (genders.entries
                    .firstWhere((entry) => entry.value == _gender)
                    .key),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
