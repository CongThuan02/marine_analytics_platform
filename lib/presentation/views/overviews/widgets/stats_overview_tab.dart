import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_stats/waste_stats_cubit.dart';

class StatsOverviewTab extends StatelessWidget {
  final StatsPeriod period;
  final String emptyMessage;

  const StatsOverviewTab({super.key, required this.period, required this.emptyMessage});

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
            SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state.status == Status.loading && state.stats.entryCount == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = state.stats;
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
                    context.read<WasteStatsCubit>().load(referenceDate: newDate);
                  }
                },
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                icon: Icons.scale,
                label: 'Tổng khối lượng',
                value: _formatQuantity(stats.totalQuantity),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.description_outlined,
                label: 'Số lần ghi nhận',
                value: stats.entryCount.toString(),
              ),
              const SizedBox(height: 24),
              Text('Phân bố theo loại chất thải', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (stats.breakdowns.isEmpty)
                Text(emptyMessage, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.breakdowns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = stats.breakdowns[index];
                    return _BreakdownTile(item: item);
                  },
                ),
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

  const _PeriodSelector({required this.period, required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatDate(period, date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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

  Future<DateTime?> _pickDate(BuildContext context, StatsPeriod period, DateTime date) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(date.year - 5),
      lastDate: DateTime(date.year + 5),
    );
    if (picked == null) return null;
    switch (period) {
      case StatsPeriod.day:
        return DateTime(picked.year, picked.month, picked.day);
      case StatsPeriod.month:
        return DateTime(picked.year, picked.month);
      case StatsPeriod.year:
        return DateTime(picked.year);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

  const _BreakdownTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.unit != null && item.unit!.isNotEmpty)
                  Text('Đơn vị: ${item.unit}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(_formatQuantity(item.quantity)),
        ],
      ),
    );
  }
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
      return 'Tháng $month/${date.year}';
    case StatsPeriod.year:
      return 'Năm ${date.year}';
  }
}

