import 'dart:async';

import 'package:fedcampus/view/stats_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fedcampus/models/activity_data_model.dart';
import 'package:fedcampus/utility/filter_params.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/calendar.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utility/event_bus.dart';

class Activity extends StatefulWidget {
  const Activity({
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final entries = userApi.isAndroid
      ? [
          {
            "entry_name": "step",
            "icon_path": "assets/svg/step.svg",
            "unit": "steps",
            "decimal_points": 0,
          },
          {
            "entry_name": "distance",
            "icon_path": "assets/svg/distance.svg",
            "unit": "meters",
            "decimal_points": 0,
          },
          {
            "entry_name": "carbon_emission",
            "icon_path": "assets/svg/carbon_emission.svg",
            "unit": "g",
            "decimal_points": 0,
          },
          {
            "entry_name": "calorie",
            "icon_path": "assets/svg/calorie.svg",
            "unit": "kcals",
            "decimal_points": 0,
          },
          {
            "entry_name": "intensity",
            "icon_path": "assets/svg/exercise.svg",
            "unit": "min",
            "decimal_points": 0,
          },
          {
            "entry_name": "stress",
            "icon_path": "assets/svg/stress.svg",
            "unit": "stress",
            "decimal_points": 0,
          },
          {
            "entry_name": "step_time",
            "icon_path": "assets/svg/step_time.svg",
            "img_scale": 1.2,
            "unit": "min",
            "decimal_points": 0,
          },
          {
            "entry_name": "sleep_efficiency",
            "icon_path": "assets/svg/sleep.svg",
            "img_scale": 1.2,
            "unit": "effi",
            "decimal_points": 0,
          },
        ]
      : [
          {
            "entry_name": "step",
            "icon_path": "assets/svg/step.svg",
            "unit": "steps",
            "decimal_points": 0,
          },
          {
            "entry_name": "distance",
            "icon_path": "assets/svg/distance.svg",
            "unit": "meters",
            "decimal_points": 0,
          },
          {
            "entry_name": "carbon_emission",
            "icon_path": "assets/svg/carbon_emission.svg",
            "unit": "g",
            "decimal_points": 0,
          },
          {
            "entry_name": "calorie",
            "icon_path": "assets/svg/calorie.svg",
            "unit": "kcals",
            "decimal_points": 0,
          },
          {
            "entry_name": "sleep_time",
            "icon_path": "assets/svg/sleep.svg",
            "img_scale": 1.2,
            "unit": "hours",
            "decimal_points": 0,
          },
          {
            "entry_name": "sleep_duration",
            "display_name": "Bedtime",
            "icon_path": "assets/svg/sleep.svg",
            "img_scale": 1.2,
            "unit": "time",
            "decimal_points": 0,
          },
        ];

  late final int maxCount;
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    maxCount = entries.length + 3;
    Provider.of<ActivityDataModel>(context, listen: false).filterParams =
        FilterParams.create();
    dateTime = DateTime.parse(
        Provider.of<ActivityDataModel>(context, listen: false).date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  Future<void> refresh({bool forcedRefresh = false}) async {
    Provider.of<ActivityDataModel>(context, listen: false).ifSent = false;
    Provider.of<ActivityDataModel>(context, listen: false)
        .getActivityData(forcedRefresh: forcedRefresh);
    LoadingDialog loadingDialog = SmallLoadingDialog(context: context);
    loadingDialog.showLoading();
    bus.on("activity_loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
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
    bus.on("activity_loading_done", (arg) {
      if (!loadingDialog.cancelled) loadingDialog.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return RefreshIndicator(
      onRefresh: () => refresh(forcedRefresh: true),
      child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 11),
          itemCount: maxCount,
          padding: EdgeInsets.all(20 * pixel),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // calendar and filter
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 15,
                    child: Date(
                      onDateChange: updateDate,
                      date: dateTime,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 5,
                    child: FilterCard(
                      refreshCallBack: refresh,
                    ),
                  ),
                ],
              );
            }
            if (index == 1) {
              // table header
              return Row(
                children: <Widget>[
                  const Spacer(flex: 1),
                  Text(
                    AppLocalizations.of(context)!.stats_tbl_header_avg,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: pixel * 15),
                  ),
                  const Spacer(flex: 1),
                  Text(
                    AppLocalizations.of(context)!.stats_tbl_header_percentile,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: pixel * 15),
                  ),
                ],
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
            final currentEntry = entries[index - 2];
            // do not show value for FA if average is 0

            final String entry = currentEntry['entry_name'] as String;

            final String displayName =
                (currentEntry["display_name"] as String? ??
                    snakeCaseToCapitalSeparated(entry));

            final String value;
            String? secondaryValue;
            final String unit = currentEntry['unit']?.toString() ?? "unit";
            String? secondaryUnit;
            final rank = Provider.of<ActivityDataModel>(context)
                .activityData[currentEntry['entry_name']]["rank"]
                .toStringAsFixed(0);

            final num rawAverage = Provider.of<ActivityDataModel>(context)
                .activityData[currentEntry['entry_name']]["average"];
            final List<double> dataPoints = List<double>.from(
                Provider.of<ActivityDataModel>(context)
                    .activityData[currentEntry['entry_name']]["data_points"]);

            if (entry == "sleep_duration") {
              String startH = (rawAverage ~/ 60).toString().padLeft(2, "0");
              String startM =
                  (rawAverage % 60).toInt().toString().padLeft(2, "0");
              value = "$startH:$startM";
            } else if (entry == "sleep_time" && rawAverage > 60) {
              value = (rawAverage ~/ 60).toString();
              secondaryValue = (rawAverage % 60).toInt().toString();
              secondaryUnit = "min";
            } else {
              value = rawAverage
                  .toStringAsFixed(currentEntry['decimal_points'] as int);
            }

            return ActivityCard(
              displayName: displayName,
              rank: rank,
              value: value,
              secondaryValue: secondaryValue,
              unit: unit,
              secondaryUnit: secondaryUnit,
              iconPath: currentEntry['icon_path']?.toString() ??
                  "assets/svg/sleep.svg",
              imgScale: currentEntry["img_scale"] as double?,
              isValidValue: value != "0" &&
                  !Provider.of<ActivityDataModel>(context).loading,
              isValidRank: rank != "0" &&
                  !Provider.of<ActivityDataModel>(context).loading,
              dataPoints: dataPoints,
            );
          }),
    );
  }
}

String snakeCaseToCapitalSeparated(String snakeCaseString) {
  List<String> words = snakeCaseString.split('_');
  String capitalSeparatedString = words.map((word) {
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
  return capitalSeparatedString;
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.displayName,
    required this.rank,
    required this.value,
    this.secondaryValue,
    required this.unit,
    this.secondaryUnit,
    required this.iconPath,
    this.imgScale,
    this.isValidValue,
    this.isValidRank,
    dataPoints,
  }) : _dataPoints = dataPoints;

  final String displayName;
  final String rank;
  final String value;
  final String? secondaryValue;
  final String unit;
  final String? secondaryUnit;
  final String iconPath;
  final double? imgScale;
  final bool? isValidValue;
  final bool? isValidRank;
  final List<double>? _dataPoints;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;

    Widget widget = Row(
      children: <Widget>[
        // As stated in https://api.flutter.dev/flutter/widgets/Image/height.html,
        // it is recommended to specify the image size (in order to avoid
        // widget size suddenly changes when the app just loads another page)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              SvgIcon(
                imagePath: iconPath,
                height: pixel * 50 * (imgScale ?? 1),
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondaryContainer,
                    BlendMode.srcIn),
              ),
              SizedBox(
                height: 8 * pixel,
              ),
              AutoSizeText(
                displayName,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: (secondaryValue != null && secondaryUnit != null)
              ? _twoDataRows(
                  pixel,
                  context,
                  isValidValue ?? false ? value : "-",
                  unit,
                  isValidValue ?? false ? secondaryValue! : "-",
                  secondaryUnit!)
              : _oneDataRow(
                  pixel, context, isValidValue ?? false ? value : "-", unit),
        ),
        Expanded(
          flex: 7,
          child: isValidRank ?? false
              ? RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(1, -4),
                        child: Text(
                          'top',
                          textScaler: const TextScaler.linear(0.6),
                          style: TextStyle(
                            fontSize: pixel * 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: rank,
                      style: TextStyle(
                        fontSize: pixel * 30,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(-1, 0),
                        child: Text(
                          '%',
                          textScaler: const TextScaler.linear(0.7),
                          style: TextStyle(
                            fontSize: pixel * 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ]),
                )
              : Text(
                  "    -",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Montserrat Alternates',
                      fontSize: pixel * 30,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
        ),
      ],
    );

    if (_dataPoints != null && _dataPoints.isNotEmpty) {
      return ClickableFedCard(
        child: widget,
        callBack: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatsPDF(dataPoints: _dataPoints),
            ),
          );
        },
      );
    } else {
      return FedCard(child: widget);
    }
  }

  Column _oneDataRow(double pixel, BuildContext context, String v1, String u1) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 5,
              child: AutoSizeText(
                v1,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: value.length < 8
                        ? pixel * 30
                        : pixel * (200 / value.length),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const Spacer(
              flex: 3,
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: AutoSizeText(
                u1,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 21,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondaryContainer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _twoDataRows(double pixel, BuildContext context, String v1, String u1,
      String v2, String u2) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: AutoSizeText(
                v1,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: value.length < 8
                        ? pixel * 30
                        : pixel * (200 / value.length),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 3,
              child: AutoSizeText(
                u1,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 21,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondaryContainer),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: AutoSizeText(
                v2,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: value.length < 8
                        ? pixel * 23
                        : pixel * (200 / value.length),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 3,
              child: AutoSizeText(
                u2,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: pixel * 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondaryContainer),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class CheckBoxLabel extends StatefulWidget {
  final bool selected;
  final String text;
  final void Function(bool) callback;

  const CheckBoxLabel(
      {super.key,
      required this.selected,
      required this.text,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _CheckBoxLabelState();
}

class _CheckBoxLabelState extends State<CheckBoxLabel> {
  bool _selected = false;
  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: _selected,
            onChanged: (b) {
              setState(() {
                _selected = b!;
              });
              widget.callback(b!);
            }),
        Text(widget.text)
      ],
    );
  }
}

class FilterCard extends StatefulWidget {
  const FilterCard({super.key, required this.refreshCallBack});

  final Future<void> Function() refreshCallBack;

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard> {
  int status = userApi.prefs.getInt("status") ?? 1;
  int grade = userApi.prefs.getInt("grade") ?? 2025;
  int gender = userApi.prefs.getInt("gender") ?? 1;
  bool _selectedA = false;
  bool _selectedB = false;
  bool _selectedC = false;

  void updateQueryParams() {
    Map<String, dynamic> args = {
      "status": _selectedB
          ? grade
          : _selectedA
              ? (status == 1 ? "student" : "faculty")
              : "all",
      "gender": _selectedC ? (gender == 1 ? "male" : "female") : "all",
    };
    Provider.of<ActivityDataModel>(context, listen: false)
        .filterParams
        .addAll(args);
    logger.e(args);
  }

  Future<bool?> filterDialog() async {
    double pixel = MediaQuery.of(context).size.width / 400;
    if (userApi.prefs.getInt("status") == null ||
        userApi.prefs.getInt("grade") == null ||
        userApi.prefs.getInt("gender") == null) {
      bus.emit("toast_error",
          "You should fill in your information before applying filters.");
      return true;
    }
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select categories"),
          contentPadding:
              EdgeInsets.fromLTRB(13 * pixel, 15 * pixel, 13 * pixel, 0),
          content: SizedBox(
            height: 200 * pixel,
            width: 300 * pixel,
            child: Column(
              children: [
                CheckBoxLabel(
                  selected: _selectedA,
                  text: status == 1 ? "Students" : "Faculty",
                  callback: (b) => {
                    setState(() {
                      _selectedA = b;
                    })
                  },
                ),
                if (status == 1)
                  CheckBoxLabel(
                    selected: _selectedB,
                    text: "Class of $grade",
                    callback: (b) => {
                      setState(() {
                        _selectedB = b;
                      })
                    },
                  ),
                CheckBoxLabel(
                  selected: _selectedC,
                  text: switch (gender) {
                    1 => "Male",
                    2 => "Female",
                    _ => "Unknown"
                  },
                  callback: (b) => {
                    setState(() {
                      _selectedC = b;
                    })
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                updateQueryParams();
                Navigator.of(context).pop();
                widget.refreshCallBack();
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
    return ActivityTopCard(
      callback: filterDialog,
      child: SvgIcon(
        imagePath: 'assets/svg/filter.svg',
        height: 53 * pixel,
        width: 53 * pixel,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.secondaryContainer, BlendMode.srcIn),
      ),
    );
  }
}

class ActivityTopCard extends StatelessWidget {
  const ActivityTopCard(
      {super.key, required this.child, required this.callback, this.padding});
  final Widget child;
  final void Function() callback;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
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
          onPressed: callback,
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceTint,
            padding: padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15 * pixel)),
          ),
          child: child),
    );
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
  /// [_date] is synchronized with selected date inside [CalendarDialog]
  /// [widget.onDateChange] is called only when confirm is clicked
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
              height: 291 * pixel,
              width: 300 * pixel,
              child: CalendarDialog(
                onDateChange: _changeWidgetDate,
                selectedDate: widget.date,
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

    return ActivityTopCard(
      callback: calendarDialog,
      padding:
          EdgeInsets.fromLTRB(26 * pixel, 12 * pixel, 26 * pixel, 12 * pixel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FedIcon(
            imagePath: 'assets/images/activity_nav_icon.png',
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
    );
  }
}
