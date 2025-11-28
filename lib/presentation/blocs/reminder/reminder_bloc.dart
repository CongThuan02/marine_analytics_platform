import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/create_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/delete_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/get_all_reminders.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/toggle_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final GetAllReminders getAllReminders;
  final CreateReminder createReminder;
  final DeleteReminder deleteReminder;
  final ToggleReminder toggleReminder;

  ReminderBloc({
    required this.getAllReminders,
    required this.createReminder,
    required this.deleteReminder,
    required this.toggleReminder,
  }) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<CreateReminderEvent>(_onCreateReminder);
    on<ToggleReminderEvent>(_onToggleReminder);
    on<DeleteReminderEvent>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    final result = await getAllReminders(NoParams());
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) => emit(ReminderLoaded(reminders)),
    );
  }

  Future<void> _onCreateReminder(
    CreateReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await createReminder(CreateReminderParams(event.reminder));
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (_) => add(LoadReminders()),
    );
  }

  Future<void> _onToggleReminder(
    ToggleReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await toggleReminder(
      ToggleReminderParams(event.id, event.enabled),
    );
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (_) => add(LoadReminders()),
    );
  }

  Future<void> _onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await deleteReminder(DeleteReminderParams(event.id));
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (_) => add(LoadReminders()),
    );
  }
}
