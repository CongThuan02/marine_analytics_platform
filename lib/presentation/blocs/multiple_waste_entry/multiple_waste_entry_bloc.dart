import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/data/repositories/waste_entry_repository.dart';
import 'package:marine_analytics_platform/global.dart';

part 'multiple_waste_entry_event.dart';
part 'multiple_waste_entry_state.dart';

class MultipleWasteEntryBloc
    extends Bloc<MultipleWasteEntryEvent, MultipleWasteEntryState> {
  final WasteEntryRepository _repository;

  MultipleWasteEntryBloc({WasteEntryRepository? repository})
      : _repository = repository ?? WasteEntryRepository(),
        super(const MultipleWasteEntryState()) {
    on<AddWasteItemEvent>(_onAddWasteItem);
    on<RemoveWasteItemEvent>(_onRemoveWasteItem);
    on<UpdateWasteTypeEvent>(_onUpdateWasteType);
    on<SubmitMultipleEntriesEvent>(_onSubmitMultipleEntries);
    on<ResetMultipleEntriesEvent>(_onReset);
  }

  void _onAddWasteItem(
    AddWasteItemEvent event,
    Emitter<MultipleWasteEntryState> emit,
  ) {
    final updatedItems = List<WasteItemState>.from(state.wasteItems)
      ..add(const WasteItemState());
    emit(state.copyWith(wasteItems: updatedItems));
  }

  void _onRemoveWasteItem(
    RemoveWasteItemEvent event,
    Emitter<MultipleWasteEntryState> emit,
  ) {
    if (state.wasteItems.length <= 1) return;

    final updatedItems = List<WasteItemState>.from(state.wasteItems)
      ..removeAt(event.index);
    emit(state.copyWith(wasteItems: updatedItems));
  }

  void _onUpdateWasteType(
    UpdateWasteTypeEvent event,
    Emitter<MultipleWasteEntryState> emit,
  ) {
    final updatedItems = List<WasteItemState>.from(state.wasteItems);
    updatedItems[event.index] = updatedItems[event.index].copyWith(
      wasteTypeId: event.wasteTypeId,
      wasteTypeName: event.name,
      unit: event.unit,
    );
    emit(state.copyWith(wasteItems: updatedItems));
  }

  Future<void> _onSubmitMultipleEntries(
    SubmitMultipleEntriesEvent event,
    Emitter<MultipleWasteEntryState> emit,
  ) async {
    emit(state.copyWith(status: MultipleWasteEntryStatus.loading));

    try {
      int successCount = 0;

      for (int i = 0; i < state.wasteItems.length; i++) {
        final item = state.wasteItems[i];
        final quantity = event.quantities[i];

        if (item.wasteTypeId == null ||
            item.wasteTypeId!.isEmpty ||
            item.wasteTypeId == 'select') {
          emit(state.copyWith(
            status: MultipleWasteEntryStatus.error,
            errorMessage: 'Please select waste type for item ${i + 1}',
          ));
          return;
        }

        if (quantity == null || quantity <= 0) {
          emit(state.copyWith(
            status: MultipleWasteEntryStatus.error,
            errorMessage: 'Invalid quantity for item ${i + 1}',
          ));
          return;
        }

        final entry = WasteEntryModel(
          id: '',
          userId: supabase.auth.currentUser?.id ?? '',
          areaId: event.areaId,
          departmentId: event.departmentId,
          wasteTypeId: item.wasteTypeId!,
          date: event.date,
          quantity: quantity,
          qrCode: null,
          createdAt: DateTime.now(),
        );

        await _repository.createWasteEntry(entry: entry);
        successCount++;
      }

      emit(state.copyWith(
        status: MultipleWasteEntryStatus.success,
        entriesCreated: successCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MultipleWasteEntryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onReset(
    ResetMultipleEntriesEvent event,
    Emitter<MultipleWasteEntryState> emit,
  ) {
    emit(const MultipleWasteEntryState());
  }
}
