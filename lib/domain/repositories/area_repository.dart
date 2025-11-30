import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/area.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class AreaRepository {
  Future<Either<Failure, List<Area>>> getAll();
  Future<Either<Failure, Area>> create(Area area);
  Future<Either<Failure, void>> delete(String id);
}
