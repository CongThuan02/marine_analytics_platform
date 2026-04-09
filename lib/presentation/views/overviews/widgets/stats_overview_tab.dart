import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_stats/waste_stats_cubit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsOverviewTab extends StatelessWidget {
  final StatsPeriod period;
  final String emptyMessage;

  const StatsOverviewTab({
    super.key,
    required this.period,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WasteStatsCubit(period: period)..load(),
      child: _StatsOverviewView(period: period, emptyMessage: emptyMessage),
    );
  }
}

class _StatsOverviewView extends StatelessWidget {
  final StatsPeriod period;
  final String emptyMessage;

  const _StatsOverviewView({required this.period, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WasteStatsCubit, WasteStatsState>(
      listener: (context, state) {
        if (state.status == Status.fail && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == Status.loading && state.stats.entryCount == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = state.stats;
        final hasData = stats.breakdowns.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => context.read<WasteStatsCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PeriodSelector(
                period: period,
                date: state.referenceDate,
                onChanged: (newDate) {
                  if (newDate != null) {
                    context.read<WasteStatsCubit>().load(
                      referenceDate: newDate,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                icon: Icons.scale,
                label: 'Tổng khối lượng',
                value: '${_formatQuantity(stats.totalQuantity)} kg',
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.description_outlined,
                label: 'Số lượng bản ghi',
                value: stats.entryCount.toString(),
                color: AppTheme.secondaryTeal,
              ),
              const SizedBox(height: 24),
              if (!hasData)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      emptyMessage,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else ...[
                Text(
                  'Phân bố chất thải',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _PieChartWidget(breakdowns: stats.breakdowns),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chi tiết theo loại chất thải',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Tổng: ${_formatQuantity(stats.totalQuantity)} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Debug info - display breakdown totals
                    Builder(
                      builder: (context) {
                        final breakdownTotal = stats.breakdowns.fold<double>(
                          0,
                          (sum, item) => sum + item.quantity,
                        );
                        final percentageTotal = stats.breakdowns.fold<double>(
                          0,
                          (sum, item) =>
                              sum +
                              (stats.totalQuantity > 0
                                  ? (item.quantity / stats.totalQuantity * 100)
                                  : 0),
                        );
                        final isMatching =
                            (breakdownTotal - stats.totalQuantity).abs() < 0.01;

                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMatching
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMatching
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isMatching
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_rounded,
                                    size: 16,
                                    color: isMatching
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Kiểm tra dữ liệu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isMatching
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tổng phân tích: ${_formatQuantity(breakdownTotal)} kg\n'
                                'Tổng thống kê: ${_formatQuantity(stats.totalQuantity)} kg\n'
                                'Tổng %: ${percentageTotal.toStringAsFixed(1)}%\n'
                                'Loại: ${stats.breakdowns.length} | Bản ghi: ${stats.entryCount}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMatching
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.breakdowns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = stats.breakdowns[index];
                    // Avoid division by zero
                    final percentage = stats.totalQuantity > 0
                        ? (item.quantity / stats.totalQuantity * 100)
                        : 0.0;
                    return _BreakdownTile(
                      item: item,
                      percentage: percentage,
                      totalQuantity: stats.totalQuantity,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatsPeriod period;
  final DateTime date;
  final ValueChanged<DateTime?> onChanged;

  const _PeriodSelector({
    required this.period,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatDate(period, date),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await _pickDate(context, period, date);
            onChanged(picked);
          },
          child: const Text('Thay đổi'),
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(
    BuildContext context,
    StatsPeriod period,
    DateTime date,
  ) async {
    switch (period) {
      case StatsPeriod.day:
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(date.year - 5),
          lastDate: DateTime(date.year + 5),
        );
        return picked != null
            ? DateTime(picked.year, picked.month, picked.day)
            : null;

      case StatsPeriod.month:
        return await _showMonthYearPicker(context, date);

      case StatsPeriod.year:
        return await _showYearPicker(context, date);
    }
  }

  Future<DateTime?> _showMonthYearPicker(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = initialDate.year;
        int selectedMonth = initialDate.month;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chọn tháng và năm'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  children: [
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() => selectedYear--);
                          },
                        ),
                        Text(
                          '$selectedYear',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() => selectedYear++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Month grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          return InkWell(
                            onTap: () {
                              setState(() => selectedMonth = month);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Th $month',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(DateTime(selectedYear, selectedMonth));
                  },
                  child: const Text('Chọn'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<DateTime?> _showYearPicker(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = initialDate.year;
        final currentYear = DateTime.now().year;
        final startYear = currentYear - 10;
        final endYear = currentYear + 10;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chọn năm'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Year range display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$selectedYear',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Year grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: endYear - startYear + 1,
                        itemBuilder: (context, index) {
                          final year = startYear + index;
                          final isSelected = year == selectedYear;
                          final isCurrentYear = year == currentYear;

                          return InkWell(
                            onTap: () {
                              setState(() => selectedYear = year);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : isCurrentYear
                                    ? AppTheme.primaryGreenLight.withOpacity(
                                        0.2,
                                      )
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: isCurrentYear && !isSelected
                                    ? Border.all(
                                        color: AppTheme.primaryGreen,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$year',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected || isCurrentYear
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(DateTime(selectedYear));
                  },
                  child: const Text('Chọn'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final WasteBreakdown item;
  final double percentage;
  final double totalQuantity;

  const _BreakdownTile({
    required this.item,
    required this.percentage,
    required this.totalQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final validPercentage = percentage.isFinite && !percentage.isNaN
        ? percentage.clamp(0.0, 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${validPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.scale, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatQuantity(item.quantity)} kg',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    if (totalQuantity > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tổng: ${_formatQuantity(totalQuantity)} kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: validPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreenLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final List<WasteBreakdown> breakdowns;

  const _PieChartWidget({required this.breakdowns});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCircularChart(
        // title: ChartTitle(
        //   text: 'Distribution Ratio (%)',
        //   textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        // ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: const TextStyle(fontSize: 11),
          toggleSeriesVisibility: true,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x\npoint.y kg (%)',
        ),
        series: <PieSeries<WasteBreakdown, String>>[
          PieSeries<WasteBreakdown, String>(
            dataSource: breakdowns,
            xValueMapper: (data, _) => data.name,
            yValueMapper: (data, _) => data.quantity,
            dataLabelMapper: (data, index) {
              // Only show label for parts larger than 5%
              final total = breakdowns.fold<double>(
                0,
                (sum, item) => sum + item.quantity,
              );
              final percent = (data.quantity / total) * 100;
              if (percent < 5) return '';
              return '${percent.toStringAsFixed(1)}%';
            },
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.curve,
                length: '10%',
              ),
            ),
            explode: true,
            explodeIndex: 0,
            explodeOffset: '5%',
            pointColorMapper: (data, index) => _getChartColor(index),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}

Color _getChartColor(int index) {
  // Environment and nature friendly color palette
  final colors = [
    AppTheme.primaryGreenLight, // Green
    AppTheme.secondaryTealLight, // Teal
    AppTheme.accentBrown, // Brown
    AppTheme.accentBlue, // Blue
    const Color(0xFF9CCC65), // Light green
    const Color(0xFF00897B), // Moss green
    const Color(0xFFA1887F), // Sand brown
    const Color(0xFF29B6F6), // Ocean blue
    AppTheme.accentOlive, // Olive green
    const Color(0xFF00ACC1), // Cyan
  ];
  return colors[index % colors.length];
}

String _formatQuantity(double quantity) {
  final isInt = quantity % 1 == 0;
  return isInt ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2);
}

String _formatDate(StatsPeriod period, DateTime date) {
  switch (period) {
    case StatsPeriod.day:
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    case StatsPeriod.month:
      final month = date.month.toString().padLeft(2, '0');
      return 'Month $month/${date.year}';
    case StatsPeriod.year:
      return 'Year ${date.year}';
  }
}
