import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/alert.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<Alert>>> fetchAll();
  Future<Either<Failure, List<Alert>>> fetchByArea(String areaId);
  Future<Either<Failure, Alert>> fetchById(String id);
}
