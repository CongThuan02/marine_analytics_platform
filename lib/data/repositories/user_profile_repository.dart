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
      throw const RegisterException('Please enter email.');
    }
    if (password == null || password.length < 6) {
      throw const RegisterException('Password must be at least 6 characters.');
    }
    if (departmentId?.isEmpty ?? true) {
      throw const RegisterException('Please select a department.');
    }
    if (role?.isEmpty ?? true) {
      throw const RegisterException('Please select a role.');
    }

    try {
      final response = await supabase.auth.signUp(
        email: email!,
        password: password,
        data: {'department_id': departmentId, 'role': role},
      );

      final user = response.user;
      if (user == null) {
        throw const RegisterException(
          'Unable to get user information from Supabase.',
        );
      }

      await supabase.from('users_profile').insert({
        'id': user.id,
        'department_id': departmentId,
        'role': role,
      });

      final requiresConfirmation =
          response.session == null || user.emailConfirmedAt == null;
      return requiresConfirmation
          ? 'Registration successful. Please check your email to verify your account.'
          : 'Registration successful.';
    } on AuthException catch (e) {
      throw RegisterException(e.message);
    } on PostgrestException catch (e) {
      throw RegisterException(e.message ?? 'Unable to save user information.');
    } catch (e) {
      throw RegisterException('Unable to register: $e');
    }
  }
}
