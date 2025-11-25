part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {
  final String? departmentId;

  const LoadReminders({this.departmentId});

  @override
  List<Object?> get props => [departmentId];
}

class CreateReminder extends ReminderEvent {
  final ReminderModel reminder;

  const CreateReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class UpdateReminder extends ReminderEvent {
  final String id;
  final ReminderModel reminder;

  const UpdateReminder(this.id, this.reminder);

  @override
  List<Object> get props => [id, reminder];
}

class ToggleReminder extends ReminderEvent {
  final String id;
  final bool enabled;

  const ToggleReminder(this.id, this.enabled);

  @override
  List<Object> get props => [id, enabled];
}

class DeleteReminder extends ReminderEvent {
  final String id;

  const DeleteReminder(this.id);

  @override
  List<Object> get props => [id];
}
