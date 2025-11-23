import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: TextButton(
          onPressed: () {
            context.pushNamed('/');
          },
          child: Text("12321"),
        ),
      ),
    );
  }
}
