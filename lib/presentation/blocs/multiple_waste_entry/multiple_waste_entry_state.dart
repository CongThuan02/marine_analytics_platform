part of 'multiple_waste_entry_bloc.dart';

enum MultipleWasteEntryStatus {
  initial,
  loading,
  success,
  error,
}

class WasteItemState extends Equatable {
  final String? wasteTypeId;
  final String? wasteTypeName;
  final String? unit;

  const WasteItemState({
    this.wasteTypeId,
    this.wasteTypeName,
    this.unit,
  });

  WasteItemState copyWith({
    String? wasteTypeId,
    String? wasteTypeName,
    String? unit,
  }) {
    return WasteItemState(
      wasteTypeId: wasteTypeId ?? this.wasteTypeId,
      wasteTypeName: wasteTypeName ?? this.wasteTypeName,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [wasteTypeId, wasteTypeName, unit];
}

class MultipleWasteEntryState extends Equatable {
  final MultipleWasteEntryStatus status;
  final List<WasteItemState> wasteItems;
  final String? errorMessage;
  final int? entriesCreated;

  const MultipleWasteEntryState({
    this.status = MultipleWasteEntryStatus.initial,
    this.wasteItems = const [WasteItemState()],
    this.errorMessage,
    this.entriesCreated,
  });

  MultipleWasteEntryState copyWith({
    MultipleWasteEntryStatus? status,
    List<WasteItemState>? wasteItems,
    String? errorMessage,
    int? entriesCreated,
  }) {
    return MultipleWasteEntryState(
      status: status ?? this.status,
      wasteItems: wasteItems ?? this.wasteItems,
      errorMessage: errorMessage,
      entriesCreated: entriesCreated,
    );
  }

  @override
  List<Object?> get props => [status, wasteItems, errorMessage, entriesCreated];
}
