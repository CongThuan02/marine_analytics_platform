part of 'waste_entry_bloc.dart';

abstract class WasteEntryEvent extends Equatable {
  const WasteEntryEvent();

  @override
  List<Object?> get props => [];
}

class LoadWasteEntries extends WasteEntryEvent {
  const LoadWasteEntries();
}

class CreateWasteEntry extends WasteEntryEvent {
  final WasteEntryModel entry;
  const CreateWasteEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

