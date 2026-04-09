import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WasteTypeBarChart extends StatelessWidget {
  final List<WasteTypeData> data;
  final String title;

  const WasteTypeBarChart({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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
              height: 350,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelRotation: -45,
                  labelStyle: TextStyle(fontSize: 11),
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
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y kg',
                  textStyle: const TextStyle(fontSize: 12),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<WasteTypeData, String>(
                    dataSource: data,
                    xValueMapper: (WasteTypeData item, _) => item.name,
                    yValueMapper: (WasteTypeData item, _) => item.quantity,
                    pointColorMapper: (WasteTypeData item, int index) =>
                        _getColorForIndex(index),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(fontSize: 10),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    width: 0.7,
                    spacing: 0.1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final wasteType = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorForIndex(index),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${wasteType.name}: ${_formatQuantity(wasteType.quantity)} kg',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
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
    ];
    return colors[index % colors.length];
  }

  String _formatQuantity(double quantity) {
    if (quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1)}k';
    }
    final isInt = quantity % 1 == 0;
    return isInt ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(1);
  }
}

class WasteTypeData {
  final String name;
  final double quantity;

  WasteTypeData({required this.name, required this.quantity});
}
