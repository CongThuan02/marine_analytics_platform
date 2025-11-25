part of 'alert_bloc.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object> get props => [];
}

class LoadAlerts extends AlertEvent {}

class LoadTodayAlerts extends AlertEvent {}

class CheckAndCreateAlerts extends AlertEvent {}

class DeleteAlert extends AlertEvent {
  final String id;

  const DeleteAlert(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteOldAlerts extends AlertEvent {}
