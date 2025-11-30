import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
