import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_limit_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllWasteLimits extends UseCase<List<WasteLimit>, NoParams> {
  final WasteLimitRepository repository;

  GetAllWasteLimits(this.repository);

  @override
  Future<Either<Failure, List<WasteLimit>>> call(NoParams params) {
    return repository.fetchAll();
  }
}
