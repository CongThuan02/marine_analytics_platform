import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_limit_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class CreateWasteLimit extends UseCase<WasteLimit, CreateWasteLimitParams> {
  final WasteLimitRepository repository;

  CreateWasteLimit(this.repository);

  @override
  Future<Either<Failure, WasteLimit>> call(CreateWasteLimitParams params) {
    return repository.create(params.limit);
  }
}

class CreateWasteLimitParams {
  final WasteLimit limit;

  CreateWasteLimitParams(this.limit);
}
