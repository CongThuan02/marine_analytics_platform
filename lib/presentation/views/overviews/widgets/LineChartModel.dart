import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu nhiều hơn 10 điểm để scroll
    final List<Map<String, dynamic>> data = [
      {'day': 'Mon', 'value': 30},
      {'day': 'Tue', 'value': 40},
      {'day': 'Wed', 'value': 35},
      {'day': 'Thu', 'value': 50},
      {'day': 'Fri', 'value': 45},
      {'day': 'Sat', 'value': 38},
      {'day': 'Sun', 'value': 42},
      {'day': 'Mon2', 'value': 48},
      {'day': 'Tue2', 'value': 50},
      {'day': 'Wed2', 'value': 55},
      {'day': 'Thu2', 'value': 53},
      {'day': 'Fri2', 'value': 60},
      {'day': 'Sat2', 'value': 62},
      {'day': 'Sun2', 'value': 58},
    ];

    return Center(
      child: SizedBox(
        width: data.length * 60,
        height: 300,
        child: SfCartesianChart(
          enableMultiSelection: true,
          enableAxisAnimation: true,
          enableSideBySideSeriesPlacement: true,
          title: ChartTitle(text: 'Weekly Values'),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(initialVisibleMaximum: 5, autoScrollingMode: AutoScrollingMode.start),
          primaryYAxis: NumericAxis(),
          series: <LineSeries<Map<String, dynamic>, String>>[
            LineSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (datum, _) => datum['day'] as String,
              yValueMapper: (datum, _) => double.parse('${datum['value']}'),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Scroll ngang
            zoomMode: ZoomMode.x, // Chỉ scroll trục X
          ),
        ),
      ),
    );
  }
}
