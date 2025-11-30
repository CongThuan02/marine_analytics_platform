import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/waste_type_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/waste_type_model.dart';
import 'package:marine_analytics_platform/domain/entities/waste_type.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_type_repository.dart';

class WasteTypeRepositoryImpl implements WasteTypeRepository {
  final WasteTypeRemoteDataSource remoteDataSource;

  WasteTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WasteType>>> getAll() async {
    try {
      final result = await remoteDataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WasteType>> create(WasteType wasteType) async {
    try {
      final model = WasteTypeModel.fromEntity(wasteType);
      await remoteDataSource.create(model);
      return Right(wasteType);
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
