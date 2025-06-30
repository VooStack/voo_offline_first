import 'dart:math';

/// Abstract class for defining retry policies
abstract class RetryPolicy {
  /// Calculate the delay before the next retry attempt
  Duration calculateDelay(int retryCount);

  /// Determine if we should retry based on the current attempt count
  bool shouldRetry(int retryCount, Exception? exception);

  /// Maximum number of retry attempts
  int get maxRetries;
}

/// Exponential backoff retry policy with jitter
class ExponentialBackoffRetryPolicy implements RetryPolicy {
  ExponentialBackoffRetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 5),
    this.multiplier = 2.0,
    this.jitter = true,
  });

  @override
  final int maxRetries;

  final Duration baseDelay;
  final Duration maxDelay;
  final double multiplier;
  final bool jitter;

  static final Random _random = Random();

  @override
  Duration calculateDelay(int retryCount) {
    if (retryCount <= 0) return Duration.zero;

    // Calculate exponential delay
    var delay = baseDelay.inMilliseconds * pow(multiplier, retryCount - 1);

    // Apply jitter to prevent thundering herd
    if (jitter) {
      delay = delay * (0.5 + _random.nextDouble() * 0.5);
    }

    // Cap at maximum delay
    delay = min(delay, maxDelay.inMilliseconds.toDouble());

    return Duration(milliseconds: delay.round());
  }

  @override
  bool shouldRetry(int retryCount, Exception? exception) {
    return retryCount < maxRetries;
  }
}

/// Linear backoff retry policy
class LinearBackoffRetryPolicy implements RetryPolicy {
  LinearBackoffRetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 5),
    this.increment = const Duration(seconds: 5),
    this.maxDelay = const Duration(minutes: 5),
  });

  @override
  final int maxRetries;

  final Duration baseDelay;
  final Duration increment;
  final Duration maxDelay;

  @override
  Duration calculateDelay(int retryCount) {
    if (retryCount <= 0) return Duration.zero;

    final delayMilliseconds = baseDelay.inMilliseconds + (increment.inMilliseconds * (retryCount - 1));

    return Duration(
      milliseconds: min(delayMilliseconds, maxDelay.inMilliseconds),
    );
  }

  @override
  bool shouldRetry(int retryCount, Exception? exception) {
    return retryCount < maxRetries;
  }
}

/// Fixed interval retry policy
class FixedIntervalRetryPolicy implements RetryPolicy {
  FixedIntervalRetryPolicy({
    this.maxRetries = 3,
    this.interval = const Duration(seconds: 30),
  });

  @override
  final int maxRetries;

  final Duration interval;

  @override
  Duration calculateDelay(int retryCount) {
    return retryCount > 0 ? interval : Duration.zero;
  }

  @override
  bool shouldRetry(int retryCount, Exception? exception) {
    return retryCount < maxRetries;
  }
}

/// Smart retry policy that adapts based on the type of error
class SmartRetryPolicy implements RetryPolicy {
  SmartRetryPolicy({
    this.maxRetries = 5,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 10),
  });

  @override
  final int maxRetries;

  final Duration baseDelay;
  final Duration maxDelay;

  @override
  Duration calculateDelay(int retryCount) {
    if (retryCount <= 0) return Duration.zero;

    // Use exponential backoff as base
    var delay = baseDelay.inMilliseconds * pow(2, retryCount - 1);
    delay = min(delay, maxDelay.inMilliseconds.toDouble());

    return Duration(milliseconds: delay.round());
  }

  @override
  bool shouldRetry(int retryCount, Exception? exception) {
    if (retryCount >= maxRetries) return false;

    // Don't retry certain types of errors
    if (exception != null) {
      final errorMessage = exception.toString().toLowerCase();

      // Don't retry client errors (4xx)
      if (errorMessage.contains('400') || errorMessage.contains('401') || errorMessage.contains('403') || errorMessage.contains('404')) {
        return false;
      }

      // Don't retry permanent failures
      if (errorMessage.contains('permanent') || errorMessage.contains('invalid') || errorMessage.contains('malformed')) {
        return false;
      }
    }

    return true;
  }
}
