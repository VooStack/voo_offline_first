import 'package:equatable/equatable.dart';
import '../../core/utils/typedef.dart';

/// Base use case class that all use cases should extend
abstract class UseCase<Type, Params> {
  const UseCase();

  ResultFuture<Type> call(Params params);
}

/// Use case without parameters
abstract class UseCaseWithoutParams<Type> {
  const UseCaseWithoutParams();

  ResultFuture<Type> call();
}

/// Base class for use case parameters
abstract class Params extends Equatable {
  const Params();
}

/// Empty parameters for use cases that don't need parameters
class NoParams extends Params {
  const NoParams();

  @override
  List<Object?> get props => [];
}
