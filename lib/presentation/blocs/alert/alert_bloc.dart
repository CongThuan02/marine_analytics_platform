import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/data/models/alert_model.dart';
import 'package:marine_analytics_platform/data/repositories/alert_repository.dart';

part 'alert_event.dart';
part 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository _repository;

  AlertBloc({AlertRepository? repository})
      : _repository = repository ?? AlertRepository(),
        super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<LoadTodayAlerts>(_onLoadTodayAlerts);
    on<CheckAndCreateAlerts>(_onCheckAndCreateAlerts);
    on<DeleteAlert>(_onDeleteAlert);
    on<DeleteOldAlerts>(_onDeleteOldAlerts);
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());
    try {
      final alerts = await _repository.fetchAll();
      emit(AlertLoaded(alerts));
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onLoadTodayAlerts(
    LoadTodayAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());
    try {
      final alerts = await _repository.fetchToday();
      emit(AlertLoaded(alerts));
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onCheckAndCreateAlerts(
    CheckAndCreateAlerts event,
    Emitter<AlertState> emit,
  ) async {
    try {
      final alerts = await _repository.checkAndCreateAlerts();
      emit(AlertLoaded(alerts));
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onDeleteAlert(
    DeleteAlert event,
    Emitter<AlertState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      add(LoadAlerts()); // Load tất cả alerts sau khi xóa
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onDeleteOldAlerts(
    DeleteOldAlerts event,
    Emitter<AlertState> emit,
  ) async {
    try {
      await _repository.deleteOld();
      add(LoadAlerts()); // Load tất cả alerts sau khi xóa cũ
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }
}
