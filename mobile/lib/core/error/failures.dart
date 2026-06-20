import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({
    required String message,
    @Default(true) bool retryable,
  }) = NetworkFailure;

  const factory Failure.server({
    required String code,
    required String message,
    @Default(false) bool retryable,
    Map<String, List<String>>? fields,
  }) = ServerFailure;

  const factory Failure.unauthorized({
    @Default('Session expired. Please log in again.') String message,
  }) = UnauthorizedFailure;

  const factory Failure.validation({
    required String message,
    Map<String, List<String>>? fields,
  }) = ValidationFailure;

  const factory Failure.rateLimited({
    required String message,
    int? retryAfterSeconds,
  }) = RateLimitedFailure;

  const factory Failure.aiUnavailable({
    @Default('AI service is temporarily unavailable.') String message,
  }) = AiUnavailableFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.unknown({
    @Default('An unexpected error occurred.') String message,
  }) = UnknownFailure;
}

extension FailureX on Failure {
  String get userMessage => switch (this) {
        NetworkFailure(:final message) => message,
        ServerFailure(:final message) => message,
        UnauthorizedFailure(:final message) => message,
        ValidationFailure(:final message) => message,
        RateLimitedFailure(:final message) => message,
        AiUnavailableFailure(:final message) => message,
        CacheFailure(:final message) => message,
        UnknownFailure(:final message) => message,
      };

  bool get isRetryable => switch (this) {
        NetworkFailure(:final retryable) => retryable,
        ServerFailure(:final retryable) => retryable,
        RateLimitedFailure() => true,
        _ => false,
      };
}
