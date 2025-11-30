import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<Reminder>>> fetchAll();
  Future<Either<Failure, List<Reminder>>> fetchByDepartment(String departmentId);
  Future<Either<Failure, Reminder>> create(Reminder reminder);
  Future<Either<Failure, Reminder>> update(String id, Reminder reminder);
  Future<Either<Failure, void>> toggleEnabled(String id, bool enabled);
  Future<Either<Failure, void>> delete(String id);
}
