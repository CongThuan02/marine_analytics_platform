part of 'department_bloc.dart';

sealed class DepartmentState extends Equatable {
  const DepartmentState();
}

final class DepartmentInitial extends DepartmentState {
  @override
  List<Object> get props => [];
}
