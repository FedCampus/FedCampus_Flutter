import 'dart:math';

import 'package:fedcampus/utility/log.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utility/collections.dart';
import '../utility/my_math.dart';

class StatsPDF extends StatefulWidget {
  const StatsPDF({
    super.key,
    userValue,
    required this.dataPoints,
  }) : _userValue = userValue;

  final double? _userValue;
  final List<double> dataPoints;

  @override
  State<StatsPDF> createState() => _StatsPDFState();
}

class _StatsPDFState extends State<StatsPDF> {
  late final List<double> x;
  late final List<double> y;
  @override
  void initState() {
    super.initState();
    x = linspace(widget.dataPoints.reduce(min) - 1,
        widget.dataPoints.reduce(max) + 1, 100);
    y = kernelSmoothing(
        x, widget.dataPoints, silvermanBandwidth(widget.dataPoints));
  }

  List<FlSpot> getFlSpots() {
    return zip(x, y).map((e) => FlSpot(e.first, e.last)).toList();
  }

  (double, double) getXRange() {
    return (x.first, x.last);
  }

  double getMaximumY() {
    return y.reduce(max);
  }

  List<FlSpot> getVertical() {
    if (widget._userValue != null) {
      final x0 = [widget._userValue!, widget._userValue!];
      final y0 = [0.0, getMaximumY()];
      logger.e(x0);
      return zip(x0, y0).map((e) => FlSpot(e.first, e.last)).toList();
    }
    throw Exception("widget._userValue should not be null!");
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (widget.dataPoints.length > 6)
            ? Container(
                height: 280 * pixel,
                padding: EdgeInsets.fromLTRB(
                    18 * pixel, 5 * pixel, 18 * pixel, 5 * pixel),
                child: LineChart(
                  LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: getFlSpots(),
                          dotData: const FlDotData(
                            show: false,
                          ),
                        ),
                        if (widget._userValue != null && widget._userValue! > 0)
                          LineChartBarData(
                            spots: getVertical(),
                            dotData: const FlDotData(
                              show: false,
                            ),
                          ),
                      ],
                      lineTouchData: const LineTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: const SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 30,
                            showTitles: true,
                            getTitlesWidget: () {
                              double x0 = 0;
                              double x1 = 0;
                              return (value, meta) {
                                Widget text = const Text('');
                                if (x0 == 0) {
                                  x0 = value;
                                }
                                if (x1 == 0) {
                                  x1 = value;
                                }
                                double prevGap = x1 - x0;
                                x0 = x1;
                                x1 = value;
                                // do not show last axis when no enough space
                                if (x1 - x0 < prevGap / 1.5) {
                                  text = const Text('');
                                } else {
                                  text = Text(meta.formattedValue);
                                }

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: text,
                                );
                              };
                            }(),
                          ),
                        ),
                      ),
                      minX: getXRange().$1 > 0 ? getXRange().$1 : 0,
                      maxY: getMaximumY()),
                ),
              )
            : const Text(
                "Too few data to show the distribution graph. Please wait other to upload data."),
      ],
    );
  }
}
