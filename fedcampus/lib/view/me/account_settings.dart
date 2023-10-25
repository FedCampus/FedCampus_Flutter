import 'dart:async';

import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/log.dart';
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

  Map<String, int> roles = {
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
  }

  void setRole(String role) {
    logger.d(role);
    setState(() {
      _status = roles[role]!;
    });
  }

  void setGrade(String grade) {
    logger.d(grade);
    _grade = grades[grade]!;
  }

  void setGender(String gender) {
    logger.d(gender);
    _gender = genders[gender]!;
  }

  Future<void> commitChanges() async {
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    try {
      await HTTPApi.accountSettings(_status, _grade, _gender)
          .timeout(const Duration(seconds: 5));
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
        children: [
          WidgetListWithDivider(
            color: Theme.of(context).colorScheme.primary,
            children: [
              SettingsDropDownMenu(
                key: GlobalKey(),
                text: "Role",
                callback: (s) {
                  return commitChanges().then((value) => setRole(s));
                },
                options: roles.keys.toList(),
                defaultValue: (roles.entries
                    .firstWhere((entry) => entry.value == _status)
                    .key),
              ),
              if (_status == 1)
                SettingsDropDownMenu(
                  key: GlobalKey(),
                  text: "Grade",
                  callback: (s) {
                    return commitChanges().then((value) => setGrade(s));
                  },
                  options: grades.keys.toList(),
                  defaultValue: (grades.entries
                      .firstWhere((entry) => entry.value == _grade)
                      .key),
                ),
              SettingsDropDownMenu(
                key: GlobalKey(),
                text: "Gender",
                callback: (s) {
                  return commitChanges().then((value) => setGender(s));
                },
                options: genders.keys.toList(),
                defaultValue: (genders.entries
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
