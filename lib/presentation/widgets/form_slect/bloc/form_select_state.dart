part of 'form_select_bloc.dart';

class FormSelectState extends Equatable {
  final Status status;
  final List<Map<String, dynamic>> items;
  final String? selected;

  const FormSelectState({this.status = Status.init, required this.items, this.selected});

  FormSelectState copyWith({final Status? status, final List<Map<String, dynamic>>? items, final String? selected}) {
    return FormSelectState(
      status: status ?? this.status,
      items: items ?? this.items,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [status, items, selected];
}
