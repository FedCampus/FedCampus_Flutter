//TODO:find better way do adapt different screen size

import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Health extends StatefulWidget {
  const Health({
    super.key,
  });

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  DateTime dateTime = DateTime.now();
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    Provider.of<HealthDataModel>(context, listen: false).getData();
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
      Provider.of<HealthDataModel>(context, listen: false).date = datecode;
    });
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: EdgeInsets.fromLTRB(
              22 * pixel, 19 * pixel, 22 * pixel, 10 * pixel),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: LeftColumn(
                  date: dateTime,
                  onDateChange: updateDate,
                ),
              ),
              SizedBox(
                width: 22 * pixel,
              ),
              const Expanded(flex: 1, child: RightColumn()),
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
    required this.date,
    required this.onDateChange,
  });

  final DateTime date;
  final void Function(DateTime selectedDate) onDateChange;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Date(
            date: date,
            onDateChange: onDateChange,
          ),
          SizedBox(
            height: 20 * pixel,
          ),
          const Heart(),
          SizedBox(
            height: 20 * pixel,
          ),
          const Distance(),
          SizedBox(
            height: 20 * pixel,
          ),
          const Stress(),
        ],
      ),
    );
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Step(),
        SizedBox(
          height: 21 * pixel,
        ),
        const Calorie(),
        SizedBox(
          height: 21 * pixel,
        ),
        const IntenseExercise(),
        SizedBox(
          height: 21 * pixel,
        ),
        const Sleep(),
      ],
    );
  }
}

class Date extends StatefulWidget {
  const Date({
    super.key,
    required this.date,
    required this.onDateChange,
  });

  final DateTime date;
  final void Function(DateTime selectedDate) onDateChange;

  @override
  State<Date> createState() => _DateState();
}

class _DateState extends State<Date> {
  DateTime _date = DateTime.now();

  void change(DateTime dateTime) {
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
            content: CalendarDialog(
              onDateChange: change,
              primaryColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Confirm"),
                onPressed: () {
                  widget.onDateChange(_date);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(10 * pixel),
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
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          padding: EdgeInsets.fromLTRB(
              14 * pixel, 18 * pixel, 14 * pixel, 17 * pixel),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10 * pixel)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FedIcon(imagePath: 'assets/images/health_nav_icon.png'),
            SizedBox(
              width: 10 * pixel,
            ),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * pixel, 0 * pixel, 0 * pixel, 5 * pixel),
                    child: Text(
                      DateFormat.MMMd('en_US').format(widget.date),
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: pixel * 22,
                          shadows: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              offset: Offset(0 * pixel, 2 * pixel),
                              blurRadius: 1 * pixel,
                            ),
                          ]),
                    ),
                  ),
                  Text(
                    DateFormat.y('en_US').format(widget.date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: pixel * 17,
                    ),
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

class Heart extends StatelessWidget {
  const Heart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return FedCard(
        widget: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FedIcon(
              imagePath: 'assets/images/heart_rate.png',
            ),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Heart \nRate',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            SizedBox(
              height: 10 * pixel,
            ),
            const FedIcon(imagePath: 'assets/images/heart_rate_2.png'),
          ],
        ),
        SizedBox(
          width: 10 * pixel,
        ),
        Column(
          children: [
            Text(
                Provider.of<HealthDataModel>(context)
                        .healthData['restHeartRate']
                        ?.toStringAsFixed(2) ??
                    '0',
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
            SizedBox(
              height: 33 * pixel,
            ),
            Text(
                Provider.of<HealthDataModel>(context)
                        .healthData['exerciseHeartRate']
                        ?.toStringAsFixed(2) ??
                    '0',
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
          ],
        )
      ],
    ));
  }
}

class Distance extends StatelessWidget {
  const Distance({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    String displayText = Provider.of<HealthDataModel>(context)
            .healthData['distance']
            ?.toInt()
            .toString() ??
        '0';
    return FedCard(
      widget: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FedIcon(imagePath: 'assets/images/location.png'),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Distance',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            SizedBox(
              height: 9 * pixel,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  // https://stackoverflow.com/a/61748312
                  text: TextSpan(children: [
                    TextSpan(
                        text: displayText,
                        style: TextStyle(
                          fontFamily: 'Montserrat Alternates',
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: displayText.length < 6
                              ? pixel * 30
                              : pixel * (170 / displayText.length),
                        )),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(2, -2),
                        child: Text(
                          'm',
                          style: TextStyle(
                              fontFamily: 'Montserrat Alternates',
                              fontSize: displayText.length < 6
                                  ? pixel * 17
                                  : pixel * (90 / displayText.length),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ),
                      ),
                    )
                  ]),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Stress extends StatelessWidget {
  const Stress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return FedCard(
      widget: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const FedIcon(imagePath: 'assets/images/meter.png'),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Stress',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ]),
          SizedBox(
            width: 10 * pixel,
          ),
          Column(
            children: [
              Text(
                  Provider.of<HealthDataModel>(context)
                          .healthData['stress']
                          ?.toStringAsFixed(2) ??
                      '0',
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: pixel * 30,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)),
              Text('mmHg',
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: pixel * 15,
                      color: Theme.of(context).colorScheme.onPrimaryContainer))
            ],
          )
        ],
      ),
    );
  }
}

class Step extends StatelessWidget {
  const Step({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    String displayText = Provider.of<HealthDataModel>(context)
            .healthData['step']
            ?.toInt()
            .toString() ??
        '0';
    return FedCard(
        widget: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FedIcon(imagePath: 'assets/images/step.png'),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Step',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        SizedBox(
          width: 10 * pixel,
        ),
        Column(
          children: [
            Text(displayText,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: displayText.length < 5
                        ? pixel * 30
                        : pixel * (135 / displayText.length),
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
          ],
        )
      ],
    ));
  }
}

class Calorie extends StatelessWidget {
  const Calorie({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    String displayText = Provider.of<HealthDataModel>(context)
            .healthData['calorie']
            ?.toStringAsFixed(2) ??
        '0';
    return FedCard(
        widget: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FedIcon(imagePath: 'assets/images/calorie.png'),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Calorie',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        SizedBox(
          width: 10 * pixel,
        ),
        Column(
          children: [
            Text(displayText,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: displayText.length < 6
                        ? pixel * 30
                        : pixel * (145 / displayText.length),
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
          ],
        )
      ],
    ));
  }
}

class IntenseExercise extends StatelessWidget {
  const IntenseExercise({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return FedCard(
        widget: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FedIcon(
              imagePath: 'assets/images/exercise.png',
              width: 52 * pixel,
              height: 63 * pixel,
            ),
            SizedBox(
              height: 10 * pixel,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  3 * pixel, 0 * pixel, 0 * pixel, 0 * pixel),
              constraints: BoxConstraints(
                maxWidth: 64 * pixel,
              ),
              child: Text(
                'Intense \nExercise',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 10 * pixel,
        ),
        Column(
          children: [
            Text(
                Provider.of<HealthDataModel>(context)
                        .healthData['intensity']
                        ?.toStringAsFixed(2) ??
                    '0',
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
            Text('min',
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer))
          ],
        )
      ],
    ));
  }
}

class Sleep extends StatelessWidget {
  const Sleep({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return FedCard(
      widget: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const FedIcon(
                imagePath: 'assets/images/sleep.png',
              ),
              SizedBox(
                height: 10 * pixel,
              ),
              Text(
                'Sleep',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
          SizedBox(
            width: 10 * pixel,
          ),
          Column(
            children: [
              Text(
                  Provider.of<HealthDataModel>(context)
                          .healthData['sleepEfficiency']
                          ?.toStringAsFixed(2) ??
                      '0',
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: pixel * 30,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ],
          )
        ],
      ),
    );
  }
}
