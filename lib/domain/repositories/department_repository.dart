import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/department.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class DepartmentRepository {
  Future<Either<Failure, List<Department>>> getAll();
  Future<Either<Failure, Department>> create(Department department);
  Future<Either<Failure, void>> delete(String id);
}
