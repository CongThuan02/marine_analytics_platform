import 'package:marine_analytics_platform/data/models/singUp.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterException implements Exception {
  final String message;
  const RegisterException(this.message);

  @override
  String toString() => message;
}

class UserProfileRepository {
  Future<String> signUp({required SingUp singUp}) async {
    final email = singUp.email?.trim();
    final password = singUp.password?.trim();
    final departmentId = singUp.departmentId?.trim();
    final role = singUp.role?.trim();

    if (email?.isEmpty ?? true) {
      throw const RegisterException('Vui lòng nhập email.');
    }
    if (password == null || password.length < 6) {
      throw const RegisterException('Mật khẩu phải có ít nhất 6 ký tự.');
    }
    // if (departmentId?.isEmpty ?? true) {
    //   throw const RegisterException('Vui lòng chọn phòng.');
    // }
    if (role?.isEmpty ?? true) {
      throw const RegisterException('Vui lòng chọn vai trò.');
    }

    try {
      final response = await supabase.auth.signUp(email: email!, password: password, data: {'role': role});

      final user = response.user;
      if (user == null) {
        throw const RegisterException('Không thể lấy thông tin người dùng từ Supabase.');
      }

      await supabase.from('users_profile').insert({'id': user.id, 'role': role});

      final requiresConfirmation = response.session == null || user.emailConfirmedAt == null;
      return requiresConfirmation
          ? 'Đăng ký thành công. Vui lòng kiểm tra email để xác minh tài khoản.'
          : 'Đăng ký thành công.';
    } on AuthException catch (e) {
      throw RegisterException(e.message);
    } on PostgrestException catch (e) {
      throw RegisterException(e.message ?? 'Không thể lưu thông tin người dùng.');
    } catch (e) {
      throw RegisterException('Không thể đăng ký: $e');
    }
  }
}
