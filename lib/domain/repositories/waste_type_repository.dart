import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_type.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class WasteTypeRepository {
  Future<Either<Failure, List<WasteType>>> getAll();
  Future<Either<Failure, WasteType>> create(WasteType wasteType);
  Future<Either<Failure, void>> delete(String id);
}
