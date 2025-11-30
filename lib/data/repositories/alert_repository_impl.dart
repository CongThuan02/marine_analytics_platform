import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/alert_remote_datasource.dart';
import 'package:marine_analytics_platform/domain/entities/alert.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  AlertRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Alert>>> fetchAll() async {
    try {
      final result = await remoteDataSource.fetchAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Alert>>> fetchByArea(String areaId) async {
    try {
      final result = await remoteDataSource.fetchByArea(areaId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Alert>> fetchById(String id) async {
    try {
      final result = await remoteDataSource.fetchById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
