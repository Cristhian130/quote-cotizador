import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché local']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Error de base de datos']);
}
