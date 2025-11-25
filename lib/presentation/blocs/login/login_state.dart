part of 'login_bloc.dart';

class LoginState extends Equatable {
  final Status status;
  final String? message;

  const LoginState({this.status = Status.init, this.message});

  LoginState copyWith({Status? status, String? message}) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

