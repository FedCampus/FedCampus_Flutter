import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/view/me/about.dart';
import 'package:fedcampus/view/me/privacy_policy.dart';
import 'package:fedcampus/view/trainingDetail.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
      await HTTPApi.logout();
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
      await userApi.healthDataHandler.authenticate();
      if (mounted) showToastMessage('you successfully authenticated', context);
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
    }
  }

  void _healthServiceCancel() async {
    try {
      await userApi.healthDataHandler.cancelAuthentication();
      if (mounted) {
        showToastMessage('you successfully cancelled authenticattion', context);
      }
    } on Exception catch (e) {
      logger.d(e.toString());
      if (mounted) showToastMessage(e.getMessage, context);
    }
  }

  void _toSignInPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double pixel = MediaQuery.of(context).size.width / 400;
    return ListView(
      children: [
        const ProfileCard(),
        SizedBox(
          height: 10 * pixel,
        ),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            // placeholder since a widget cannot be null
            return const SizedBox();
          }
          return MeText(
            text: 'Sign in',
            callback: () => _toSignInPage(),
          );
        }),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            // placeholder since a widget cannot be null
            return const SizedBox();
          } else {
            return const MeDivider();
          }
        }),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            return MeText(
              text: 'Account Settings',
              callback: () => {},
            );
          } else {
            // placeholder since a widget cannot be null
            return const SizedBox();
          }
        }),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            return const MeDivider();
          } else {
            // placeholder since a widget cannot be null
            return const SizedBox();
          }
        }),
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
          text: 'Authenticate',
          callback: _healthServiceAuthenticate,
        ),
        const MeDivider(),
        MeText(
          text: 'Cancel authentication',
          callback: _healthServiceCancel,
        ),
        const MeDivider(),
        MeText(
            text: 'About',
            callback: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const About()),
                  )
                }),
        const MeDivider(),
        MeText(
          text: 'Help & feedback',
          callback: () => {},
        ),
        const MeDivider(),
        MeText(
          text: 'Log Output',
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrainingDetail()),
            );
          },
        ),
        const MeDivider(),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            return MeText(
              text: 'Sign out',
              callback: _logOut,
            );
          } else {
            // placeholder since a widget cannot be null
            return const SizedBox();
          }
        }),
        Builder(builder: (context) {
          if (context.watch<UserModel>().isLogin) {
            return const MeDivider();
          } else {
            // placeholder since a widget cannot be null
            return const SizedBox();
          }
        }),
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
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
        ),
        child: Text(
          'Terms of Service',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer),
        ),
      ),
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

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 28 * pixel, 0, 8),
      child: Consumer<UserModel>(
        builder: (BuildContext context, UserModel value, Widget? child) {
          double pixel = MediaQuery.of(context).size.width / 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      width: 100 * pixel,
                      height: 100 * pixel,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                    ),
                    Image.asset(
                      'assets/images/me_nav_icon.png',
                      width: 85 * pixel,
                      height: 85 * pixel,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10 * pixel,
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
      ),
    );
  }
}
