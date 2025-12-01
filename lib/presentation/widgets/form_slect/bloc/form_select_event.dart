part of 'form_select_bloc.dart';

class FormSelectEvent extends Equatable {
  const FormSelectEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetItemsFormEvent extends FormSelectEvent {
  final String tableName;
  final String? filterColumn;
  final String? filterValue;

  const GetItemsFormEvent({
    required this.tableName,
    this.filterColumn,
    this.filterValue,
  });

  @override
  List<Object?> get props => [tableName, filterColumn, filterValue];
}

class UpdateFiledFormEvent extends FormSelectEvent {
  final String? value;

  const UpdateFiledFormEvent(this.value);

  @override
  List<Object?> get props => [value];
}
