import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class ToggleReminder extends UseCase<void, ToggleReminderParams> {
  final ReminderRepository repository;

  ToggleReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleReminderParams params) {
    return repository.toggleEnabled(params.id, params.enabled);
  }
}

class ToggleReminderParams {
  final String id;
  final bool enabled;

  ToggleReminderParams(this.id, this.enabled);
}
