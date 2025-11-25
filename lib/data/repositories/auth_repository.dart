import 'package:marine_analytics_platform/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginFailure implements Exception {
  final String message;
  const LoginFailure(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  Future<String> signIn({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) throw const LoginFailure('Vui lòng nhập email.');
    if (trimmedPassword.isEmpty) throw const LoginFailure('Vui lòng nhập mật khẩu.');

    try {
      final response = await supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      if (response.session == null) {
        throw const LoginFailure('Không thể tạo phiên đăng nhập.');
      }

      return 'Đăng nhập thành công.';
    } on AuthException catch (e) {
      throw LoginFailure(e.message);
    } catch (e) {
      throw LoginFailure('Không thể đăng nhập: $e');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

