
import 'package:fedcampus/view/train_app.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:flutter/material.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/title.png',
            height: 35,
          ),
        ),
        body: Center(
          child: Column(children: [
            ElevatedButton(
              child: const Text('Open training page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainApp()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Open Health page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavigator()),
                );
              },
            ),
          ]),
        ),
      );

}
