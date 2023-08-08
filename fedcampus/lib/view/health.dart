//TODO:find better way do adapt different screen size
import 'dart:convert';

import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/test_api.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';

class Health extends StatefulWidget {
  const Health({
    super.key,
  });

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  DateTime dateTime = DateTime.now();
  String dist = 'loading';
  @override
  void initState() {
    super.initState();
    getDistance();
  }

  Future<void> refresh() async {
    getDistance();
  }

  getDistance() async {
    String responseBody;
    try {
      responseBody = (await fetchDistance()).body;
    } catch (e) {
      responseBody = '[{"status": "fail"}]';
    }
    final data = jsonDecode(responseBody);
    logger.d(data);
    if (mounted) {
      setState(() {
        try {
          int d = int.parse(data['distance']);
          dist = d >= 10000 ? '${(d / 10000).toStringAsFixed(2)}km' : '${d}m';
        } catch (e) {
          dist = 'loading';
        }
      });
    } else {
      logger.d("setState() called after dispose(), aborted");
    }
  }

  updateDate(DateTime selectedDate) {
    setState(() {
      dateTime = selectedDate;
      // logger.d(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: EdgeInsets.fromLTRB(26 * fem, 19 * fem, 26 * fem, 11 * fem),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: LeftColumn(
                  fem: fem,
                  ffem: ffem,
                  date: dateTime,
                  dist: dist,
                  onDateChange: updateDate,
                ),
              ),
              SizedBox(
                width: 22 * fem,
              ),
              Expanded(flex: 1, child: RightColumn(fem: fem, ffem: ffem)),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftColumn extends StatelessWidget {
  const LeftColumn({
    super.key,
    required this.fem,
    required this.ffem,
    required this.date,
    required this.dist,
    required this.onDateChange,
  });

  final double fem;
  final double ffem;
  final DateTime date;
  final String dist;
  final void Function(DateTime selectedDate) onDateChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Date(
            fem: fem,
            date: date,
            onDateChange: onDateChange,
          ),
          SizedBox(
            height: 20 * fem,
          ),
          // Heartrate(fem: fem, ffem: ffem),
          Heart(fem: fem, ffem: ffem),
          SizedBox(
            height: 20 * fem,
          ),
          Distance(fem: fem, ffem: ffem, distance: dist),
          SizedBox(
            height: 20 * fem,
          ),
          Stress(fem: fem, ffem: ffem),
        ],
      ),
    );
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.date,
    required this.onDateChange,
  });

  final double fem;
  final DateTime date;
  final void Function(DateTime selectedDate) onDateChange;

  @override
  Widget build(BuildContext context) {
    Future<bool?> calendarDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select a day"),
            content: CalendarDialog(
              onDateChange: onDateChange,
              primaryColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
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
        onPressed: () => Future.delayed(const Duration(milliseconds: 140))
            .then((value) => calendarDialog()),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.fromLTRB(14 * fem, 18 * fem, 14 * fem, 17 * fem),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FedIcon(fem: fem, imagePath: 'assets/images/health_nav_icon.png'),
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
                      '${date.month}/${date.day}',
                      style: TextStyle(
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

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Step(fem: fem, ffem: ffem),
        SizedBox(
          height: 21 * fem,
        ),
        Calorie(fem: fem, ffem: ffem),
        SizedBox(
          height: 21 * fem,
        ),
        IntenseExercise(fem: fem, ffem: ffem),
        SizedBox(
          height: 21 * fem,
        ),
        Sleep(fem: fem, ffem: ffem),
      ],
    );
  }
}

class Heart extends StatelessWidget {
  const Heart({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
        fem: fem,
        ffem: ffem,
        widget: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FedIcon(
                  fem: fem,
                  imagePath: 'assets/images/heart_rate.png',
                ),
                SizedBox(
                  height: 11 * fem,
                ),
                Text(
                  'Heart \nRate',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                SizedBox(
                  height: 11 * fem,
                ),
                FedIcon(fem: fem, imagePath: 'assets/images/heart_rate_2.png'),
              ],
            ),
          ],
        ));
  }
}

class Step extends StatelessWidget {
  const Step({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
        fem: fem,
        ffem: ffem,
        widget: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FedIcon(fem: fem, imagePath: 'assets/images/step.png'),
                SizedBox(
                  height: 11 * fem,
                ),
                Text(
                  'Step',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
            SizedBox(
              width: 11 * fem,
            ),
            Column(
              children: [
                Text('78',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primaryContainer)),
                Text('78',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primaryContainer))
              ],
            )
          ],
        ));
  }
}

class Sleep extends StatelessWidget {
  const Sleep({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
      fem: fem,
      ffem: ffem,
      widget: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FedIcon(
                fem: fem,
                imagePath: 'assets/images/sleep.png',
              ),
              SizedBox(
                height: 11 * fem,
              ),
              Text(
                // sleepoPf (30:137)
                'Sleep',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IntenseExercise extends StatelessWidget {
  const IntenseExercise({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
        fem: fem,
        ffem: ffem,
        widget: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FedIcon(
                  fem: fem,
                  imagePath: 'assets/images/exercise.png',
                  width: 52,
                  height: 63,
                ),
                SizedBox(
                  height: 11 * fem,
                ),
                Container(
                  margin:
                      EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
                  constraints: BoxConstraints(
                    maxWidth: 64 * fem,
                  ),
                  child: Text(
                    'Intense \nExercise',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 11 * fem,
            ),
            Column(
              children: [
                Text('78',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primaryContainer)),
                Text('min',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primaryContainer))
              ],
            )
          ],
        ));
  }
}

class Calorie extends StatelessWidget {
  const Calorie({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
        fem: fem,
        ffem: ffem,
        widget: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FedIcon(fem: fem, imagePath: 'assets/images/calorie.png'),
                SizedBox(
                  height: 11 * fem,
                ),
                Text(
                  // calorieFSh (30:134)
                  'Calorie',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
            SizedBox(
              width: 11 * fem,
            ),
            Column(
              children: [
                Text('78',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primaryContainer)),
                Text('f8',
                    style: TextStyle(
                        fontFamily: 'Montserrat Alternates',
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primaryContainer))
              ],
            )
          ],
        ));
  }
}

class Stress extends StatelessWidget {
  const Stress({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return FedCard(
      fem: fem,
      ffem: ffem,
      widget: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            FedIcon(fem: fem, imagePath: 'assets/images/meter.png'),
            SizedBox(
              height: 11 * fem,
            ),
            Text(
              // stressm6H (30:138)
              'Stress',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          ]),
          SizedBox(
            width: 11 * fem,
          ),
          Column(
            children: [
              Text('78',
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.primaryContainer)),
              Text('mmHg',
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer))
            ],
          )
        ],
      ),
    );
  }
}

class Distance extends StatelessWidget {
  const Distance({
    super.key,
    required this.fem,
    required this.ffem,
    required this.distance,
  });

  final double fem;
  final double ffem;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return FedCard(
      fem: fem,
      ffem: ffem,
      widget: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FedIcon(fem: fem, imagePath: 'assets/images/location.png'),
              SizedBox(
                height: 10 * fem,
              ),
              Text(
                'Distance',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ],
          ),
          SizedBox(
            width: 11 * fem,
          ),
          Column(
            children: [
              Text(distance,
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer)),
            ],
          )
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.fem,
  });

  final double fem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 37 * fem),
      padding: EdgeInsets.fromLTRB(118 * fem, 44 * fem, 112 * fem, 11 * fem),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Align(
        // 2rD (36:231)
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 160 * fem,
          height: 34 * fem,
          child: Image.asset(
            'assets/images/title.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
