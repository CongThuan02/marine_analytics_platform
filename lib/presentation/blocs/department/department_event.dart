part of 'department_bloc.dart';

sealed class DepartmentEvent extends Equatable {
  const DepartmentEvent();
}

class CreateDepartmentEvent extends DepartmentEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UpdateFieldDepartmentEvent extends DepartmentEvent {
  final String? value;
  final String key;

  const UpdateFieldDepartmentEvent({this.value, required this.key});

  @override
  List<Object?> get props => [value, key];
}

class GetDepartmentEvent extends DepartmentEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class DeleteDepartmentEvent extends DepartmentEvent {
  final String id;

  const DeleteDepartmentEvent(this.id);

  @override
  List<Object> get props => [id];
}
