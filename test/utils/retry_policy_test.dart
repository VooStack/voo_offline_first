import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

void main() {
  group('ExponentialBackoffRetryPolicy', () {
    late ExponentialBackoffRetryPolicy policy;

    setUp(() {
      policy = ExponentialBackoffRetryPolicy(
        maxRetries: 3,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(minutes: 5),
        multiplier: 2.0,
        jitter: false, // Disable jitter for predictable tests
      );
    });

    test('should return zero delay for retry count 0', () {
      final delay = policy.calculateDelay(0);
      expect(delay, Duration.zero);
    });

    test('should calculate exponential delays correctly', () {
      final delay1 = policy.calculateDelay(1);
      final delay2 = policy.calculateDelay(2);
      final delay3 = policy.calculateDelay(3);

      expect(delay1, const Duration(seconds: 1));
      expect(delay2, const Duration(seconds: 2));
      expect(delay3, const Duration(seconds: 4));
    });

    test('should cap delay at maximum', () {
      final policyWithSmallMax = ExponentialBackoffRetryPolicy(
        maxRetries: 10,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 3),
        multiplier: 2.0,
        jitter: false,
      );

      final delay10 = policyWithSmallMax.calculateDelay(10);
      expect(delay10.inSeconds, lessThanOrEqualTo(3));
    });

    test('should apply jitter when enabled', () {
      final policyWithJitter = ExponentialBackoffRetryPolicy(
        maxRetries: 3,
        baseDelay: const Duration(seconds: 2),
        jitter: true,
      );

      final delay1a = policyWithJitter.calculateDelay(1);
      final delay1b = policyWithJitter.calculateDelay(1);

      // With jitter, delays should vary (though this test might rarely fail due to randomness)
      // We test that delay is within expected range
      expect(delay1a.inMilliseconds, greaterThanOrEqualTo(1000)); // At least 50% of base
      expect(delay1a.inMilliseconds, lessThanOrEqualTo(2000)); // At most 100% of base
    });

    test('should allow retries up to max count', () {
      expect(policy.shouldRetry(0, null), true);
      expect(policy.shouldRetry(1, null), true);
      expect(policy.shouldRetry(2, null), true);
      expect(policy.shouldRetry(3, null), false);
      expect(policy.shouldRetry(4, null), false);
    });

    test('should have correct max retries', () {
      expect(policy.maxRetries, 3);
    });
  });

  group('LinearBackoffRetryPolicy', () {
    late LinearBackoffRetryPolicy policy;

    setUp(() {
      policy = LinearBackoffRetryPolicy(
        maxRetries: 3,
        baseDelay: const Duration(seconds: 5),
        increment: const Duration(seconds: 5),
        maxDelay: const Duration(minutes: 1),
      );
    });

    test('should return zero delay for retry count 0', () {
      final delay = policy.calculateDelay(0);
      expect(delay, Duration.zero);
    });

    test('should calculate linear delays correctly', () {
      final delay1 = policy.calculateDelay(1);
      final delay2 = policy.calculateDelay(2);
      final delay3 = policy.calculateDelay(3);

      expect(delay1, const Duration(seconds: 5));
      expect(delay2, const Duration(seconds: 10));
      expect(delay3, const Duration(seconds: 15));
    });

    test('should cap delay at maximum', () {
      final policyWithSmallMax = LinearBackoffRetryPolicy(
        maxRetries: 10,
        baseDelay: const Duration(seconds: 5),
        increment: const Duration(seconds: 5),
        maxDelay: const Duration(seconds: 12),
      );

      final delay5 = policyWithSmallMax.calculateDelay(5);
      expect(delay5.inSeconds, lessThanOrEqualTo(12));
    });

    test('should allow retries up to max count', () {
      expect(policy.shouldRetry(0, null), true);
      expect(policy.shouldRetry(1, null), true);
      expect(policy.shouldRetry(2, null), true);
      expect(policy.shouldRetry(3, null), false);
    });
  });

  group('FixedIntervalRetryPolicy', () {
    late FixedIntervalRetryPolicy policy;

    setUp(() {
      policy = FixedIntervalRetryPolicy(
        maxRetries: 3,
        interval: const Duration(seconds: 30),
      );
    });

    test('should return zero delay for retry count 0', () {
      final delay = policy.calculateDelay(0);
      expect(delay, Duration.zero);
    });

    test('should return fixed interval for all retry counts', () {
      final delay1 = policy.calculateDelay(1);
      final delay2 = policy.calculateDelay(2);
      final delay3 = policy.calculateDelay(3);

      expect(delay1, const Duration(seconds: 30));
      expect(delay2, const Duration(seconds: 30));
      expect(delay3, const Duration(seconds: 30));
    });

    test('should allow retries up to max count', () {
      expect(policy.shouldRetry(0, null), true);
      expect(policy.shouldRetry(1, null), true);
      expect(policy.shouldRetry(2, null), true);
      expect(policy.shouldRetry(3, null), false);
    });
  });

  group('SmartRetryPolicy', () {
    late SmartRetryPolicy policy;

    setUp(() {
      policy = SmartRetryPolicy(
        maxRetries: 5,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(minutes: 10),
      );
    });

    test('should calculate exponential delays', () {
      final delay1 = policy.calculateDelay(1);
      final delay2 = policy.calculateDelay(2);
      final delay3 = policy.calculateDelay(3);

      expect(delay1, const Duration(seconds: 1));
      expect(delay2, const Duration(seconds: 2));
      expect(delay3, const Duration(seconds: 4));
    });

    test('should not retry client errors (4xx)', () {
      expect(policy.shouldRetry(1, Exception('HTTP 400 Bad Request')), false);
      expect(policy.shouldRetry(1, Exception('HTTP 401 Unauthorized')), false);
      expect(policy.shouldRetry(1, Exception('HTTP 403 Forbidden')), false);
      expect(policy.shouldRetry(1, Exception('HTTP 404 Not Found')), false);
    });

    test('should not retry permanent failures', () {
      expect(policy.shouldRetry(1, Exception('permanent failure')), false);
      expect(policy.shouldRetry(1, Exception('invalid data format')), false);
      expect(policy.shouldRetry(1, Exception('malformed request')), false);
    });

    test('should retry server errors and network issues', () {
      expect(policy.shouldRetry(1, Exception('HTTP 500 Internal Server Error')), true);
      expect(policy.shouldRetry(1, Exception('timeout')), true);
      expect(policy.shouldRetry(1, Exception('connection refused')), true);
      expect(policy.shouldRetry(1, Exception('network unreachable')), true);
    });

    test('should retry when no exception provided', () {
      expect(policy.shouldRetry(1, null), true);
      expect(policy.shouldRetry(2, null), true);
    });

    test('should stop retrying after max attempts', () {
      expect(policy.shouldRetry(5, null), false);
      expect(policy.shouldRetry(6, null), false);
    });

    test('should respect max retries even for retryable errors', () {
      expect(policy.shouldRetry(5, Exception('timeout')), false);
    });
  });

  group('RetryPolicy interface', () {
    test('all policies should implement RetryPolicy interface', () {
      final policies = <RetryPolicy>[
        ExponentialBackoffRetryPolicy(),
        LinearBackoffRetryPolicy(),
        FixedIntervalRetryPolicy(),
        SmartRetryPolicy(),
      ];

      for (final policy in policies) {
        expect(policy, isA<RetryPolicy>());
        expect(policy.maxRetries, isA<int>());
        expect(policy.maxRetries, greaterThan(0));

        // Test basic interface methods
        expect(policy.calculateDelay(0), Duration.zero);
        expect(policy.shouldRetry(0, null), true);
        expect(policy.shouldRetry(policy.maxRetries, null), false);
      }
    });
  });

  group('Edge cases', () {
    test('should handle negative retry counts gracefully', () {
      final policy = ExponentialBackoffRetryPolicy();
      expect(policy.calculateDelay(-1), Duration.zero);
      expect(policy.shouldRetry(-1, null), true);
    });

    test('should handle very large retry counts', () {
      final policy = ExponentialBackoffRetryPolicy(
        maxDelay: const Duration(minutes: 5),
      );

      final delay = policy.calculateDelay(100);
      expect(delay.inMinutes, lessThanOrEqualTo(5));
    });

    test('should handle exceptions with complex error messages', () {
      final policy = SmartRetryPolicy();

      final complexError = Exception(
        'Multiple errors occurred: HTTP 400 Bad Request, timeout, permanent failure',
      );

      // Should not retry because it contains client error keywords
      expect(policy.shouldRetry(1, complexError), false);
    });

    test('should handle null and empty error messages', () {
      final policy = SmartRetryPolicy();

      expect(policy.shouldRetry(1, Exception('')), true);
      expect(policy.shouldRetry(1, Exception('null')), true);
    });
  });
}
