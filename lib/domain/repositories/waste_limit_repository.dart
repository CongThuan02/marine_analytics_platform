import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class WasteLimitRepository {
  Future<Either<Failure, List<WasteLimit>>> fetchAll();
  Future<Either<Failure, List<WasteLimit>>> fetchByArea(String areaId);
  Future<Either<Failure, WasteLimit>> create(WasteLimit limit);
  Future<Either<Failure, WasteLimit>> update(String id, WasteLimit limit);
  Future<Either<Failure, void>> delete(String id);
}
