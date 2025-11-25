part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final SingUp singUp;
  const RegisterSubmitted(this.singUp);

  @override
  List<Object?> get props => [singUp];
}

class UpdateFieldEvent extends RegisterEvent {
  final String? value;
  final String key;

  const UpdateFieldEvent(this.value, this.key);

  @override
  // TODO: implement props
  List<Object?> get props => [value, key];
}
