import 'package:equatable/equatable.dart';

class SingUp extends Equatable {
  final String? email;
  final String? password;
  final String? departmentId;
  final String? role;

  //<editor-fold desc="Data Methods">
  const SingUp({
    this.email = "",
    this.password = "",
    this.departmentId = "",
    this.role = "",
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingUp &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          departmentId == other.departmentId &&
          role == other.role);

  @override
  int get hashCode =>
      email.hashCode ^
      password.hashCode ^
      departmentId.hashCode ^
      role.hashCode;

  @override
  String toString() {
    return 'SingUp{'
            ' email: $email,' +
        ' password: $password,' +
        ' departmentId: $departmentId,' +
        ' role: $role,' +
        '}';
  }

  SingUp copyWith({
    String? email,
    String? password,
    String? departmentId,
    String? role,
  }) {
    return SingUp(
      email: email ?? this.email,
      password: password ?? this.password,
      departmentId: departmentId ?? this.departmentId,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'department_id': departmentId,
      'role': role,
    };
  }

  factory SingUp.fromMap(Map<String, dynamic> map) {
    return SingUp(
      email: map['email'],
      password: map['password'],
      departmentId: map['department_id'],
      role: map['role'],
    );
  }

  //</editor-fold>
  @override
  List<Object?> get props => [email, password, departmentId, role];
}
