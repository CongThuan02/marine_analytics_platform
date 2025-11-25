part of 'waste_type_bloc.dart';

sealed class WasteTypeEvent extends Equatable {
  const WasteTypeEvent();
}

class CreateWasteTypeEvent extends WasteTypeEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UpdateFieldWasteTypeEvent extends WasteTypeEvent {
  final String? value;
  final String key;

  const UpdateFieldWasteTypeEvent({this.value, required this.key});

  @override
  List<Object?> get props => [value, key];
}

class GetWasteTypeEvent extends WasteTypeEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class DeleteWasteTypeEvent extends WasteTypeEvent {
  final String id;

  const DeleteWasteTypeEvent(this.id);

  @override
  List<Object> get props => [id];
}
