import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarGraphPage extends StatelessWidget {
  final int numCorrectAnswers;
  final int numWrongAnswers;

  BarGraphPage({required this.numCorrectAnswers, required this.numWrongAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answer Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Number of Correct and Wrong Answers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              width: 300,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(y: numCorrectAnswers.toDouble(), colors: [Colors.green]),
                      BarChartRodData(y: numWrongAnswers.toDouble(), colors: [Colors.red]),
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) {
                        return const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
                      },
                      getTitles: (double value) {
                        if (value == 0) {
                          return 'Correct';
                        } else if (value == 1) {
                          return 'Wrong';
                        } else {
                          return '';
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
