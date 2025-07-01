import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

/// Collection of test helpers and utilities for offline-first package testing
class TestHelpers {
  TestHelpers._();

  /// Generates a random string of specified length
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Generates a unique ID for testing
  static String generateTestId([String? prefix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = generateRandomString(4);
    return '${prefix ?? 'test'}_${timestamp}_$randomSuffix';
  }

  /// Creates a test SyncItem with default or custom values
  static SyncItem createTestSyncItem({
    String? id,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    UploadStatus? status,
    SyncPriority? priority,
    String? endpoint,
    DateTime? lastAttemptAt,
    List<String>? dependencies,
  }) {
    final testId = id ?? generateTestId();
    return SyncItem(
      id: testId,
      entityType: entityType ?? 'TestEntity',
      entityId: entityId ?? testId,
      data: data ?? {'id': testId, 'name': 'Test Entity $testId'},
      createdAt: createdAt ?? DateTime.now(),
      status: status ?? const UploadStatus(state: UploadState.pending),
      priority: priority ?? SyncPriority.normal,
      endpoint: endpoint,
      lastAttemptAt: lastAttemptAt,
      dependencies: dependencies ?? [],
    );
  }

  /// Creates a test UploadStatus with specified state and optional parameters
  static UploadStatus createTestUploadStatus({
    required UploadState state,
    double? progress,
    String? error,
    DateTime? uploadedAt,
    int? retryCount,
    DateTime? nextRetryAt,
  }) {
    return UploadStatus(
      state: state,
      progress: progress ?? (state == UploadState.uploading ? 0.5 : 0.0),
      error: error,
      uploadedAt: uploadedAt ?? (state == UploadState.completed ? DateTime.now() : null),
      retryCount: retryCount ?? 0,
      nextRetryAt: nextRetryAt,
    );
  }

  /// Creates a list of test SyncItems with different priorities
  static List<SyncItem> createTestSyncItems({
    int count = 5,
    List<SyncPriority>? priorities,
    List<UploadState>? states,
  }) {
    final items = <SyncItem>[];
    final availablePriorities = priorities ?? SyncPriority.values;
    final availableStates = states ?? [UploadState.pending];

    for (int i = 0; i < count; i++) {
      final priority = availablePriorities[i % availablePriorities.length];
      final state = availableStates[i % availableStates.length];

      items.add(createTestSyncItem(
        id: 'test_item_$i',
        priority: priority,
        status: createTestUploadStatus(state: state),
      ));
    }

    return items;
  }

  /// Creates test dependencies between sync items
  static List<SyncItem> createTestSyncItemsWithDependencies() {
    final itemA = createTestSyncItem(id: 'item_a', dependencies: []);
    final itemB = createTestSyncItem(id: 'item_b', dependencies: ['item_a']);
    final itemC = createTestSyncItem(id: 'item_c', dependencies: ['item_a', 'item_b']);
    final itemD = createTestSyncItem(id: 'item_d', dependencies: ['item_c']);

    return [itemD, itemC, itemB, itemA]; // Intentionally out of order
  }

  /// Waits for a condition to be true with timeout
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (!condition() && stopwatch.elapsed < timeout) {
      await Future.delayed(interval);
    }

    if (!condition()) {
      throw TimeoutException(
        'Condition not met within timeout period',
        timeout,
      );
    }
  }

  /// Waits for a stream to emit a specific value
  static Future<T> waitForStreamValue<T>(
    Stream<T> stream,
    bool Function(T) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<T>();
    StreamSubscription<T>? subscription;
    Timer? timeoutTimer;

    timeoutTimer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Stream value not found within timeout', timeout),
        );
      }
    });

    subscription = stream.listen(
      (value) {
        if (predicate(value)) {
          timeoutTimer?.cancel();
          subscription?.cancel();
          if (!completer.isCompleted) {
            completer.complete(value);
          }
        }
      },
      onError: (error) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    return completer.future;
  }

  /// Collects stream values for a specified duration
  static Future<List<T>> collectStreamValues<T>(
    Stream<T> stream,
    Duration duration,
  ) async {
    final values = <T>[];
    StreamSubscription<T>? subscription;

    subscription = stream.listen(values.add);

    await Future.delayed(duration);
    await subscription.cancel();

    return values;
  }

  /// Simulates network delay with random variation
  static Future<void> simulateNetworkDelay({
    Duration baseDelay = const Duration(milliseconds: 100),
    Duration maxVariation = const Duration(milliseconds: 50),
  }) async {
    final random = Random();
    final variation = Duration(
      milliseconds: random.nextInt(maxVariation.inMilliseconds),
    );
    final totalDelay = baseDelay + variation;
    await Future.delayed(totalDelay);
  }

  /// Simulates random network errors
  static void simulateRandomNetworkError({double errorProbability = 0.1}) {
    final random = Random();
    if (random.nextDouble() < errorProbability) {
      final errorMessages = [
        'Network timeout',
        'Connection refused',
        'Host unreachable',
        'DNS resolution failed',
        'SSL handshake failed',
      ];
      final randomMessage = errorMessages[random.nextInt(errorMessages.length)];
      throw Exception(randomMessage);
    }
  }

  /// Creates a memory-efficient test database path
  static String getTestDatabasePath([String? testName]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = testName ?? 'test';
    return ':memory:'; // Use in-memory database for tests
  }

  /// Validates that two sync items are equal ignoring timestamps
  static bool syncItemsEqualIgnoringTimestamps(SyncItem a, SyncItem b) {
    return a.id == b.id &&
        a.entityType == b.entityType &&
        a.entityId == b.entityId &&
        _mapsEqual(a.data, b.data) &&
        a.priority == b.priority &&
        a.endpoint == b.endpoint &&
        _listsEqual(a.dependencies, b.dependencies);
  }

  /// Deep equality check for maps
  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }

    return true;
  }

  /// Deep equality check for lists
  static bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Measures execution time of a function
  static Future<({T result, Duration duration})> measureExecutionTime<T>(
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    final result = await function();
    stopwatch.stop();
    return (result: result, duration: stopwatch.elapsed);
  }

  /// Runs a function multiple times and returns statistics
  static Future<PerformanceStats> measurePerformance<T>(
    Future<T> Function() function, {
    int iterations = 10,
  }) async {
    final durations = <Duration>[];

    for (int i = 0; i < iterations; i++) {
      final result = await measureExecutionTime(function);
      durations.add(result.duration);
    }

    durations.sort((a, b) => a.compareTo(b));

    final totalMs = durations.fold(0, (sum, d) => sum + d.inMilliseconds);
    final averageMs = totalMs / iterations;
    final medianMs = durations[iterations ~/ 2].inMilliseconds;
    final minMs = durations.first.inMilliseconds;
    final maxMs = durations.last.inMilliseconds;

    return PerformanceStats(
      iterations: iterations,
      averageMs: averageMs,
      medianMs: medianMs,
      minMs: minMs,
      maxMs: maxMs,
      totalMs: totalMs,
    );
  }

  /// Generates test data with realistic patterns
  static Map<String, dynamic> generateRealisticTestData({
    int complexity = 1,
  }) {
    final random = Random();
    final data = <String, dynamic>{
      'id': generateTestId(),
      'name': _generateRealisticName(),
      'email': _generateRealisticEmail(),
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': random.nextBool(),
      'score': random.nextDouble() * 100,
      'tags': List.generate(
        random.nextInt(5) + 1,
        (_) => _generateRealisticTag(),
      ),
    };

    // Add complexity based on parameter
    if (complexity > 1) {
      data['metadata'] = {
        'version': random.nextInt(10) + 1,
        'source': 'mobile_app',
        'deviceInfo': {
          'platform': random.nextBool() ? 'iOS' : 'Android',
          'version': '${random.nextInt(15) + 5}.${random.nextInt(10)}',
        },
      };
    }

    if (complexity > 2) {
      data['attachments'] = List.generate(
        random.nextInt(3) + 1,
        (index) => {
          'id': generateTestId('attachment'),
          'filename': 'file_$index.jpg',
          'size': random.nextInt(1000000) + 10000,
          'mimeType': 'image/jpeg',
        },
      );
    }

    return data;
  }

  static String _generateRealisticName() {
    final firstNames = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'Diana', 'Eve', 'Frank'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis'];
    final random = Random();

    return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
  }

  static String _generateRealisticEmail() {
    final domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'company.com', 'test.org'];
    final random = Random();
    final username = generateRandomString(8).toLowerCase();
    final domain = domains[random.nextInt(domains.length)];

    return '$username@$domain';
  }

  static String _generateRealisticTag() {
    final tags = ['urgent', 'important', 'draft', 'review', 'approved', 'pending', 'archived', 'favorite'];
    final random = Random();

    return tags[random.nextInt(tags.length)];
  }

  /// Creates a mock file path for testing
  static String createMockFilePath(String filename) {
    return '/mock/path/to/$filename';
  }

  /// Validates sync queue ordering by priority
  static bool isSyncQueueOrderedByPriority(List<SyncItem> queue) {
    for (int i = 0; i < queue.length - 1; i++) {
      if (queue[i].priority.value < queue[i + 1].priority.value) {
        return false;
      }
    }
    return true;
  }

  /// Creates test entities with relationships
  static List<Map<String, dynamic>> createRelatedTestEntities() {
    final userId = generateTestId('user');
    final orderId = generateTestId('order');

    return [
      {
        'id': userId,
        'type': 'user',
        'name': _generateRealisticName(),
        'email': _generateRealisticEmail(),
      },
      {
        'id': orderId,
        'type': 'order',
        'userId': userId,
        'amount': Random().nextDouble() * 1000,
        'status': 'pending',
      },
      {
        'id': generateTestId('item'),
        'type': 'order_item',
        'orderId': orderId,
        'productId': generateTestId('product'),
        'quantity': Random().nextInt(5) + 1,
      },
    ];
  }
}

/// Performance statistics for testing
class PerformanceStats {
  const PerformanceStats({
    required this.iterations,
    required this.averageMs,
    required this.medianMs,
    required this.minMs,
    required this.maxMs,
    required this.totalMs,
  });

  final int iterations;
  final double averageMs;
  final int medianMs;
  final int minMs;
  final int maxMs;
  final int totalMs;

  @override
  String toString() {
    return 'PerformanceStats(iterations: $iterations, avg: ${averageMs.toStringAsFixed(2)}ms, '
        'median: ${medianMs}ms, min: ${minMs}ms, max: ${maxMs}ms, total: ${totalMs}ms)';
  }
}

/// Custom matchers for testing offline-first components
class OfflineFirstMatchers {
  /// Matcher for SyncItem equality ignoring timestamps
  static Matcher syncItemEquals(SyncItem expected) {
    return _SyncItemMatcher(expected);
  }

  /// Matcher for checking if upload status is in specific state
  static Matcher hasUploadState(UploadState expected) {
    return _UploadStateMatcher(expected);
  }

  /// Matcher for checking if sync queue is properly ordered
  static Matcher isSyncQueueOrdered() {
    return _SyncQueueOrderMatcher();
  }

  /// Matcher for checking if exception is retryable
  static Matcher isRetryableException() {
    return _RetryableExceptionMatcher();
  }
}

class _SyncItemMatcher extends Matcher {
  const _SyncItemMatcher(this.expected);

  final SyncItem expected;

  @override
  bool matches(dynamic item, Map<String, dynamic> matchState) {
    if (item is! SyncItem) return false;
    return TestHelpers.syncItemsEqualIgnoringTimestamps(item, expected);
  }

  @override
  Description describe(Description description) {
    return description.add('SyncItem equal to $expected (ignoring timestamps)');
  }
}

class _UploadStateMatcher extends Matcher {
  const _UploadStateMatcher(this.expected);

  final UploadState expected;

  @override
  bool matches(dynamic item, Map<String, dynamic> matchState) {
    if (item is UploadStatus) {
      return item.state == expected;
    }
    if (item is SyncItem) {
      return item.status.state == expected;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('has upload state $expected');
  }
}

class _SyncQueueOrderMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map<String, dynamic> matchState) {
    if (item is! List<SyncItem>) return false;
    return TestHelpers.isSyncQueueOrderedByPriority(item);
  }

  @override
  Description describe(Description description) {
    return description.add('sync queue ordered by priority (high to low)');
  }
}

class _RetryableExceptionMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map<String, dynamic> matchState) {
    if (item is SyncException) {
      return item.retryable;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('retryable exception');
  }
}

/// Test data builders for complex scenarios
class TestDataBuilder {
  TestDataBuilder._();

  /// Builds a complex sync scenario with multiple entities and dependencies
  static Future<TestScenario> buildComplexSyncScenario() async {
    final entities = <String, Map<String, dynamic>>{};
    final syncItems = <SyncItem>[];

    // Create user entity
    final userId = TestHelpers.generateTestId('user');
    entities[userId] = {
      'id': userId,
      'type': 'user',
      'name': TestHelpers._generateRealisticName(),
      'email': TestHelpers._generateRealisticEmail(),
    };

    // Create profile entity (depends on user)
    final profileId = TestHelpers.generateTestId('profile');
    entities[profileId] = {
      'id': profileId,
      'type': 'profile',
      'userId': userId,
      'bio': 'Test bio for user',
      'avatar': TestHelpers.createMockFilePath('avatar.jpg'),
    };

    // Create orders (depend on user)
    final orderIds = <String>[];
    for (int i = 0; i < 3; i++) {
      final orderId = TestHelpers.generateTestId('order');
      orderIds.add(orderId);
      entities[orderId] = {
        'id': orderId,
        'type': 'order',
        'userId': userId,
        'amount': Random().nextDouble() * 1000,
        'status': 'pending',
      };
    }

    // Create sync items with proper dependencies
    syncItems.add(TestHelpers.createTestSyncItem(
      id: 'sync_$userId',
      entityId: userId,
      data: entities[userId]!,
      priority: SyncPriority.high,
    ));

    syncItems.add(TestHelpers.createTestSyncItem(
      id: 'sync_$profileId',
      entityId: profileId,
      data: entities[profileId]!,
      dependencies: ['sync_$userId'],
      priority: SyncPriority.normal,
    ));

    for (final orderId in orderIds) {
      syncItems.add(TestHelpers.createTestSyncItem(
        id: 'sync_$orderId',
        entityId: orderId,
        data: entities[orderId]!,
        dependencies: ['sync_$userId'],
        priority: SyncPriority.low,
      ));
    }

    return TestScenario(
      entities: entities,
      syncItems: syncItems,
      description: 'Complex sync scenario with user, profile, and orders',
    );
  }

  /// Builds a failure scenario for testing error handling
  static TestScenario buildFailureScenario() {
    final syncItems = <SyncItem>[
      TestHelpers.createTestSyncItem(
        id: 'will_fail_network',
        status: TestHelpers.createTestUploadStatus(
          state: UploadState.failed,
          error: 'Network timeout',
          retryCount: 2,
        ),
      ),
      TestHelpers.createTestSyncItem(
        id: 'will_fail_auth',
        status: TestHelpers.createTestUploadStatus(
          state: UploadState.failed,
          error: 'Unauthorized',
          retryCount: 1,
        ),
      ),
      TestHelpers.createTestSyncItem(
        id: 'max_retries_exceeded',
        status: TestHelpers.createTestUploadStatus(
          state: UploadState.failed,
          error: 'Max retries exceeded',
          retryCount: 5,
        ),
      ),
    ];

    return TestScenario(
      entities: {},
      syncItems: syncItems,
      description: 'Failure scenario with various error types',
    );
  }
}

/// Represents a test scenario with entities and sync items
class TestScenario {
  const TestScenario({
    required this.entities,
    required this.syncItems,
    required this.description,
  });

  final Map<String, Map<String, dynamic>> entities;
  final List<SyncItem> syncItems;
  final String description;
}

/// Exception for test timeouts
class TimeoutException implements Exception {
  const TimeoutException(this.message, this.timeout);

  final String message;
  final Duration timeout;

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}
