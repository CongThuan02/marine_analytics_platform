import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/data/repositories/waste_entry_repository.dart';

part 'waste_entry_event.dart';
part 'waste_entry_state.dart';

class WasteEntryBloc extends Bloc<WasteEntryEvent, WasteEntryState> {
  final WasteEntryRepository _repository;

  WasteEntryBloc({WasteEntryRepository? repository})
    : _repository = repository ?? WasteEntryRepository(),
      super(const WasteEntryState()) {
    on<LoadWasteEntries>(_onLoad);
    on<CreateWasteEntry>(_onCreate);
    on<ImportMultipleWasteEntries>(_onImportMultiple);
  }

  Future<void> _onLoad(
    LoadWasteEntries event,
    Emitter<WasteEntryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, clearMessage: true));
    try {
      final entries = await _repository.fetchWasteEntries();
      emit(
        state.copyWith(
          status: Status.loaded,
          entries: entries,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.fail, message: e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateWasteEntry event,
    Emitter<WasteEntryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, clearMessage: true));
    try {
      final message = await _repository.createWasteEntry(entry: event.entry);
      final entries = await _repository.fetchWasteEntries();
      emit(
        state.copyWith(
          status: Status.success,
          message: message,
          entries: entries,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.fail, message: e.toString()));
    }
  }

  Future<void> _onImportMultiple(
    ImportMultipleWasteEntries event,
    Emitter<WasteEntryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, clearMessage: true));
    try {
      int successCount = 0;
      int failCount = 0;

      for (final entry in event.entries) {
        try {
          await _repository.createWasteEntry(entry: entry);
          successCount++;
        } catch (e) {
          failCount++;
          print('Lỗi khi import entry: $e');
        }
      }

      final entries = await _repository.fetchWasteEntries();
      final message = failCount == 0
          ? 'Import thành công $successCount bản ghi'
          : 'Import thành công $successCount bản ghi, thất bại $failCount bản ghi';

      emit(
        state.copyWith(
          status: failCount == 0 ? Status.success : Status.fail,
          message: message,
          entries: entries,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.fail,
          message: 'Lỗi khi import: ${e.toString()}',
        ),
      );
    }
  }
}
