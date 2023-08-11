//TODO:find better way do adapt different screen size

import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:fedcampus/view/health/healthcard.dart';

import '../pigeons/messages.g.dart';
import 'health/healthdate.dart';

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
    final host = DataApi();
    final d = await host.getData("distance", 20230811, 20230811);
    setState(() {
      dist = d[0]!.value.toString();
    });
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
          HealthCard(
            fem: fem,
            ffem: ffem,
            value: dist,
            name: "distance",
            imagePath: "assets/images/location.png",
            unit: null,
          ),
          SizedBox(
            height: 20 * fem,
          ),
          HealthCard(
              fem: fem,
              ffem: ffem,
              value: "0",
              name: "Stress",
              imagePath: "assets/images/meter.png",
              unit: null),
        ],
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
        HealthCard(
          fem: fem,
          ffem: ffem,
          name: "step",
          value: "100",
          imagePath: "assets/images/step.png",
          unit: null,
        ),
        SizedBox(
          height: 21 * fem,
        ),
        HealthCard(
          fem: fem,
          ffem: ffem,
          name: "calorie",
          value: "200",
          imagePath: 'assets/images/calorie.png',
          unit: "Kcal",
        ),
        SizedBox(
          height: 21 * fem,
        ),
        HealthCard(
          fem: fem,
          ffem: ffem,
          name: "intensity",
          value: "78",
          imagePath: 'assets/images/exercise.png',
          unit: "mins",
        ),
        SizedBox(
          height: 21 * fem,
        ),
        HealthCard(
          fem: fem,
          ffem: ffem,
          name: "Sleep",
          value: "81",
          imagePath: 'assets/images/sleep.png',
          unit: "points",
        ),
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
