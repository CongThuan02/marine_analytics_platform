import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class DeleteReminder extends UseCase<void, DeleteReminderParams> {
  final ReminderRepository repository;

  DeleteReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReminderParams params) {
    return repository.delete(params.id);
  }
}

class DeleteReminderParams {
  final String id;

  DeleteReminderParams(this.id);
}
