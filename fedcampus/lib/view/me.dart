import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fedcampus/view/me/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    Provider.of<UserModel>(context, listen: false).setUser();
  }

  Future<void> _loginAndGetResult() async {
    final loggedIn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
    logger.d(loggedIn);
    if (loggedIn && mounted) {
      Provider.of<UserModel>(context, listen: false).setUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: [
        const IntrinsicHeight(
          child: ProfileCard(
            date: '1/1',
            steps: '1111',
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        MeText(
          text: 'Sign in',
          callback: _loginAndGetResult,
        ),
        const SizedBox(
          height: 10,
        ),
        MeText(
          text: 'Account Settings',
          callback: () {},
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
          callback: () => Provider.of<UserModel>(context, listen: false)
              .getHuaweiAuthenticate(),
        ),
        const MeDivider(),
        MeText(
          text: 'Cancel authentication',
          callback: () => Provider.of<UserModel>(context, listen: false)
              .cancelHuaweiAuthenticate(),
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
          callback: () =>
              Provider.of<UserModel>(context, listen: false).logout(),
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
    return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Privacy Policy'),
      SizedBox(
        width: 30,
        child: Text(
          '·',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
      ),
      Text('Terms of Service')
    ]);
  }
}

class MeDivider extends StatelessWidget {
  const MeDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      endIndent: 50,
      color: Theme.of(context).colorScheme.surfaceVariant,
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

  delayOpenpenNewPage() {
    // add a short delay for more complete animation
    Future.delayed(const Duration(milliseconds: 140)).then((e) => {callback()});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: TextButton(
        onPressed: delayOpenpenNewPage,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.surfaceVariant),
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
    // double logicalWidth = MediaQuery.of(context).size.width;
    // logger.d(logicalWidth / 10);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: upLoadAvatar,
            child: CircleAvatar(
              foregroundImage: NetworkImage(_avatarUrl),
              backgroundImage:
                  const AssetImage('assets/images/step_activity.png'),
              backgroundColor: Theme.of(context).colorScheme.surfaceTint,
              radius: 40,
            ),
          ),
          // GestureDetector(
          //   onTap: upLoadAvatar,
          //   child: Container(
          //     width: 70,
          //     height: 70,
          //     child: Image.network(_avatarUrl,
          //         errorBuilder: (context, error, stackTrace) {
          //       return const Text('Loading ...');
          //     }, frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          //       if (frame == null) {
          //         // fallback to placeholder
          //         return Image.asset(
          //           'assets/images/step_activity.png',
          //         );
          //       }
          //       return child;
          //     }),
          //   ),
          // ),
          Text(
            Provider.of<UserModel>(context).userName,
            style: TextStyle(
                fontSize: 27, color: Theme.of(context).colorScheme.primary),
          ),
          Text(
            Provider.of<UserModel>(context).email,
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.surfaceVariant),
          ),
        ],
      ),
    );
  }
}
