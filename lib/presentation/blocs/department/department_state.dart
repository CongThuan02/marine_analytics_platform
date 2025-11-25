part of 'department_bloc.dart';

class DepartmentState extends Equatable {
  final String? message;
  final List<DepartmentModel>? items;
  final Status? status;
  final DepartmentModel departmentModel;

  const DepartmentState({
    this.message,
    this.items,
    this.status,
    this.departmentModel = const DepartmentModel(name: "", areaId: ""),
  });

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
