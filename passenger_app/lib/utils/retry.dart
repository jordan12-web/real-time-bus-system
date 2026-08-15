import 'dart:async';
import 'dart:math';

/// Runs [action] with exponential backoff on retryable failures.
///
/// [shouldRetry] receives the attempt index (0-based) and the thrown error.
Future<T> retryWithBackoff<T>({
  required Future<T> Function() action,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 300),
  bool Function(int attempt, Object error)? shouldRetry,
}) async {
  Object? lastError;
  final random = Random();

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await action();
    } catch (error) {
      lastError = error;
      final isLastAttempt = attempt >= maxAttempts - 1;
      final retry = shouldRetry?.call(attempt, error) ?? !isLastAttempt;
      if (!retry || isLastAttempt) break;

      final jitterMs = random.nextInt(100);
      final delayMs = initialDelay.inMilliseconds * pow(2, attempt).toInt();
      await Future<void>.delayed(
        Duration(milliseconds: delayMs + jitterMs),
      );
    }
  }

  throw lastError ?? Exception('Retry failed without error');
}
