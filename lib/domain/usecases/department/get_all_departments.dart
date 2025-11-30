import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/department.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/department_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllDepartments extends UseCase<List<Department>, NoParams> {
  final DepartmentRepository repository;

  GetAllDepartments(this.repository);

  @override
  Future<Either<Failure, List<Department>>> call(NoParams params) {
    return repository.getAll();
  }
}
