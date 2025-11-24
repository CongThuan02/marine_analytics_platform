part of 'area_bloc.dart';

class AreaEvent extends Equatable {
  const AreaEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CreateArea extends AreaEvent {
  const CreateArea();

  @override
  List<Object> get props => [];
}

class UpdateFieldName extends AreaEvent {
  final String name;
  const UpdateFieldName({required this.name});
  @override
  List<Object?> get props => [name];
}

class GetAreas extends AreaEvent {}
class DeleteArea extends AreaEvent{
  final String id;
  const DeleteArea({required this.id});
  @override
  List<Object?> get props => [id];
}
