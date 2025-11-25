part of 'waste_limit_bloc.dart';

abstract class WasteLimitEvent extends Equatable {
  const WasteLimitEvent();

  @override
  List<Object?> get props => [];
}

class LoadWasteLimits extends WasteLimitEvent {
  final String? areaId;

  const LoadWasteLimits({this.areaId});

  @override
  List<Object?> get props => [areaId];
}

class CreateWasteLimit extends WasteLimitEvent {
  final WasteLimitModel limit;

  const CreateWasteLimit(this.limit);

  @override
  List<Object> get props => [limit];
}

class UpdateWasteLimit extends WasteLimitEvent {
  final String id;
  final WasteLimitModel limit;

  const UpdateWasteLimit(this.id, this.limit);

  @override
  List<Object> get props => [id, limit];
}

class DeleteWasteLimit extends WasteLimitEvent {
  final String id;

  const DeleteWasteLimit(this.id);

  @override
  List<Object> get props => [id];
}
