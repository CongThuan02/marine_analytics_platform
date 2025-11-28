import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/presentation/widgets/app_logo_title.dart';

import 'overviews/day.dart';
import 'overviews/moth.dart';
import 'overviews/trend.dart';
import 'overviews/year.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Column(
          children: [
            TabBar(
              indicator: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(12),
              unselectedLabelColor: Colors.black,
              labelColor: Colors.white,
              isScrollable: true,
              tabs: [
                Tab(child: Text("Day")),
                Tab(child: Text("Month")),
                Tab(child: Text("Year")),
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 16),
                      SizedBox(width: 4),
                      Text("Trend"),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  OverviewDay(),
                  OverviewMoth(),
                  OverviewYear(),
                  OverviewTrend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
