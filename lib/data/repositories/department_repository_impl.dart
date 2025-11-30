import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/department_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/domain/entities/department.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remoteDataSource;

  DepartmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Department>>> getAll() async {
    try {
      final result = await remoteDataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Department>> create(Department department) async {
    try {
      final model = DepartmentModel.fromEntity(department);
      await remoteDataSource.create(model);
      return Right(department);
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
