import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/constants/app_strings.dart';

import 'overviews/day.dart';
import 'overviews/moth.dart';
import 'overviews/year.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            TabBar(
              indicator: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(12),
              unselectedLabelColor: Colors.black,
              labelColor: Colors.white,

              tabs: [
                Tab(child: Text("Day")),
                Tab(child: Text("Month")),
                Tab(child: Text("Year")),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [OverviewDay(), OverviewMoth(), OverviewYear()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
