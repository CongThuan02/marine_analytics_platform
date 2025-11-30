import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/area_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/domain/entities/area.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/area_repository.dart';

class AreaRepositoryImpl implements AreaRepository {
  final AreaRemoteDataSource remoteDataSource;

  AreaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Area>>> getAll() async {
    try {
      final result = await remoteDataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Area>> create(Area area) async {
    try {
      final model = AreaModel.fromEntity(area);
      await remoteDataSource.create(model);
      return Right(area);
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
