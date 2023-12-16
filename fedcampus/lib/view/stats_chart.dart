import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utility/collections.dart';
import '../utility/my_math.dart';

class StatsPDF extends StatefulWidget {
  const StatsPDF({
    super.key,
  });

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
    final List<double> d = [
      1.2,
      1.1,
      1.3,
      1.3,
      1.2,
      2.3,
      4.5,
      4.6,
      4.7,
      5.2,
      5.7,
      7.5
    ];

    final x = linspace(d.reduce(min) - 1, d.reduce(max) + 1, 100);
    final y = kernelSmoothing(x, d, 0.5);

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
          children: [
            SizedBox(
              height: 450 * pixel,
              child: LineChart(
                LineChartData(
                    lineBarsData: [LineChartBarData(spots: getFlSpots())]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
