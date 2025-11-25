import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/data/models/waste_limit_model.dart';
import 'package:marine_analytics_platform/data/repositories/waste_limit_repository.dart';

part 'waste_limit_event.dart';
part 'waste_limit_state.dart';

class WasteLimitBloc extends Bloc<WasteLimitEvent, WasteLimitState> {
  final WasteLimitRepository _repository;

  WasteLimitBloc({WasteLimitRepository? repository})
      : _repository = repository ?? WasteLimitRepository(),
        super(WasteLimitInitial()) {
    on<LoadWasteLimits>(_onLoadWasteLimits);
    on<CreateWasteLimit>(_onCreateWasteLimit);
    on<UpdateWasteLimit>(_onUpdateWasteLimit);
    on<DeleteWasteLimit>(_onDeleteWasteLimit);
  }

  Future<void> _onLoadWasteLimits(
    LoadWasteLimits event,
    Emitter<WasteLimitState> emit,
  ) async {
    emit(WasteLimitLoading());
    try {
      final limits = event.areaId != null
          ? await _repository.fetchByArea(event.areaId!)
          : await _repository.fetchAll();
      emit(WasteLimitLoaded(limits));
    } catch (e) {
      emit(WasteLimitError(e.toString()));
    }
  }

  Future<void> _onCreateWasteLimit(
    CreateWasteLimit event,
    Emitter<WasteLimitState> emit,
  ) async {
    try {
      await _repository.create(event.limit);
      add(LoadWasteLimits());
    } catch (e) {
      emit(WasteLimitError(e.toString()));
    }
  }

  Future<void> _onUpdateWasteLimit(
    UpdateWasteLimit event,
    Emitter<WasteLimitState> emit,
  ) async {
    try {
      await _repository.update(event.id, event.limit);
      add(LoadWasteLimits());
    } catch (e) {
      emit(WasteLimitError(e.toString()));
    }
  }

  Future<void> _onDeleteWasteLimit(
    DeleteWasteLimit event,
    Emitter<WasteLimitState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      add(LoadWasteLimits());
    } catch (e) {
      emit(WasteLimitError(e.toString()));
    }
  }
}
