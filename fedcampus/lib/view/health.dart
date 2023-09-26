//TODO:find better way do adapt different screen size

import 'dart:async';

import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/chart.dart';
import 'package:fedcampus/view/me/signin.dart';
import 'package:fedcampus/utility/global.dart';
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
    dateTime = DateTime.parse(
        Provider.of<HealthDataModel>(context, listen: false).date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void detectFirstTimeLogin() async {
    if (userApi.prefs.getBool("login") == null) {
      // jump to login page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    }
  }

  void _sendLastDayData() async {
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(
        int.parse(Provider.of<HealthDataModel>(context, listen: false).date));
  }

  Future<void> refresh({bool forcedRefresh = false}) async {
    Provider.of<HealthDataModel>(context, listen: false)
        .getData(forcedRefresh: forcedRefresh);
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    pollLoading(loadingDialog);
    _sendLastDayData();
  }

  updateDate(DateTime selectedDate) {
    setState(() {
      dateTime = selectedDate;
    });
    logger.d(selectedDate);
    int datecode = (selectedDate.year * 10000 +
        selectedDate.month * 100 +
        selectedDate.day);
    Provider.of<HealthDataModel>(context, listen: false).date =
        datecode.toString();
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    pollLoading(loadingDialog);
  }

  void pollLoading(LoadingDialog loadingDialog) {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (loadingDialog.cancelled) timer.cancel();
      if (!Provider.of<HealthDataModel>(context, listen: false).loading) {
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
        child: LayoutBuilder(builder: (context, constraints) {
          // height of SingleChildScrollView is unconstrained, so use the height of grandparents
          return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: constraints.maxHeight,
                padding: EdgeInsets.fromLTRB(
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
              ));
        }));
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

  void _changeWidgetDate(DateTime dateTime) {
    _date = dateTime;
  }

  Future<bool?> calendarDialog() {
    double pixel = MediaQuery.of(context).size.width / 400;
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
              primaryColor: Theme.of(context).colorScheme.primaryContainer,
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

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
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
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                      color: Theme.of(context).colorScheme.primaryContainer,
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
            SvgIcon(
              imagePath: 'assets/svg/heart_rate.svg',
              width: 45,
              height: 45,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
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
            SvgIcon(
              imagePath: 'assets/svg/heart_rate_2.svg',
              width: 45,
              height: 45,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            Text(
                formatNum(
                  Provider.of<HealthDataModel>(context)
                      .healthData['rest_heart_rate'],
                  decimalPoints: 1,
                  loading: Provider.of<HealthDataModel>(context).loading,
                ),
                style: montserratAlternatesTextStyle(pixel * 30,
                    Theme.of(context).colorScheme.primaryContainer)),
            SizedBox(
              height: 33 * pixel,
            ),
            Text(
                formatNum(
                  Provider.of<HealthDataModel>(context)
                      .healthData['exercise_heart_rate'],
                  decimalPoints: 1,
                  loading: Provider.of<HealthDataModel>(context).loading,
                ),
                style: montserratAlternatesTextStyle(pixel * 30,
                    Theme.of(context).colorScheme.primaryContainer)),
          ],
        ),
        const Spacer(),
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
    String displayText = formatNum(
      Provider.of<HealthDataModel>(context).healthData['distance'],
      decimalPoints: 1,
      loading: Provider.of<HealthDataModel>(context).loading,
    );
    return FedCard(
      widget: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgIcon(
              imagePath: 'assets/svg/distance.svg',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
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
                        style: montserratAlternatesTextStyle(
                            displayText.length < 6
                                ? pixel * 30
                                : pixel * (170 / displayText.length),
                            Theme.of(context).colorScheme.primaryContainer)),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(2, -2),
                        child: Text('m',
                            style: montserratAlternatesTextStyle(
                                displayText.length < 6
                                    ? pixel * 17
                                    : pixel * (90 / displayText.length),
                                Theme.of(context)
                                    .colorScheme
                                    .primaryContainer)),
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
    String displayText = formatNum(
      Provider.of<HealthDataModel>(context).healthData['stress'],
      loading: Provider.of<HealthDataModel>(context).loading,
    );
    return FedCard(
      widget: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SvgIcon(
              imagePath: 'assets/svg/stress.svg',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Stress',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ]),
          const Spacer(),
          Column(
            children: [
              Text(displayText,
                  style: montserratAlternatesTextStyle(
                      displayText.length < 6
                          ? pixel * 30
                          : pixel * (155 / displayText.length),
                      Theme.of(context).colorScheme.primaryContainer)),
              Text('stress',
                  style: montserratAlternatesTextStyle(pixel * 15,
                      Theme.of(context).colorScheme.primaryContainer))
            ],
          ),
          const Spacer(),
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
    String displayText = formatNum(
      Provider.of<HealthDataModel>(context).healthData['step'],
      decimalPoints: 0,
      loading: Provider.of<HealthDataModel>(context).loading,
    );
    return ClickableFedCard(
      widget: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgIcon(
                imagePath: 'assets/svg/step.svg',
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primaryContainer,
                    BlendMode.srcIn),
              ),
              SizedBox(
                height: 10 * pixel,
              ),
              Text(
                'Step',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Text(displayText,
                  style: montserratAlternatesTextStyle(
                      displayText.length < 5
                          ? pixel * 30
                          : pixel * (135 / displayText.length),
                      Theme.of(context).colorScheme.primaryContainer)),
            ],
          ),
          const Spacer(),
        ],
      ),
      callBack: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailsChart()),
        );
      },
    );
  }
}

class Calorie extends StatelessWidget {
  const Calorie({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    String displayText = formatNum(
      Provider.of<HealthDataModel>(context).healthData['calorie'],
      loading: Provider.of<HealthDataModel>(context).loading,
    );
    return FedCard(
        widget: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgIcon(
              imagePath: 'assets/svg/calorie.svg',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
            SizedBox(
              height: 10 * pixel,
            ),
            Text(
              'Calorie',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            Text(displayText,
                style: montserratAlternatesTextStyle(
                    displayText.length < 6
                        ? pixel * 30
                        : pixel * (145 / displayText.length),
                    Theme.of(context).colorScheme.primaryContainer)),
          ],
        ),
        const Spacer(),
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
    String displayText = formatNum(
      Provider.of<HealthDataModel>(context).healthData['intensity'],
      decimalPoints: 1,
      loading: Provider.of<HealthDataModel>(context).loading,
    );
    return FedCard(
        widget: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgIcon(
              imagePath: 'assets/svg/exercise.svg',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
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
        const Spacer(),
        Column(
          children: [
            Text(displayText,
                style: montserratAlternatesTextStyle(
                    displayText.length < 6
                        ? pixel * 30
                        : pixel * (145 / displayText.length),
                    Theme.of(context).colorScheme.primaryContainer)),
            Text('min',
                style: montserratAlternatesTextStyle(pixel * 20,
                    Theme.of(context).colorScheme.primaryContainer)),
          ],
        ),
        const Spacer(),
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
              SvgIcon(
                imagePath: 'assets/svg/sleep.svg',
                width: 58,
                height: 58,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primaryContainer,
                    BlendMode.srcIn),
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
          const Spacer(),
          Column(
            children: [
              Text(
                  formatNum(
                    Provider.of<HealthDataModel>(context)
                        .healthData['sleep_efficiency'],
                    loading: Provider.of<HealthDataModel>(context).loading,
                  ),
                  style: montserratAlternatesTextStyle(pixel * 30,
                      Theme.of(context).colorScheme.primaryContainer)),
              Text('effi',
                  style: montserratAlternatesTextStyle(pixel * 20,
                      Theme.of(context).colorScheme.primaryContainer)),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

String formatNum(double? num, {decimalPoints = 2, loading = false}) {
  if (loading || num == null) return '-';
  String s = num.toStringAsFixed(decimalPoints);
  return s;
}

TextStyle montserratAlternatesTextStyle(double fontSize, Color color) {
  return TextStyle(
    fontFamily: 'Montserrat Alternates',
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.bold,
  );
}
