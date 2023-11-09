//TODO:find better way do adapt different screen size

import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utility/event_bus.dart';
import '../utility/global.dart';

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

  void _sendLastDayData() async {
    var dw = DataWrapper();
    dw.getDayDataAndSendAndTrain(
        int.parse(Provider.of<HealthDataModel>(context, listen: false).date));
  }

  Future<void> refresh({bool forcedRefresh = false}) async {
    Provider.of<HealthDataModel>(context, listen: false)
        .requestAllData(forcedRefresh: forcedRefresh);
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    bus.on("loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
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
    bus.on("loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return RefreshIndicator(
      onRefresh: () => refresh(forcedRefresh: true),
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
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
    if (!userApi.isAndroid) {
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
            const SleepDuration(),
            SizedBox(
              height: 20 * pixel,
            ),
          ],
        ),
      );
    } else {
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
            SizedBox(
              height: 20 * pixel,
            ),
            const StepTime()
          ],
        ),
      );
    }
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    if (!userApi.isAndroid) {
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
          SizedBox(
            height: 21 * pixel,
          ),
          const Sleep(),
          SizedBox(
            height: 21 * pixel,
          ),
          const CarbonEmission(),
          SizedBox(
            height: 21 * pixel,
          ),
        ],
      );
    } else {
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
          SizedBox(
            height: 21 * pixel,
          ),
          const ScreenTime()
        ],
      );
    }
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
        return WillPopScope(
          // restore date if confirm is not clicked
          onWillPop: () async {
            _date = widget.date;
            return true;
          },
          child: AlertDialog(
            title: const Text("Select a day"),
            contentPadding:
                EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
            content: SizedBox(
              height: 271 * pixel,
              width: 300 * pixel,
              child: CalendarDialog(
                onDateChange: _changeWidgetDate,
                selectedDate: widget.date,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    AutoSizeText(
                      "Heart Rate",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    SizedBox(
                      height: 10 * pixel,
                    ),
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
                    AutoSizeText(
                      "Rest",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    AutoSizeText(
                      formatNum(
                        Provider.of<HealthDataModel>(context)
                            .healthData['rest_heart_rate'],
                        decimalPoints: 1,
                        loading: Provider.of<HealthDataModel>(context).loading,
                      ),
                      maxLines: 1,
                      style: montserratAlternatesTextStyle(pixel * 30,
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                    AutoSizeText(
                      "bpm",
                      maxLines: 1,
                      style: montserratAlternatesTextStyle(pixel * 17,
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 11 * pixel,
          ),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    SvgIcon(
                      imagePath: 'assets/svg/heart_rate_2.svg',
                      width: 45,
                      height: 45,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primaryContainer,
                          BlendMode.srcIn),
                    ),
                    SizedBox(
                      height: 10 * pixel,
                    ),
                    AutoSizeText(
                      userApi.isAndroid ? "Exercise" : "Average",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    AutoSizeText(
                      formatNum(
                        Provider.of<HealthDataModel>(context).healthData[
                            userApi.isAndroid
                                ? 'exercise_heart_rate'
                                : "avg_heart_rate"],
                        decimalPoints: 1,
                        loading: Provider.of<HealthDataModel>(context).loading,
                      ),
                      maxLines: 1,
                      style: montserratAlternatesTextStyle(pixel * 30,
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                    AutoSizeText(
                      "bpm",
                      maxLines: 1,
                      style: montserratAlternatesTextStyle(pixel * 17,
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  const HealthCard({
    super.key,
    required this.icon,
    required this.label,
    required this.unit,
    required this.value,
    this.labelMaxLines = 1,
    this.valueMaxLines = 1,
  });

  final SvgIcon icon;
  final String label;
  final String unit;
  final String value;
  final int labelMaxLines;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;

    return FedCard(
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon,
                SizedBox(
                  height: 10 * pixel,
                ),
                AutoSizeText(
                  label,
                  maxLines: labelMaxLines,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                AutoSizeText(
                  value,
                  maxLines: valueMaxLines,
                  style: montserratAlternatesTextStyle(pixel * 30,
                      Theme.of(context).colorScheme.primaryContainer),
                ),
                AutoSizeText(
                  unit,
                  maxLines: 1,
                  style: montserratAlternatesTextStyle(pixel * 17,
                      Theme.of(context).colorScheme.primaryContainer),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthCardItems extends StatelessWidget {
  const HealthCardItems({
    super.key,
    required this.icons,
    required this.labels,
    required this.units,
    required this.value,
  });

  final List<SvgIcon> icons;
  final List<String> labels;
  final List<String> units;
  final List<String> value;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    List<Widget> rows = [
      for (var i = 0; i < min(icons.length, labels.length); i++) ...[
        Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  icons[i],
                  SizedBox(
                    height: 10 * pixel,
                  ),
                  AutoSizeText(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  AutoSizeText(
                    value[i],
                    maxLines: 1,
                    style: montserratAlternatesTextStyle(pixel * 30,
                        Theme.of(context).colorScheme.primaryContainer),
                  ),
                  AutoSizeText(
                    units[i],
                    maxLines: 1,
                    style: montserratAlternatesTextStyle(pixel * 17,
                        Theme.of(context).colorScheme.primaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 11 * pixel,
        ),
      ]
    ]..removeLast();

    return FedCard(
      child: Column(
        children: rows,
      ),
    );
  }
}

class Distance extends StatelessWidget {
  const Distance({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/distance.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Distance",
      unit: "m",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['distance'],
        decimalPoints: 1,
        loading: Provider.of<HealthDataModel>(context).loading,
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
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/stress.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Stress",
      unit: "stress",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['stress'],
        decimalPoints: 2,
        loading: Provider.of<HealthDataModel>(context).loading,
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
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/step.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Step",
      unit: "steps",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['step'],
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

class StepTime extends StatelessWidget {
  const StepTime({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        height: 58,
        width: 58,
        imagePath: 'assets/svg/step_time.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Step\nTime",
      labelMaxLines: 2,
      unit: "min",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['step_time'],
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

class Calorie extends StatelessWidget {
  const Calorie({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/calorie.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Calorie",
      unit: "kcal",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['calorie'],
        decimalPoints: 2,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

class IntenseExercise extends StatelessWidget {
  const IntenseExercise({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/exercise.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Intense \nExercise",
      labelMaxLines: 2,
      unit: "min",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['calorie'],
        decimalPoints: 1,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

class Sleep extends StatelessWidget {
  const Sleep({
    super.key,
  });

  List<double> _sleepMinuteToHour(double? sleepTime) {
    if (sleepTime == null || sleepTime == -1) {
      return [-1, -1];
    } else {
      return [((sleepTime) ~/ 60).toDouble(), ((sleepTime) % 60)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return userApi.isAndroid
        ? HealthCard(
            icon: SvgIcon(
              imagePath: 'assets/svg/sleep.svg',
              width: 58,
              height: 58,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
            label: "Sleep",
            unit: "score",
            value: formatNum(
              Provider.of<HealthDataModel>(context)
                  .healthData['sleep_efficiency'],
              decimalPoints: 2,
              loading: Provider.of<HealthDataModel>(context).loading,
            ),
          )
        : HealthCard(
            icon: SvgIcon(
              imagePath: 'assets/svg/sleep.svg',
              width: 58,
              height: 58,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primaryContainer,
                  BlendMode.srcIn),
            ),
            label: "Sleep",
            unit: "${formatNum(
              _sleepMinuteToHour(Provider.of<HealthDataModel>(context)
                  .healthData['sleep_time'])[1],
              decimalPoints: 0,
              loading: Provider.of<HealthDataModel>(context).loading,
            )} min",
            value:
                "${formatNum(_sleepMinuteToHour(Provider.of<HealthDataModel>(context).healthData['sleep_time'])[0], loading: Provider.of<HealthDataModel>(context).loading, decimalPoints: 0)} h",
          );
  }
}

class SleepDuration extends StatelessWidget {
  const SleepDuration({
    super.key,
  });

  String _sleepDurationDoubleToString(double? sleepDuration) {
    var s = formatNum(sleepDuration, decimalPoints: 0);
    if (s == "-" || s == "0") {
      return s;
    }
    s = s.padLeft(8, "0");
    return "${s.substring(0, 2)}:${s.substring(2, 4)}\n${s.substring(4, 6)}:${s.substring(6, 8)}";
  }

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/sleep.svg',
        width: 58,
        height: 58,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Duration",
      unit: "",
      value: _sleepDurationDoubleToString(
          Provider.of<HealthDataModel>(context).healthData['sleep_duration']),
      valueMaxLines: 2,
    );
  }
}

class ScreenTime extends StatelessWidget {
  const ScreenTime({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/phone_usage.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Screen\nTime",
      labelMaxLines: 2,
      unit: "min",
      value: formatNum(
        Provider.of<HealthDataModel>(context)
            .healthData['total_time_foreground'],
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}


class CarbonEmission extends StatelessWidget {
  const CarbonEmission({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/carbon_emission.svg',
        width: 58,
        height: 58,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Emission\nReductions",
      labelMaxLines: 2,
      unit: "g",
      value: formatNum(
        Provider.of<HealthDataModel>(context)
            .healthData['carbon_emission'],
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

String formatNum(double? num, {decimalPoints = 2, loading = false}) {
  if (loading || num == -1 || num == null) return '-';
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
