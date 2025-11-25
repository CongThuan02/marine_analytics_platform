part of 'register_bloc.dart';

class RegisterState extends Equatable {
  final Status status;
  final String? message;

  const RegisterState({this.status = Status.init, this.message});

  RegisterState copyWith({Status? status, String? message}) {
    return RegisterState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
