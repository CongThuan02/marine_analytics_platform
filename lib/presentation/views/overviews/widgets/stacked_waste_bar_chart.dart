import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StackedWasteBarChart extends StatelessWidget {
  final List<String> periods;
  final List<WasteTypeSeriesData> series;
  final String title;

  const StackedWasteBarChart({
    super.key,
    required this.periods,
    required this.series,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty || series.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelRotation: -45,
                  labelStyle: TextStyle(fontSize: 10),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  title: const AxisTitle(
                    text: 'Số lượng (kg)',
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  labelStyle: const TextStyle(fontSize: 11),
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: const TextStyle(fontSize: 11),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x - series.name: point.y kg',
                  textStyle: const TextStyle(fontSize: 11),
                ),
                series: _buildStackedColumnSeries(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CartesianSeries> _buildStackedColumnSeries() {
    return series.asMap().entries.map((entry) {
      final index = entry.key;
      final wasteTypeSeries = entry.value;

      // Create data points for this waste type
      final dataPoints = <_ChartData>[];
      for (int i = 0; i < periods.length; i++) {
        dataPoints.add(
          _ChartData(period: periods[i], quantity: wasteTypeSeries.data[i]),
        );
      }

      return StackedColumnSeries<_ChartData, String>(
        dataSource: dataPoints,
        xValueMapper: (_ChartData data, _) => data.period,
        yValueMapper: (_ChartData data, _) => data.quantity,
        name: wasteTypeSeries.name,
        color: _getColorForIndex(index),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.secondaryTeal,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.teal,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.deepPurple,
      Colors.lightGreen,
    ];
    return colors[index % colors.length];
  }
}

class _ChartData {
  final String period;
  final double quantity;

  _ChartData({required this.period, required this.quantity});
}

class WasteTypeSeriesData {
  final String name;
  final List<double> data;

  WasteTypeSeriesData({required this.name, required this.data});
}
