import 'app_error.dart';

/// A value or an [AppError], never a thrown exception across layer boundaries.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(AppError error) onErr, R Function(T value) onOk) => switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final error) => onErr(error),
      };

  Result<R> map<R>(R Function(T value) f) => switch (this) {
        Ok(:final value) => Ok(f(value)),
        Err(:final error) => Err(error),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}
