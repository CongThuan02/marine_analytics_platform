import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cài đặt")),
      body: Column(
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed('/create/area');
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50)),
              child: Center(child: Text("Quản lý khu vực")),
            ),
          ),
        ],
      ),
    );
  }
}
