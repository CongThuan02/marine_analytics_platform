import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/presentation/views/overviews/widgets/stats_overview_tab.dart';

class OverviewYear extends StatelessWidget {
  const OverviewYear({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatsOverviewTab(
      period: StatsPeriod.year,
      emptyMessage: 'Chưa có dữ liệu chất thải cho năm này.',
    );
  }
}
