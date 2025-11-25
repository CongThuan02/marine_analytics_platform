part of 'form_select_bloc.dart';

class FormSelectEvent extends Equatable {
  const FormSelectEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetItemsFormEvent extends FormSelectEvent {
  final String tableName;

  const GetItemsFormEvent({required this.tableName});

  @override
  // TODO: implement props
  List<Object?> get props => [tableName];
}

class UpdateFiledFormEvent extends FormSelectEvent {
  final String? value;

  const UpdateFiledFormEvent(this.value);

  @override
  List<Object?> get props => [value];
}
