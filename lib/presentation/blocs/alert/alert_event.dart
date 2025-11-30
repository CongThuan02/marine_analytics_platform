part of 'alert_bloc.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object> get props => [];
}

class LoadAlerts extends AlertEvent {
  const LoadAlerts();
}
