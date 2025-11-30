import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/reminder_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/reminder_model.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Reminder>>> fetchAll() async {
    try {
      final result = await remoteDataSource.fetchAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> fetchByDepartment(
      String departmentId) async {
    try {
      final result = await remoteDataSource.fetchByDepartment(departmentId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> create(Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);
      final result = await remoteDataSource.create(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> update(String id, Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);
      final result = await remoteDataSource.update(id, model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleEnabled(String id, bool enabled) async {
    try {
      await remoteDataSource.toggleEnabled(id, enabled);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
