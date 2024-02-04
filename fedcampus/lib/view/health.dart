//TODO:find better way do adapt different screen size

import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/event_bus.dart';
import '../utility/global.dart';
import '../utility/http_api.dart';

final healthEntries = userApi.isAndroid
    ? [
        {
          "entry_name": "heart",
          "height": 1.1,
        },
        {
          "entry_name": "distance",
          "height": 1.0,
        },
        {
          "entry_name": "stress",
          "height": 1.0,
        },
        {
          "entry_name": "step_time",
          "height": 1.25,
        },
        {
          "entry_name": "step",
          "height": 1.0,
        },
        {
          "entry_name": "calorie",
          "height": 1.0,
        },
        {
          "entry_name": "intense_exercise",
          "height": 1.2,
        },
        {
          "entry_name": "sleep_efficiency",
          "height": 1.1,
        },
        {
          "entry_name": "screen_time",
          "height": 1.2,
        },
        {
          "entry_name": "carbon_emission",
          "height": 1.1,
        },
      ]
    : [
        {
          "entry_name": "heart",
          "height": 1.1,
        },
        {
          "entry_name": "distance",
          "height": 1.0,
        },
        {
          "entry_name": "sleep_duration",
          "height": 1.0,
        },
        {
          "entry_name": "step",
          "height": 1.0,
        },
        {
          "entry_name": "calorie",
          "height": 1.0,
        },
        {
          "entry_name": "sleep",
          "height": 1.1,
        },
        {
          "entry_name": "carbon_emission",
          "height": 1.1,
        },
      ];

class Health extends StatefulWidget {
  const Health({
    super.key,
  });

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  DateTime dateTime = DateTime.now();

  final entriesMap = {
    "heart": const Heart(),
    "distance": const Distance(),
    "stress": const Stress(),
    "step_time": const StepTime(),
    "step": const Step(),
    "calorie": const Calorie(),
    "intense_exercise": const IntenseExercise(),
    "sleep_efficiency": const Sleep(),
    "screen_time": const ScreenTime(),
    "carbon_emission": const CarbonEmission(),
    "sleep_duration": const SleepDuration(),
    "sleep": const Sleep(),
  };

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.parse(
        Provider.of<HealthDataModel>(context, listen: false).date);

    init();
  }

  init() async {
    await checkVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  checkVersion() async {
    try {
      await HTTPApi.checkVersion();
    } catch (e) {
      logger.e(e);

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text("Version check"),
                content: SizedBox(
                  width: 350,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Text(e.toString()),
                        Text(userApi.isAndroid
                            ? "Please download the latest version."
                            : "Please update in TestFlight.")
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  if (userApi.isAndroid)
                    TextButton(
                      child: const Text("Download"),
                      onPressed: () async {
                        final Uri url = Uri.parse(
                            'http://10.201.8.29:8006/media/android/app-arm64-v8a-release.apk');
                        await launchUrl(url);
                      },
                    ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  (List<Widget>, List<Widget>) _splitEntriesRecursiveThreshold(
      [threshhold = 1]) {
    List<Widget> left;
    List<Widget> right;
    (left, right) = _splitEntriesThreshold(threshhold);
    if (left.isEmpty) {
      return _splitEntriesRecursiveThreshold(2 * threshhold);
    }
    return (left, right);
  }

  (List<Widget>, List<Widget>) _splitEntriesThreshold([threshhold = 1]) {
    final validEntries = healthEntries
        .where((e) => userApi.prefs.getBool(e["entry_name"] as String) ?? true)
        .toList();
    final totalWeight = validEntries
        .map<double>((entry) => entry['height'] as double)
        .reduce((a, b) => a + b);
    double targetWeight = totalWeight / 2;
    List<dynamic> group1 = [];
    List<dynamic> group2 = [];

    bool partition(int index, double currentSum, List<dynamic> group) {
      if ((currentSum - targetWeight).abs() < threshhold) {
        return true;
      }
      if (currentSum > targetWeight + threshhold ||
          index >= validEntries.length) {
        return false;
      }

      // Include the current weight in the group
      group.add(validEntries[index]);

      // Recursively check if a solution is found
      if (partition(index + 1,
          currentSum + (validEntries[index]["height"] as double), group)) {
        return true;
      }

      // Exclude the current weight from the group
      group.removeLast();

      // Recursively check if a solution is found
      if (partition(index + 1, currentSum, group)) {
        return true;
      }

      return false;
    }

    // Start the partitioning process
    partition(0, 0, group1);

    // Assign the remaining weights to group2
    group2 = validEntries.where((weight) => !group1.contains(weight)).toList();

    List<Widget> left =
        group1.map<Widget>((e) => entriesMap[e["entry_name"]]!).toList();
    List<Widget> right =
        group2.map<Widget>((e) => entriesMap[e["entry_name"]]!).toList();

    return (left, right);
  }

  Future<void> refresh({bool forcedRefresh = false}) async {
    Provider.of<HealthDataModel>(context, listen: false)
        .requestAllData(forcedRefresh: forcedRefresh);
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    bus.on("loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
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
    List<Widget> left;
    List<Widget> right;
    (left, right) = _splitEntriesRecursiveThreshold(0.05);
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
            child: Column(
              children: [
                Date(
                  date: dateTime,
                  onDateChange: updateDate,
                ),
                SizedBox(
                  height: 20 * pixel,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: HealthCardColumn(
                        children: left,
                      ),
                    ),
                    SizedBox(
                      width: 22 * pixel,
                    ),
                    Expanded(
                      flex: 1,
                      child: HealthCardColumn(
                        children: right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HealthCardColumn extends StatelessWidget {
  const HealthCardColumn({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;

    Widget elementToInsert = SizedBox(
      height: 20 * pixel,
    );
    List<Widget> childrenWithMeDividerInserted = [];
    childrenWithMeDividerInserted = children
        .sublist(0, children.length - 1)
        .expand((Widget item) => [item, elementToInsert])
        .toList()
      ..add(children.last);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: childrenWithMeDividerInserted,
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
  /// [_date] is synchronized with selected date inside [CalendarDialog]
  /// [widget.onDateChange] is called only when confirm is clicked
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
            height: 291 * pixel,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      height: 80 * pixel,
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
              14 * pixel, 12 * pixel, 14 * pixel, 12 * pixel),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10 * pixel)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            FedIcon(
              imagePath: 'assets/images/health_nav_icon.png',
              height: 52 * pixel,
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: AutoSizeText(
                            "${DateFormat.MMMd('en_US').format(widget.date)}  ${DateFormat.E('en_US').format(widget.date)}",
                            textAlign: TextAlign.center,
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
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: AutoSizeText(
                      DateFormat.y('en_US').format(widget.date),
                      style: TextStyle(
                          fontSize: pixel * 18,
                          color: Theme.of(context).colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
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

class Heart extends StatelessWidget {
  const Heart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      icon: SvgIcon(
        imagePath: 'assets/svg/heart_rate.svg',
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primaryContainer, BlendMode.srcIn),
      ),
      label: "Rest\nHeart Rate",
      labelMaxLines: 2,
      subvalue: "bpm",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['rest_heart_rate'],
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  const HealthCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.subvalue,
    this.labelMaxLines = 1,
    this.valueMaxLines = 1,
  });

  final SvgIcon icon;
  final String label;
  final String subvalue;
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
                  textAlign: TextAlign.center,
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
                  textAlign: TextAlign.center,
                  maxLines: valueMaxLines,
                  style: montserratAlternatesTextStyle(pixel * 30,
                      Theme.of(context).colorScheme.primaryContainer),
                ),
                AutoSizeText(
                  subvalue,
                  textAlign: TextAlign.center,
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
      subvalue: "m",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['distance'],
        decimalPoints: 0,
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
      subvalue: "stress",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['stress'],
        decimalPoints: 0,
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
      subvalue: "steps",
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
    final double originalValue =
        Provider.of<HealthDataModel>(context).healthData['step_time']!;
    partialHealthCard(String value, String subvalue) => HealthCard(
          icon: SvgIcon(
            height: 58,
            width: 58,
            imagePath: 'assets/svg/step_time.svg',
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primaryContainer,
                BlendMode.srcIn),
          ),
          label: "Step\nTime",
          labelMaxLines: 2,
          value: value,
          subvalue: subvalue,
        );

    if (originalValue < 60) {
      return partialHealthCard(
          formatNum(
            originalValue,
            decimalPoints: 0,
            loading: Provider.of<HealthDataModel>(context).loading,
          ),
          "min");
    } else {
      String value, subvalue;
      (value, subvalue) = formatHour(
        originalValue,
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      );
      return partialHealthCard("$value h", "$subvalue min");
    }
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
      subvalue: "kcal",
      value: formatNum(
        Provider.of<HealthDataModel>(context).healthData['calorie'],
        decimalPoints: 1,
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
    final double originalValue =
        Provider.of<HealthDataModel>(context).healthData['intensity']!;
    partialHealthCard(String value, String subvalue) => HealthCard(
          icon: SvgIcon(
            imagePath: 'assets/svg/exercise.svg',
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primaryContainer,
                BlendMode.srcIn),
          ),
          label: "Intense \nExercise",
          labelMaxLines: 2,
          value: value,
          subvalue: subvalue,
        );

    if (originalValue < 60) {
      return partialHealthCard(
          formatNum(
            originalValue,
            decimalPoints: 0,
            loading: Provider.of<HealthDataModel>(context).loading,
          ),
          "min");
    } else {
      String value, subvalue;
      (value, subvalue) = formatHour(
        originalValue,
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      );
      return partialHealthCard("$value h", "$subvalue min");
    }
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
            subvalue: "score",
            value: formatNum(
              Provider.of<HealthDataModel>(context)
                  .healthData['sleep_efficiency'],
              decimalPoints: 0,
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
            subvalue: "${formatNum(
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

  String _sleepDurationDoubleToString(double sleepDuration) {
    logger.e(sleepDuration);
    int start = sleepDuration ~/ 10000;
    int end = (sleepDuration % 10000).toInt();
    String startH = (start ~/ 60).toString().padLeft(2, "0");
    String startM = (start % 60).toString().padLeft(2, "0");
    String endH = (end ~/ 60).toString().padLeft(2, "0");
    String endM = (end % 60).toString().padLeft(2, "0");

    return "$startH:$startM\n$endH:$endM";
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
      subvalue: "",
      value: _sleepDurationDoubleToString(
          Provider.of<HealthDataModel>(context).healthData['sleep_duration']!),
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
    final double totalTimeForeground = Provider.of<HealthDataModel>(context)
        .healthData['total_time_foreground']!;
    partialHealthCard(String value, String subvalue) => HealthCard(
          icon: SvgIcon(
            imagePath: 'assets/svg/phone_usage.svg',
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primaryContainer,
                BlendMode.srcIn),
          ),
          label: "Screen\nTime",
          labelMaxLines: 2,
          value: value,
          subvalue: subvalue,
        );

    if (totalTimeForeground < 60) {
      return partialHealthCard(
          formatNum(
            totalTimeForeground,
            decimalPoints: 0,
            loading: Provider.of<HealthDataModel>(context).loading,
          ),
          "min");
    } else {
      String value, subvalue;
      (value, subvalue) = formatHour(
        totalTimeForeground,
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      );
      return partialHealthCard("$value h", "$subvalue min");
    }
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
      subvalue: "g",
      // to choose the data resource based on platform
      value: formatNum(
        !userApi.isAndroid
            ? Provider.of<HealthDataModel>(context)
                .healthData['carbon_emission']
            : (Provider.of<HealthDataModel>(context).healthData['distance']! /
                1000 *
                42),
        decimalPoints: 0,
        loading: Provider.of<HealthDataModel>(context).loading,
      ),
    );
  }
}

String formatNum(double? num, {decimalPoints = 2, loading = false}) {
  if (loading || num == -1 || num == 0 || num == null) return '-';
  String s = num.toStringAsFixed(decimalPoints);
  return s;
}

(String, String) formatHour(double? num, {decimalPoints = 2, loading = false}) {
  if (loading || num == -1 || num == 0 || num == null) return ('-', '-');
  String s = (num ~/ 60).toStringAsFixed(decimalPoints);
  String s2 = (num % 60).toStringAsFixed(decimalPoints);
  logger.e(s);
  return (s, s2);
}

TextStyle montserratAlternatesTextStyle(double fontSize, Color color) {
  return TextStyle(
    fontFamily: 'Montserrat Alternates',
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.bold,
  );
}
