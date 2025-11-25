import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cài đặt"), centerTitle: true),
      body: Column(
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          Padding(
            padding: .symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed('/create/area');
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50)),
              child: Center(child: Text("Quản lý khu vực")),
            ),
          ),
          Padding(
            padding: .symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed('/department');
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50)),
              child: Center(child: Text("Quản lý phòng ban")),
            ),
          ),
          Padding(
            padding: .symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed('/wasteType');
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50)),
              child: Center(child: Text("Quả lý loại chất thải")),
            ),
          ),
        ],
      ),
    );
  }
}
