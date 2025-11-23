import 'package:flutter/material.dart';

import 'overviews/day.dart';
import 'overviews/moth.dart';
import 'overviews/year.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
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
                Tab(child: Text("Ngày")),
                Tab(child: Text("Tháng")),
                Tab(child: Text("Năm")),
              ],
            ),
            Expanded(
              child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [OverviewDay(), OverviewMoth(), OverviewYear()]),
            ),
          ],
        ),
      ),
    );
  }
}
