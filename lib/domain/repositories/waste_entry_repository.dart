import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_entry.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class WasteEntryRepository {
  Future<Either<Failure, List<WasteEntry>>> getAll();
  Future<Either<Failure, List<WasteEntry>>> getByDepartment(String departmentId);
  Future<Either<Failure, List<WasteEntry>>> getByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, WasteEntry>> create(WasteEntry entry);
  Future<Either<Failure, void>> delete(String id);
}
