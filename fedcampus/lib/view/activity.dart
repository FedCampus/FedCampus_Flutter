import 'dart:convert';

import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/test_api.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class Activity extends StatefulWidget {
  const Activity({
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List steps = [{}];
  int currentCount = 10;
  final int maxCount = 50;
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    getSteps();
  }

  Future<void> refresh() async {
    getSteps();
  }

  getSteps() async {
    String responseBody;
    List data;
    try {
      responseBody = (await fetchSteps()).body;
    } catch (e) {
      responseBody = '[{"status": "fail"}]';
    }
    data = jsonDecode(responseBody);
    // logger.d(data);
    if (mounted) {
      setState(() {
        steps = data;
        logger.d(steps);
      });
    }
  }

  updateDate(DateTime selectedDate) {
    setState(() {
      dateTime = selectedDate;
      // logger.d(selectedDate);
    });
  }

  // https://stackoverflow.com/questions/59681328/safe-way-to-access-list-index
  T? tryGet<T>(List<T> list, int index) =>
      index < 0 || index >= list.length ? null : list[index];

  getDate(int index) {
    if (tryGet(steps, index) != null) return tryGet(steps, index)["date"];
    return "loading";
  }

  getStep(int index) {
    if (tryGet(steps, index) != null) return tryGet(steps, index)["step"];
    return "loading";
  }

  loadMore() {
    Future.delayed(const Duration(seconds: 1)).then((e) => {
          setState(() {
            currentCount += 10;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    double logicalWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 11),
          itemCount: currentCount,
          padding: EdgeInsets.all(logicalWidth / 20),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Date(
                fem: 1,
                onDateChange: updateDate,
                date: dateTime,
              );
            }
            // https://book.flutterchina.club/chapter6/listview.html
            if (index == maxCount - 1) {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "no more data available",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            if (index == currentCount - 1) {
              // https://stackoverflow.com/a/59478165
              SchedulerBinding.instance.addPostFrameCallback((_) {
                loadMore();
              });
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            }
            // the use of IntrinsicHeight is explained here:
            // because ActivityCard() is flexible vertically, when placed in ListView, the height becomes an issue
            // IntrinsicHeight forces the column to be exactly as big as its contents
            // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
            return IntrinsicHeight(
                child:
                    ActivityCard(date: getDate(index), steps: getStep(index)));
          }),
    );
  }
}

class FedIcon extends StatelessWidget {
  const FedIcon({
    super.key,
    required this.imagePath,
    this.width = 48,
    this.height = 39,
  });

  final String imagePath;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      height: height,
      width: width,
    );
  }
}

class FedCard extends StatelessWidget {
  const FedCard({
    super.key,
    required this.smallSize,
    required this.widget,
  });
  final double smallSize;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          14 * smallSize, 18 * smallSize, 14 * smallSize, 17 * smallSize),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(24 * smallSize),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * smallSize, 4 * smallSize),
            blurRadius: 2 * smallSize,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * smallSize, -1 * smallSize),
            blurRadius: 1 * smallSize,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * smallSize, 4 * smallSize),
            blurRadius: 2 * smallSize,
          ),
        ],
      ),
      child: widget,
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
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
    return FedCard(
        smallSize: logicalWidth / 360,
        widget: Row(
          children: <Widget>[
            // As stated in https://api.flutter.dev/flutter/widgets/Image/height.html,
            // it is recommended to specify the image size (in order to avoid
            // widget size suddenly changes when the app just loads another page)
            Image.asset(
              'assets/images/step_activity.png',
              fit: BoxFit.contain,
              height: logicalWidth / 6,
              width: logicalWidth / 6,
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 7,
              child: Text(
                steps,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'steps',
                      style: TextStyle(
                          fontFamily: 'Montserrat Alternates',
                          fontSize: 20,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 7,
              child: Text(
                date,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.secondaryContainer),
              ),
            ),
          ],
        ));
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.onDateChange,
    required this.date,
  });

  final double fem;
  final void Function(DateTime) onDateChange;
  final DateTime date;

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
              primaryColor: Theme.of(context).colorScheme.secondaryContainer,
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
      height: 80,
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
        onPressed: () => Future.delayed(const Duration(milliseconds: 140))
            .then((value) => calendarDialog()),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          padding: EdgeInsets.fromLTRB(40 * fem, 12 * fem, 40 * fem, 12 * fem),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const FedIcon(
              imagePath: 'assets/images/activity_nav_icon.png',
              height: 52,
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Text(
                        DateFormat.MMMd('en_US').format(date),
                        style: TextStyle(
                            fontSize: 22,
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                offset: Offset(0 * fem, 2 * fem),
                                blurRadius: 1,
                              ),
                            ],
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Text(
                        DateFormat.E('en_US').format(date),
                        style: TextStyle(
                            fontSize: 22,
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                offset: Offset(0 * fem, 2 * fem),
                                blurRadius: 1,
                              ),
                            ],
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  const Expanded(
                    flex: 3,
                    child: SizedBox(),
                  ),
                  Text(
                    '2023',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
