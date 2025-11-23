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
