part of 'department_bloc.dart';

class DepartmentState extends Equatable {
  final String? message;
  final List<DepartmentModel>? items;
  final Status? status;
  final DepartmentModel departmentModel;

  DepartmentState({
    this.message,
    this.items,
    this.status,
    DepartmentModel? departmentModel,
  }) : departmentModel =
           departmentModel ??
           DepartmentModel(
             id: '',
             name: '',
             areaId: null, // Initialize with null instead of empty string
             createdAt: DateTime.now(),
           );

  DepartmentState copyWith({
    final String? message,
    final List<DepartmentModel>? items,
    final Status? status,
    final DepartmentModel? departmentModel,
  }) {
    return DepartmentState(
      message: message ?? this.message,
      items: items ?? this.items,
      status: status ?? this.status,
      departmentModel: departmentModel ?? this.departmentModel,
    );
  }

  @override
  List<Object?> get props => [message, items, status, departmentModel];
}
