part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {
  const LoadReminders();
}

class CreateReminderEvent extends ReminderEvent {
  final Reminder reminder;

  const CreateReminderEvent(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class ToggleReminderEvent extends ReminderEvent {
  final String id;
  final bool enabled;

  const ToggleReminderEvent(this.id, this.enabled);

  @override
  List<Object> get props => [id, enabled];
}

class DeleteReminderEvent extends ReminderEvent {
  final String id;

  const DeleteReminderEvent(this.id);

  @override
  List<Object> get props => [id];
}
