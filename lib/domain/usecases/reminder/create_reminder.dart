import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class CreateReminder extends UseCase<Reminder, CreateReminderParams> {
  final ReminderRepository repository;

  CreateReminder(this.repository);

  @override
  Future<Either<Failure, Reminder>> call(CreateReminderParams params) {
    return repository.create(params.reminder);
  }
}

class CreateReminderParams {
  final Reminder reminder;

  CreateReminderParams(this.reminder);
}
