import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 11),
        itemCount: 20,
        padding: const EdgeInsets.fromLTRB(11, 13, 11, 13),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Date(fem: 1, callback: () => {});
          }
          return const ActivityCard();
        });
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FedCard(
        fem: 1,
        ffem: 1,
        widget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FedIcon(fem: 1, imagePath: 'assets/images/step_activity.png'),
            const SizedBox(
              width: 16,
            ),
            Text(
              '1111',
              style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
            const SizedBox(width: 22),
            Text(
              '88/88',
              style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.secondaryContainer),
            ),
          ],
        ));
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.callback,
  });

  final double fem;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, -1 * fem),
            blurRadius: 1 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
          ),
        ],
      ),
      child: TextButton(
        onPressed: callback,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          padding: EdgeInsets.fromLTRB(40 * fem, 18 * fem, 40 * fem, 17 * fem),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FedIcon(fem: fem, imagePath: 'assets/images/activity_nav_icon.png'),
            SizedBox(
              width: 11 * fem,
            ),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
                    child: Text(
                      'Jan 1',
                      style: TextStyle(
                          fontSize: 20,
                          shadows: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              offset: Offset(0 * fem, 2 * fem),
                              blurRadius: 1,
                            ),
                          ],
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  Text(
                    '2023',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
