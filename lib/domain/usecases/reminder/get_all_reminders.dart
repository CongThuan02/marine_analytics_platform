import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllReminders extends UseCase<List<Reminder>, NoParams> {
  final ReminderRepository repository;

  GetAllReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(NoParams params) {
    return repository.fetchAll();
  }
}
