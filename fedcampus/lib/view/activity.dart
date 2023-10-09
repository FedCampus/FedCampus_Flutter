import 'dart:async';

import 'package:fedcampus/models/activity_data_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Activity extends StatefulWidget {
  const Activity({
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final entries = [
    {
      "entry_name": "step_time",
      "icon_path": "assets/svg/step.svg",
      "unit": "min"
    },
    {
      "entry_name": "distance",
      "icon_path": "assets/svg/distance.svg",
      "unit": "meters"
    },
    {
      "entry_name": "calorie",
      "icon_path": "assets/svg/calorie.svg",
      "unit": "kcals"
    },
    {
      "entry_name": "intensity",
      "icon_path": "assets/svg/exercise.svg",
      "unit": "min"
    },
    {
      "entry_name": "stress",
      "icon_path": "assets/svg/stress.svg",
      "unit": "stress"
    },
    {
      "entry_name": "step",
      "icon_path":
          "assets/svg/step.svg", // TODO: distinguish step and step_time icon
      "unit": "steps"
    },
    {
      "entry_name": "sleep_efficiency",
      "icon_path": "assets/svg/sleep.svg",
      "unit": "effi"
    },
  ];

  final int maxCount = 8;
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.parse(
        Provider.of<ActivityDataModel>(context, listen: false).date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  Future<void> refresh({bool forcedRefresh = false}) async {
    Provider.of<ActivityDataModel>(context, listen: false)
        .getActivityData(forcedRefresh: forcedRefresh);
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    pollLoading(loadingDialog);
  }

  updateDate(DateTime selectedDate) {
    setState(() {
      dateTime = selectedDate;
      logger.i(selectedDate);
    });
    String datecode = (selectedDate.year * 10000 +
            selectedDate.month * 100 +
            selectedDate.day)
        .toString();
    Provider.of<ActivityDataModel>(context, listen: false).date = datecode;
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    pollLoading(loadingDialog);
  }

  void pollLoading(LoadingDialog loadingDialog) {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (loadingDialog.cancelled) timer.cancel();
      if (!Provider.of<ActivityDataModel>(context, listen: false).loading) {
        timer.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadingDialog.cancel();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return RefreshIndicator(
      onRefresh: () => refresh(forcedRefresh: true),
      child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 11),
          itemCount: 8,
          padding: EdgeInsets.all(20 * pixel),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Date(
                onDateChange: updateDate,
                date: dateTime,
              );
            }
            // https://book.flutterchina.club/chapter6/listview.html
            if (index == maxCount - 1) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(
                    16 * pixel, 16 * pixel, 8 * pixel, 16 * pixel),
                child: const Text(
                  "no more data available",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            // the use of IntrinsicHeight is explained here:
            // because ActivityCard() is flexible vertically, when placed in ListView, the height becomes an issue
            // IntrinsicHeight forces the column to be exactly as big as its contents
            // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
            if (Provider.of<ActivityDataModel>(context).loading) {
              return IntrinsicHeight(
                  child: ActivityCard(
                rank: '-',
                value: '-',
                unit: entries[index - 1]['unit'] ?? "unit",
                iconPath:
                    entries[index - 1]['icon_path'] ?? "assets/svg/sleep.svg",
              ));
            } else {
              return IntrinsicHeight(
                  child: ActivityCard(
                rank: Provider.of<ActivityDataModel>(context)
                    .activityData[entries[index - 1]['entry_name']]["rank"]
                    .toString(),
                value: Provider.of<ActivityDataModel>(context)
                    .activityData[entries[index - 1]['entry_name']]["average"]
                    .toStringAsFixed(2),
                unit: entries[index - 1]['unit'] ?? "unit",
                iconPath:
                    entries[index - 1]['icon_path'] ?? "assets/svg/sleep.svg",
              ));
            }
          }),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.rank,
    required this.value,
    required this.unit,
    required this.iconPath,
  });

  final String rank;
  final String value;
  final String unit;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return FedCard(
        left: 18,
        right: 18,
        widget: Row(
          children: <Widget>[
            // As stated in https://api.flutter.dev/flutter/widgets/Image/height.html,
            // it is recommended to specify the image size (in order to avoid
            // widget size suddenly changes when the app just loads another page)
            SvgIcon(
              imagePath: iconPath,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.secondaryContainer,
                  BlendMode.srcIn),
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              flex: 9,
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontFamily: 'Montserrat Alternates',
                              fontSize: value.length < 8
                                  ? pixel * 30
                                  : pixel * (200 / value.length),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          unit,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontFamily: 'Montserrat Alternates',
                              fontSize: pixel * 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Expanded(
              flex: 5,
              child: Text(
                rank,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ));
  }
}

class Date extends StatefulWidget {
  const Date({
    super.key,
    required this.onDateChange,
    required this.date,
  });

  final void Function(DateTime) onDateChange;
  final DateTime date;

  @override
  State<Date> createState() => _DateState();
}

class _DateState extends State<Date> {
  DateTime _date = DateTime.now();

  void _changeWidgetDate(DateTime dateTime) {
    _date = dateTime;
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    Future<bool?> calendarDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select a day"),
            contentPadding:
                EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
            content: SizedBox(
              height: 271 * pixel,
              width: 300 * pixel,
              child: CalendarDialog(
                onDateChange: _changeWidgetDate,
                primaryColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDateChange(_date);
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      height: 80 * pixel,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(15 * pixel),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, -1 * pixel),
            blurRadius: 1 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => calendarDialog(),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          padding: EdgeInsets.fromLTRB(
              40 * pixel, 12 * pixel, 40 * pixel, 12 * pixel),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15 * pixel)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FedIcon(
              imagePath: 'assets/images/activity_nav_icon.png',
              height: 52 * pixel,
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
                        DateFormat.MMMd('en_US').format(widget.date),
                        style: TextStyle(
                            fontSize: pixel * 22,
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                offset: Offset(0 * pixel, 2 * pixel),
                                blurRadius: 1 * pixel,
                              ),
                            ],
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Text(
                        DateFormat.E('en_US').format(widget.date),
                        style: TextStyle(
                            fontSize: pixel * 22,
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                offset: Offset(0 * pixel, 2 * pixel),
                                blurRadius: 1 * pixel,
                              ),
                            ],
                            color: Theme.of(context).colorScheme.secondary),
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
                        color: Theme.of(context).colorScheme.secondary),
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
