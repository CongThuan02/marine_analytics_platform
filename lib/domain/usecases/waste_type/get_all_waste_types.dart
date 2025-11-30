import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/waste_type.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_type_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllWasteTypes extends UseCase<List<WasteType>, NoParams> {
  final WasteTypeRepository repository;

  GetAllWasteTypes(this.repository);

  @override
  Future<Either<Failure, List<WasteType>>> call(NoParams params) {
    return repository.getAll();
  }
}
