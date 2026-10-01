/// Every failure the app can show, as a closed set.
///
/// The data layer translates SDK/HTTP exceptions into one of these; presentation picks the
/// user-facing copy. Nothing above the data layer sees a raw exception.
sealed class AppError {
  const AppError();
}

final class NetworkError extends AppError {
  const NetworkError();
}

final class NotFoundError extends AppError {
  const NotFoundError();
}

final class UnauthorisedError extends AppError {
  const UnauthorisedError();
}

/// Server-side validation, keyed by field name so forms can show errors next to fields.
final class ValidationError extends AppError {
  const ValidationError(this.fieldErrors);
  final Map<String, String> fieldErrors;
}

final class UnknownError extends AppError {
  const UnknownError(this.cause);
  final Object cause;
}
