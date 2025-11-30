import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/waste_limit_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/waste_limit_model.dart';
import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_limit_repository.dart';

class WasteLimitRepositoryImpl implements WasteLimitRepository {
  final WasteLimitRemoteDataSource remoteDataSource;

  WasteLimitRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WasteLimit>>> fetchAll() async {
    try {
      final result = await remoteDataSource.fetchAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WasteLimit>>> fetchByArea(String areaId) async {
    try {
      final result = await remoteDataSource.fetchByArea(areaId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WasteLimit>> create(WasteLimit limit) async {
    try {
      final model = WasteLimitModel.fromEntity(limit);
      final result = await remoteDataSource.create(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WasteLimit>> update(
      String id, WasteLimit limit) async {
    try {
      final model = WasteLimitModel.fromEntity(limit);
      final result = await remoteDataSource.update(id, model);
      return Right(result);
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
