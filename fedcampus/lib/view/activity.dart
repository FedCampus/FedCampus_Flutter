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
      "icon_path": "assets/images/step.png",
      "unit": "min"
    },
    {
      "entry_name": "distance",
      "icon_path": "assets/images/location.png",
      "unit": "meters"
    },
    {
      "entry_name": "calorie",
      "icon_path": "assets/images/calorie.png",
      "unit": "kcals"
    },
    {
      "entry_name": "intensity",
      "icon_path": "assets/images/exercise.png",
      "unit": "min"
    },
    {
      "entry_name": "stress",
      "icon_path": "assets/images/meter.png",
      "unit": "mmHg"
    },
    {
      "entry_name": "step",
      "icon_path":
          "assets/images/step.png", // TODO: distinguish step and step_time icon
      "unit": "steps"
    },
    {
      "entry_name": "sleep_efficiency",
      "icon_path": "assets/images/sleep.png",
      "unit": "effi"
    },
  ];

  final int maxCount = 8;
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    await Provider.of<ActivityDataModel>(context, listen: false)
        .getActivityData();
  }

  updateDate(DateTime selectedDate) {
    setState(() {
      dateTime = selectedDate;
      logger.d(selectedDate);
      String month = selectedDate.month.toString();
      if (month.length < 2) month = '0$month';
      String day = selectedDate.day.toString();
      if (day.length < 2) day = '0$day';
      String datecode = '${selectedDate.year}$month$day';
      Provider.of<ActivityDataModel>(context, listen: false).date = datecode;
    });
  }

  // https://stackoverflow.com/questions/59681328/safe-way-to-access-list-index
  T? tryGet<T>(List<T> list, int index) =>
      index < 0 || index >= list.length ? null : list[index];

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return RefreshIndicator(
      onRefresh: refresh,
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
            return IntrinsicHeight(
                child: ActivityCard(
              rank: Provider.of<ActivityDataModel>(context)
                  .activityData[entries[index - 1]['entry_name']]["rank"]
                  .toString(),
              value: Provider.of<ActivityDataModel>(context)
                  .activityData[entries[index - 1]['entry_name']]["average"]
                  .toString(),
              unit: entries[index - 1]['unit'] ?? "unit",
              iconPath:
                  entries[index - 1]['icon_path'] ?? "assets/images/sleep.png",
            ));
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
        widget: Row(
      children: <Widget>[
        // As stated in https://api.flutter.dev/flutter/widgets/Image/height.html,
        // it is recommended to specify the image size (in order to avoid
        // widget size suddenly changes when the app just loads another page)
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Image.asset(
          iconPath,
          fit: BoxFit.contain,
          height: pixel * 56,
          width: pixel * 56,
        ),
        const Expanded(
          flex: 2,
          child: SizedBox(),
        ),
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: TextStyle(
                fontFamily: 'Montserrat Alternates',
                fontSize: pixel * 30,
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: <Widget>[
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  unit,
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: pixel * 20,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
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
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
      ],
    ));
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.onDateChange,
    required this.date,
  });

  final void Function(DateTime) onDateChange;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    Future<bool?> calendarDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: const Text("Select a day"),
            content: Container(
              width: 200.0,
              height: 200.0,
              child: CalendarDialog(
                onDateChange: onDateChange,
                primaryColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
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
                        DateFormat.MMMd('en_US').format(date),
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
                        DateFormat.E('en_US').format(date),
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
