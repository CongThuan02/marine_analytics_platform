import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/presentation/views/overviews/widgets/LineChartModel.dart';
import 'package:marine_analytics_platform/presentation/views/overviews/widgets/PieChartNoModel.dart';

class OverviewDay extends StatelessWidget {
  const OverviewDay({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [PieChartNoModel(), LineChartExample()]));
  }
}
