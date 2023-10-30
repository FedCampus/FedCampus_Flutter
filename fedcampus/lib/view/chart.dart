import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_data_model.dart';
import '../utility/calendar.dart';

class DetailsChart extends StatefulWidget {
  const DetailsChart({
    super.key,
  });

  @override
  State<DetailsChart> createState() => _DetailsChartState();
}

class _DetailsChartState extends State<DetailsChart> {
  late DateTime date;
  List<double> dataList = [9999, 12306, 3333, 6666, 7777, 2222, 8888];
  List<BarChartGroupData> barGroupData = [];

  @override
  void initState() {
    super.initState();
    getBarGroupData();
    date = DateTime.parse(
        Provider.of<HealthDataModel>(context, listen: false).date);
  }

  List<BarChartGroupData> getBarGroupData() {
    for (final (index, item) in dataList.indexed) {
      barGroupData.add(BarChartGroupData(
          x: index + 1, barRods: [BarChartRodData(toY: item)]));
    }

    return barGroupData;
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health details"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
                "${findWeekFirstDay(date).toString()} - ${findWeekLastDay(date).toString()}"),
            SizedBox(
              height: 450 * pixel,
              child: BarChart(
                BarChartData(
                  barGroups: barGroupData,
                  // maxY: 12001,
                  gridData: const FlGridData(
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                          reservedSize: 50 * pixel, showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                swapAnimationDuration:
                    const Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ),
            ),
          ],
        ),
      ),
    );
  }
}
