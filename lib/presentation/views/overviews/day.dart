import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/presentation/views/overviews/widgets/stats_overview_tab.dart';

class OverviewDay extends StatelessWidget {
  const OverviewDay({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatsOverviewTab(
      period: StatsPeriod.day,
      emptyMessage: 'No waste data for this day.',
    );
  }
}
