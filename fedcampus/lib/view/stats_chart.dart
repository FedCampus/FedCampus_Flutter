import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utility/collections.dart';
import '../utility/my_math.dart';

class StatsPDF extends StatefulWidget {
  const StatsPDF({
    super.key,
    required this.dataPoints,
  });

  final List<double> dataPoints;

  @override
  State<StatsPDF> createState() => _StatsPDFState();
}

class _StatsPDFState extends State<StatsPDF> {
  List<BarChartGroupData> barGroupData = [];

  @override
  void initState() {
    super.initState();
  }

  List<FlSpot> getFlSpots() {
    final x = linspace(widget.dataPoints.reduce(min) - 1,
        widget.dataPoints.reduce(max) + 1, 100);
    final y = kernelSmoothing(
        x, widget.dataPoints, silvermanBandwidth(widget.dataPoints));
    return zip(x, y).map((e) => FlSpot(e.first, e.last)).toList();
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats details"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 450 * pixel,
              child: (widget.dataPoints.length > 5)
                  ? LineChart(
                      LineChartData(lineBarsData: [
                        LineChartBarData(spots: getFlSpots())
                      ]),
                    )
                  : const Text(
                      "Too few data to show the distribution graph. Please wait other to upload data."),
            ),
          ],
        ),
      ),
    );
  }
}
