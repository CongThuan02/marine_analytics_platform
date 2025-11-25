import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập")),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              context.pushNamed('/register');
            },
            child: Text("Đăng ký tài khoản"),
          ),
        ],
      ),
    );
  }
}
