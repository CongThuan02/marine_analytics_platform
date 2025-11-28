import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/alert.dart';
import 'package:marine_analytics_platform/domain/usecases/alert/get_all_alerts.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

part 'alert_event.dart';
part 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetAllAlerts getAllAlerts;

  AlertBloc({required this.getAllAlerts}) : super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());
    final result = await getAllAlerts(NoParams());
    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }
}
