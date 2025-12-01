import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/repositories/waste_stats_repository.dart';
import 'package:marine_analytics_platform/presentation/views/overviews/widgets/trend_chart_widget.dart';

class TrendComparisonTab extends StatefulWidget {
  const TrendComparisonTab({super.key});

  @override
  State<TrendComparisonTab> createState() => _TrendComparisonTabState();
}

class _TrendComparisonTabState extends State<TrendComparisonTab> {
  final _repository = WasteStatsRepository();
  TrendPeriod _selectedPeriod = TrendPeriod.monthly;
  List<TrendDataPoint>? _trendData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.fetchTrendData(
        trendPeriod: _selectedPeriod,
        endDate: DateTime.now(),
        periodsCount: _selectedPeriod == TrendPeriod.monthly ? 12 : 5,
      );

      setState(() {
        _trendData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTrendData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khoảng thời gian so sánh',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<TrendPeriod>(
                    segments: const [
                      ButtonSegment(
                        value: TrendPeriod.monthly,
                        label: Text('Hàng tháng'),
                        icon: Icon(Icons.calendar_view_month),
                      ),
                      ButtonSegment(
                        value: TrendPeriod.yearly,
                        label: Text('Hàng năm'),
                        icon: Icon(Icons.calendar_today),
                      ),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<TrendPeriod> newSelection) {
                      setState(() {
                        _selectedPeriod = newSelection.first;
                      });
                      _loadTrendData();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryGreen;
                        }
                        return null;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return AppTheme.primaryGreen;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Loading or error state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lỗi tải dữ liệu',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_trendData != null) ...[
            // Summary cards
            _buildSummaryCards(),
            const SizedBox(height: 16),

            // Trend chart
            TrendChartWidget(
              trendData: _trendData!
                  .map(
                    (e) => TrendData(
                      period: e.period,
                      quantity: e.quantity,
                      date: e.date,
                    ),
                  )
                  .toList(),
              title: _selectedPeriod == TrendPeriod.monthly
                  ? 'Xu hướng rác thải theo tháng (12 tháng gần nhất)'
                  : 'Xu hướng rác thải theo năm (5 năm gần nhất)',
              xAxisTitle: _selectedPeriod == TrendPeriod.monthly
                  ? 'Tháng'
                  : 'Year',
            ),
            const SizedBox(height: 24),

            // Statistics table
            _buildStatisticsTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_trendData == null || _trendData!.isEmpty) return const SizedBox();

    final totalQuantity = _trendData!.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final avgQuantity = totalQuantity / _trendData!.length;
    final maxPeriod = _trendData!.reduce(
      (a, b) => a.quantity > b.quantity ? a : b,
    );
    final minPeriod = _trendData!.reduce(
      (a, b) => a.quantity < b.quantity ? a : b,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.trending_up,
                label: 'Tổng',
                value: '${_formatQuantity(totalQuantity)} kg',
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.show_chart,
                label: 'Trung bình',
                value: '${_formatQuantity(avgQuantity)} kg',
                color: AppTheme.secondaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_upward,
                label: 'Cao nhất',
                value:
                    '${maxPeriod.period}\n${_formatQuantity(maxPeriod.quantity)} kg',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_downward,
                label: 'Thấp nhất',
                value:
                    '${minPeriod.period}\n${_formatQuantity(minPeriod.quantity)} kg',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsTable() {
    if (_trendData == null || _trendData!.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê chi tiết',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight.withOpacity(0.2),
                  ),
                  children: [
                    _buildTableCell('Period', isHeader: true),
                    _buildTableCell('Quantity (kg)', isHeader: true),
                    _buildTableCell('Entries', isHeader: true),
                  ],
                ),
                // Data rows
                ..._trendData!.map((data) {
                  return TableRow(
                    children: [
                      _buildTableCell(data.period),
                      _buildTableCell(_formatQuantity(data.quantity)),
                      _buildTableCell(data.entryCount.toString()),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 13 : 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatQuantity(double quantity) {
    final isInt = quantity % 1 == 0;
    return isInt ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2);
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
