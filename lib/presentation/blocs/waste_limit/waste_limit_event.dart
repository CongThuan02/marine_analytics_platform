part of 'waste_limit_bloc.dart';

abstract class WasteLimitEvent extends Equatable {
  const WasteLimitEvent();

  @override
  List<Object?> get props => [];
}

class LoadWasteLimits extends WasteLimitEvent {
  const LoadWasteLimits();
}

class CreateWasteLimitEvent extends WasteLimitEvent {
  final WasteLimit limit;

  const CreateWasteLimitEvent(this.limit);

  @override
  List<Object> get props => [limit];
}

class DeleteWasteLimitEvent extends WasteLimitEvent {
  final String id;

  const DeleteWasteLimitEvent(this.id);

  @override
  List<Object> get props => [id];
}
