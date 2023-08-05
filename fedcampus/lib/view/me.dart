import 'package:fedcampus/view/activity.dart';
import 'package:fedcampus/view/setting.dart';
import 'package:flutter/material.dart';

class Me extends StatefulWidget {
  const Me({
    super.key,
  });

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  @override
  Widget build(BuildContext context) {
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
          text: 'Preference',
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
        ),
        MeDivider(),
        // MeText(text: 'Authentication'),
        // MeDivider(),
        // MeText(text: 'Authentication'),
        // MeDivider(),
        // MeText(text: 'About'),
        // MeDivider(),
        // MeText(text: 'Help & feedback'),
        // MeDivider(),
        BottomText(),
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
      height: 20,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: callback,
          child: Text(
            text,
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.surfaceVariant),
            textAlign: TextAlign.center,
          ),
        ));
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.date,
    required this.steps,
  });

  final String date;
  final String steps;

  @override
  Widget build(BuildContext context) {
    double logicalWidth = MediaQuery.of(context).size.width;
    // logger.d(logicalWidth / 10);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/step_activity.png',
            fit: BoxFit.contain,
            height: logicalWidth / 6,
            width: logicalWidth / 6,
          ),
          Text(
            'John Doe',
            style: TextStyle(
                fontSize: 30, color: Theme.of(context).colorScheme.primary),
          ),
          Text(
            'johndoe123@dukekunshan.edu.cn',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.surfaceVariant),
          ),
        ],
      ),
    );
  }
}
