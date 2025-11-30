import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_limit_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class DeleteWasteLimit extends UseCase<void, DeleteWasteLimitParams> {
  final WasteLimitRepository repository;

  DeleteWasteLimit(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWasteLimitParams params) {
    return repository.delete(params.id);
  }
}

class DeleteWasteLimitParams {
  final String id;

  DeleteWasteLimitParams(this.id);
}
