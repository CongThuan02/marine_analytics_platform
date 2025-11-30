import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/alert.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/alert_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllAlerts extends UseCase<List<Alert>, NoParams> {
  final AlertRepository repository;

  GetAllAlerts(this.repository);

  @override
  Future<Either<Failure, List<Alert>>> call(NoParams params) {
    return repository.fetchAll();
  }
}
