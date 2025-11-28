part of 'waste_limit_bloc.dart';

abstract class WasteLimitState extends Equatable {
  const WasteLimitState();

  @override
  List<Object> get props => [];
}

class WasteLimitInitial extends WasteLimitState {}

class WasteLimitLoading extends WasteLimitState {}

class WasteLimitLoaded extends WasteLimitState {
  final List<WasteLimit> limits;

  const WasteLimitLoaded(this.limits);

  @override
  List<Object> get props => [limits];
}

class WasteLimitError extends WasteLimitState {
  final String message;

  const WasteLimitError(this.message);

  @override
  List<Object> get props => [message];
}
