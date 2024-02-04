import 'package:fedcampus/utility/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  late final String userGuide;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Feedback'),
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<String>(
        future: rootBundle.loadString(userApi.isAndroid
            ? 'doc/android_user_guide.md'
            : 'doc/ios_user_guide.md'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              styleSheet: MarkdownStyleSheet(textScaleFactor: 1.2),
              data: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return const Text('Error loading text');
          } else {
            return const CircularProgressIndicator(); // Or any loading indicator
          }
        },
      ),
    );
  }
}
