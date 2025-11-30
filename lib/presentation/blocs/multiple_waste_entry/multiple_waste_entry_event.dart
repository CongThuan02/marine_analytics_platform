part of 'multiple_waste_entry_bloc.dart';

abstract class MultipleWasteEntryEvent extends Equatable {
  const MultipleWasteEntryEvent();

  @override
  List<Object?> get props => [];
}

class AddWasteItemEvent extends MultipleWasteEntryEvent {
  const AddWasteItemEvent();
}

class RemoveWasteItemEvent extends MultipleWasteEntryEvent {
  final int index;

  const RemoveWasteItemEvent(this.index);

  @override
  List<Object> get props => [index];
}

class UpdateWasteTypeEvent extends MultipleWasteEntryEvent {
  final int index;
  final String wasteTypeId;
  final String name;
  final String unit;

  const UpdateWasteTypeEvent({
    required this.index,
    required this.wasteTypeId,
    required this.name,
    required this.unit,
  });

  @override
  List<Object> get props => [index, wasteTypeId, name, unit];
}

class SubmitMultipleEntriesEvent extends MultipleWasteEntryEvent {
  final String areaId;
  final String departmentId;
  final DateTime date;
  final Map<int, double> quantities;

  const SubmitMultipleEntriesEvent({
    required this.areaId,
    required this.departmentId,
    required this.date,
    required this.quantities,
  });

  @override
  List<Object> get props => [areaId, departmentId, date, quantities];
}

class ResetMultipleEntriesEvent extends MultipleWasteEntryEvent {
  const ResetMultipleEntriesEvent();
}
