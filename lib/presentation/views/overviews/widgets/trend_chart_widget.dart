import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TrendData {
  final String period;
  final double quantity;
  final DateTime date;

  TrendData({
    required this.period,
    required this.quantity,
    required this.date,
  });
}

class TrendChartWidget extends StatelessWidget {
  final List<TrendData> trendData;
  final String title;
  final String xAxisTitle;

  const TrendChartWidget({
    super.key,
    required this.trendData,
    required this.title,
    required this.xAxisTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      height: 380,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: title,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(
            text: xAxisTitle,
            textStyle: const TextStyle(fontSize: 12),
          ),
          labelStyle: const TextStyle(fontSize: 10),
          majorGridLines: const MajorGridLines(width: 0),
          labelRotation: trendData.length > 6 ? -45 : 0,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'Total Quantity (kg)',
            textStyle: const TextStyle(fontSize: 12),
          ),
          labelStyle: const TextStyle(fontSize: 10),
          majorGridLines: MajorGridLines(
            width: 1,
            color: Colors.grey.shade200,
          ),
          minimum: 0,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x\npoint.y kg',
          textStyle: const TextStyle(fontSize: 12),
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enableDoubleTapZooming: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        series: <CartesianSeries<TrendData, String>>[
          // Line series
          LineSeries<TrendData, String>(
            dataSource: trendData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.quantity,
            name: 'Waste Quantity',
            color: AppTheme.primaryGreen,
            width: 3,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
              borderWidth: 2,
              borderColor: AppTheme.primaryGreen,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
              builder: (data, point, series, pointIndex, seriesIndex) {
                final trendData = data as TrendData;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatQuantity(trendData.quantity),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                );
              },
            ),
          ),
          // Area series for gradient effect
          AreaSeries<TrendData, String>(
            dataSource: trendData,
            xValueMapper: (data, _) => data.period,
            yValueMapper: (data, _) => data.quantity,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreenLight.withOpacity(0.3),
                AppTheme.primaryGreenLight.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1)}t';
    }
    final isInt = quantity % 1 == 0;
    return isInt
        ? '${quantity.toStringAsFixed(0)}kg'
        : '${quantity.toStringAsFixed(1)}kg';
  }
}
