import 'dart:async';

import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/http_api.dart';
import 'package:fedcampus/view/me/about.dart';
import 'package:fedcampus/view/me/account_settings.dart';
import 'package:fedcampus/view/me/privacy_policy.dart';
import 'package:fedcampus/view/training_detail.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fedcampus/view/me/preferences.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/me/signin.dart';

import 'me/help.dart';

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

  void _logOut() async {
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    try {
      await HTTPApi.logout().timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      loadingDialog.showIfDialogNotCancelled(
          e, "Please check your internet connection");
      return;
    } on Exception catch (e) {
      loadingDialog.showIfDialogNotCancelled(e, e.getMessage);
      return;
    }
    if (mounted && !loadingDialog.cancelled) {
      Provider.of<UserModel>(context, listen: false).setLogin = false;
      showToastMessage('you successfully logged out', context);
    }
    loadingDialog.cancel();
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
        WidgetListWithDivider(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          children: [
            // A few words on this design: I actually do not like to use `if` in this way:
            // this is weird, by using if as an expression, I can conditionally include (evaluate) some element in the list [] literal
            // I would prefer ternary expression, but in that way I have to include an empty container, which problematic for [ListTile]
            // Using `if` is the most succinct way, otherwise I would have to turn the [] list literal into another method handling the logic for building the list
            if (!context.watch<UserModel>().isLogin)
              MeText(
                text: 'Sign in',
                callback: () => _toSignInPage(),
              ),
            // if (context.watch<UserModel>().isLogin)
            MeText(
              text: 'Account Settings',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AccountSettings()),
              ),
            ),
            MeText(
              text: 'Preferences',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Preferences()),
              ),
            ),
            if (userApi.healthDataHandler.canAuth)
              MeText(
                text: 'Authenticate',
                callback: _healthServiceAuthenticate,
              ),
            if (userApi.healthDataHandler.canCancelAuth)
              MeText(
                text: 'Cancel authentication',
                callback: _healthServiceCancel,
              ),
            MeText(
              text: 'About',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              ),
            ),
            MeText(
              text: 'Help & Feedback',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Help()),
              ),
            ),
            MeText(
              text: 'Log Output',
              callback: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainingDetail()),
              ),
            ),
            if (context.watch<UserModel>().isLogin)
              MeText(
                text: 'Sign out',
                callback: _logOut,
              ),
            const BottomText(),
          ],
        ),
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

class MeText extends StatelessWidget {
  const MeText({
    super.key,
    required this.text,
    required this.callback,
    this.textStyle,
  });

  final String text;
  final void Function() callback;
  final TextStyle? textStyle;

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
          style: textStyle ??
              TextStyle(
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
