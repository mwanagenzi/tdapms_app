class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Showing cached data.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Your session has expired. Please log in again.');
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(super.message, this.errors);

  String get firstError {
    if (errors.isEmpty) return message;
    return errors.values.first.first;
  }
}

class ServerException extends AppException {
  const ServerException(super.message);
}
