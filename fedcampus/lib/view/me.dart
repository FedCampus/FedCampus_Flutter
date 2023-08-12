import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/view/me/user_api.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:fedcampus/view/me/preferences.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/me/signin.dart';

class Me extends StatefulWidget {
  const Me({
    super.key,
  });

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> with AutomaticKeepAliveClientMixin<Me> {
  @override
  bool get wantKeepAlive => true;
  final methodChannel = const MethodChannel('fed_kit_flutter');

  String log = "";

  void _logOut() async {
    try {
      await userApi.logout();
      if (mounted) showToastMessage('you successfully logged out', context);
      if (mounted) {
        Provider.of<UserModel>(context, listen: false).setLogin = false;
      }
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
    }
  }

  void _healthServiceAuthenticate() async {
    try {
      await userApi.healthServiceAuthenticate();
      if (mounted) showToastMessage('you successfully authenticated', context);
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
    }
  }

  void _healthServiceCancel() async {
    try {
      await userApi.healthServiceCancel();
      if (mounted) {
        showToastMessage('you successfully cancelled authenticattion', context);
      }
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double pixel = MediaQuery.of(context).size.width / 400;
    return ListView(
      children: [
        const IntrinsicHeight(
          child: ProfileCard(
            date: '1/1',
            steps: '1111',
          ),
        ),
        SizedBox(
          height: 10 * pixel,
        ),
        MeText(
          text: 'Sign in',
          callback: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignIn()),
          ),
        ),
        SizedBox(
          height: 10 * pixel,
        ),
        MeText(
          text: 'Account Settings',
          callback: () => {},
        ),
        const MeDivider(),
        MeText(
          text: 'Preferences',
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Preferences()),
            );
          },
        ),
        const MeDivider(),
        MeText(
          text: 'Authentication',
          callback: _healthServiceAuthenticate,
        ),
        const MeDivider(),
        MeText(
          text: 'Cancel authentication',
          callback: _healthServiceCancel,
        ),
        const MeDivider(),
        MeText(text: 'About', callback: () => {}),
        const MeDivider(),
        MeText(
          text: 'Help & feedback',
          callback: () => {},
        ),
        const MeDivider(),
        MeText(
          text: 'Sign out',
          callback: _logOut,
        ),
        const MeDivider(),
        const BottomText(),
      ],
    );
  }
}

class BottomText extends StatelessWidget {
  const BottomText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Privacy Policy',
        style:
            TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer),
      ),
      SizedBox(
        width: 30 * pixel,
        child: Text(
          '·',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: pixel * 30),
        ),
      ),
      Text(
        'Terms of Service',
        style:
            TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer),
      )
    ]);
  }
}

class MeDivider extends StatelessWidget {
  const MeDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Divider(
      height: 1 * pixel,
      thickness: 1,
      indent: 50,
      endIndent: 50,
      color: Theme.of(context).colorScheme.onTertiaryContainer,
    );
  }
}

class MeText extends StatelessWidget {
  const MeText({
    super.key,
    required this.text,
    required this.callback,
  });

  final String text;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Padding(
      padding:
          EdgeInsets.fromLTRB(50 * pixel, 0 * pixel, 50 * pixel, 0 * pixel),
      child: TextButton(
        onPressed: callback,
        child: Text(
          text,
          style: TextStyle(
              fontSize: pixel * 20,
              color: Theme.of(context).colorScheme.onTertiaryContainer),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.date,
    required this.steps,
  });

  final String date;
  final String steps;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    getAvatar();
  }

  upLoadAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path ?? '');
      Dio dio = Dio();
      FormData formData =
          FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
      logger.d(formData);
      try {
        var response = await dio.put('http://192.168.0.107:9999/api/file/10/',
            data: formData);
        logger.d(response);
      } catch (e) {
        logger.d(e);
      }
    } else {
      // User canceled the picker
    }
    getAvatar();
  }

  getAvatar() async {
    String responseBody;
    try {
      responseBody =
          (await http.get(Uri.parse('http://192.168.0.107:9999/api/file/10/')))
              .body;
    } catch (e) {
      responseBody = '{"file": "fail"}';
    }
    final data = jsonDecode(responseBody);
    if (mounted) {
      setState(() {
        _avatarUrl = data['file'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20 * pixel, 0, 0),
      child: header(),
    );
  }
}

Widget header() {
  return Consumer<UserModel>(
    builder: (BuildContext context, UserModel value, Widget? child) {
      double pixel = MediaQuery.of(context).size.width / 400;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          value.isLogin
              ? CircleAvatar(
                  foregroundImage: NetworkImage(value.user['avatarUrl'] ?? ''),
                  backgroundImage:
                      const AssetImage('assets/images/step_activity.png'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceTint,
                  radius: 40 * pixel,
                )
              : CircleAvatar(
                  backgroundImage: const AssetImage(
                      'assets/images/me_nav_icon_inactive.png'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceTint,
                  radius: 40 * pixel,
                ),
          Text(
            value.isLogin ? value.user['userName'] : 'Not logged in',
            style: TextStyle(
                fontSize: pixel * 20,
                color: Theme.of(context).colorScheme.onTertiaryContainer),
          )
        ],
      );
    },
  );
}
