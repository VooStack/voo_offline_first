# 🧪 Testing Guide for Offline First Package

This directory contains comprehensive tests for the Offline First Flutter package. The test suite covers unit tests, widget tests, integration tests, and performance benchmarks.

## 📋 Test Structure

```
test/
├── README.md                          # This file
├── test_all.dart                      # Main test runner
├── pubspec_additions.yaml             # Additional test dependencies
├── Makefile.test                      # Test automation commands
│
├── models/                            # Model tests
│   ├── sync_item_test.dart           # SyncItem model tests
│   └── upload_status_test.dart       # UploadStatus model tests
│
├── utils/                             # Utility tests
│   ├── sync_utils_test.dart          # SyncUtils helper tests
│   └── retry_policy_test.dart        # Retry policy tests
│
├── services/                          # Service layer tests
│   ├── connectivity_service_test.dart # Connectivity service tests
│   └── sync_manager_test.dart        # Sync manager tests
│
├── repositories/                      # Repository tests
│   └── base_offline_repository_test.dart # Base repository tests
│
├── bloc/                              # BLoC tests
│   └── sync_bloc_test.dart           # Sync BLoC tests
│
├── widgets/                           # Widget tests
│   └── sync_status_widgets_test.dart # UI component tests
│
├── exceptions/                        # Exception tests
│   └── offline_exceptions_test.dart  # Custom exception tests
│
├── integration/                       # Integration tests
│   └── offline_sync_integration_test.dart # End-to-end tests
│
├── performance/                       # Performance tests
│   └── performance_test.dart         # Benchmarks and stress tests
│
├── mocks/                            # Mock implementations
│   └── mock_implementations.dart     # Test doubles and mocks
│
└── helpers/                          # Test utilities
    └── test_helpers.dart             # Common test helpers
```

## 🚀 Quick Start

### Prerequisites

Add these dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.2
  mocktail: ^0.3.0
  fake_async: ^1.3.1
```

### Running Tests

**Run all tests:**
```bash
flutter test
```

**Run specific test categories:**
```bash
# Unit tests only
flutter test test/models/ test/utils/ test/services/

# Widget tests only
flutter test test/widgets/

# Integration tests only
flutter test test/integration/

# Performance tests only
flutter test test/performance/
```

**Using the Makefile:**
```bash
# Run all tests
make test

# Run with coverage
make test-coverage

# Run in watch mode
make test-watch

# See all available commands
make test-help
```

## 📊 Test Categories

### 1. Model Tests (`test/models/`)

Tests for data models and their serialization:

- **SyncItem Tests**: Serialization, deserialization, copy operations, validation
- **UploadStatus Tests**: State transitions, progress tracking, error handling

**Coverage:**
- ✅ JSON serialization/deserialization
- ✅ Equality and hash code
- ✅ Copy operations
- ✅ Field validation
- ✅ State transitions

### 2. Utility Tests (`test/utils/`)

Tests for helper classes and utilities:

- **SyncUtils Tests**: File operations, priority calculations, dependency sorting
- **RetryPolicy Tests**: Exponential backoff, linear backoff, smart retry logic

**Coverage:**
- ✅ File validation and checksum calculation
- ✅ Priority-based sorting algorithms
- ✅ Dependency resolution (topological sort)
- ✅ Retry timing calculations
- ✅ Error classification (retryable vs non-retryable)

### 3. Service Tests (`test/services/`)

Tests for core services:

- **ConnectivityService Tests**: Network monitoring, connection quality, state changes
- **SyncManager Tests**: Queue management, sync operations, retry logic

**Coverage:**
- ✅ Connectivity detection and monitoring
- ✅ Sync queue management
- ✅ Automatic and manual sync operations
- ✅ Error handling and recovery
- ✅ Progress tracking and statistics

### 4. Repository Tests (`test/repositories/`)

Tests for data access layer:

- **BaseOfflineRepository Tests**: CRUD operations, sync queue integration, stream operations

**Coverage:**
- ✅ Entity CRUD operations
- ✅ Sync queue integration
- ✅ Upload status tracking
- ✅ Stream-based reactive updates
- ✅ Batch operations
- ✅ Error handling

### 5. BLoC Tests (`test/bloc/`)

Tests for state management:

- **SyncBloc Tests**: Event handling, state transitions, side effects

**Coverage:**
- ✅ Event processing
- ✅ State transitions
- ✅ Side effect management
- ✅ Error state handling
- ✅ Stream subscriptions

### 6. Widget Tests (`test/widgets/`)

Tests for UI components:

- **SyncStatusWidgets Tests**: UI component behavior, user interactions, state display

**Coverage:**
- ✅ Widget rendering
- ✅ User interaction handling
- ✅ State-based UI updates
- ✅ Accessibility features
- ✅ Theme integration

### 7. Exception Tests (`test/exceptions/`)

Tests for error handling:

- **OfflineExceptions Tests**: Custom exceptions, error messages, inheritance

**Coverage:**
- ✅ Exception creation and formatting
- ✅ Error message generation
- ✅ Exception inheritance hierarchy
- ✅ Stack trace preservation

### 8. Integration Tests (`test/integration/`)

End-to-end workflow tests:

- **Complete offline sync workflows**
- **Multi-component interactions**
- **Real-world scenarios**

**Coverage:**
- ✅ Offline data creation and sync
- ✅ Connectivity changes during sync
- ✅ Error recovery workflows
- ✅ Performance under load
- ✅ Concurrent operations

### 9. Performance Tests (`test/performance/`)

Benchmarks and stress tests:

- **Large dataset handling**
- **Memory usage optimization**
- **Concurrent operation performance**

**Coverage:**
- ✅ Large sync queue performance
- ✅ Memory leak detection
- ✅ Concurrent operation handling
- ✅ Resource usage optimization
- ✅ Stress testing scenarios

## 🔧 Test Utilities

### TestHelpers Class

The `TestHelpers` class provides utilities for creating test data and managing test execution:

```dart
// Create test sync items
final item = TestHelpers.createTestSyncItem(
  id: 'test-item',
  priority: SyncPriority.high,
);

// Generate realistic test data
final data = TestHelpers.generateRealisticTestData(complexity: 2);

// Wait for conditions
await TestHelpers.waitForCondition(
  () => syncManager.syncedItems.isNotEmpty,
  timeout: Duration(seconds: 5),
);

// Measure performance
final stats = await TestHelpers.measurePerformance(
  () => repository.saveAll(entities),
  iterations: 10,
);
```

### Mock Implementations

Pre-built mock implementations for testing:

- `MockSyncManagerImpl`: Full-featured sync manager mock
- `MockConnectivityServiceImpl`: Connectivity service mock
- `MockOfflineRepository`: Repository mock with in-memory storage

### Custom Matchers

Custom test matchers for domain-specific assertions:

```dart
// Test sync item equality (ignoring timestamps)
expect(actualItem, OfflineFirstMatchers.syncItemEquals(expectedItem));

// Test upload state
expect(status, OfflineFirstMatchers.hasUploadState(UploadState.completed));

// Test sync queue ordering
expect(queue, OfflineFirstMatchers.isSyncQueueOrdered());
```

## 📈 Coverage Goals

We aim for comprehensive test coverage across all components:

- **Unit Tests**: >90% line coverage
- **Integration Tests**: All major workflows
- **Widget Tests**: All UI components
- **Performance Tests**: Key performance scenarios

### Generating Coverage Reports

```bash
# Generate coverage data
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

## 🏃‍♂️ Running Tests in CI/CD

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.6'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

### Test Configuration

Create a `test/dart_test.yaml` file for test configuration:

```yaml
# Test configuration
timeout: 30s
concurrency: 4

tags:
  fast: # Quick unit tests
    timeout: 5s
  slow: # Integration and performance tests
    timeout: 120s
  stress: # Stress tests
    timeout: 300s

platforms:
  - vm
  - chrome
```

## 🎯 Best Practices

### Writing Good Tests

1. **Follow AAA Pattern**: Arrange, Act, Assert
2. **Use Descriptive Names**: Test names should explain what is being tested
3. **Test One Thing**: Each test should focus on a single behavior
4. **Use Setup/Teardown**: Properly initialize and clean up test resources
5. **Mock External Dependencies**: Use mocks for external services

### Test Organization

1. **Group Related Tests**: Use `group()` to organize related test cases
2. **Shared Setup**: Use `setUp()` and `tearDown()` for common initialization
3. **Test Data Builders**: Create helper functions for test data creation
4. **Isolate Tests**: Ensure tests don't depend on each other

### Performance Testing

1. **Set Realistic Benchmarks**: Base performance expectations on real-world usage
2. **Test Under Load**: Verify behavior with large datasets
3. **Monitor Memory**: Check for memory leaks in long-running operations
4. **Profile Bottlenecks**: Identify and test performance-critical paths

### Example Test Structure

```dart
group('SyncManager', () {
  late MockSyncManagerImpl syncManager;

  setUp(() async {
    syncManager = MockSyncManagerImpl();
    await syncManager.initialize();
  });

  tearDown(() async {
    await syncManager.dispose();
    syncManager.reset();
  });

  group('Queue Management', () {
    test('should add item to sync queue', () async {
      // Arrange
      final item = TestHelpers.createTestSyncItem();
      
      // Act
      await syncManager.queueForSync(item);
      
      // Assert
      final queue = await syncManager.getSyncQueue();
      expect(queue, hasLength(1));
      expect(queue.first.id, item.id);
    });

    test('should handle empty queue gracefully', () async {
      // Act
      await syncManager.syncNow();
      
      // Assert
      expect(syncManager.syncedItems, isEmpty);
    });
  });
});
```

## 🐛 Debugging Test Failures

### Common Issues and Solutions

1. **Async Test Failures**
   ```dart
   // ❌ Wrong: Missing await
   test('should complete async operation', () {
     service.performAsyncOperation();
     expect(service.isComplete, true);
   });

   // ✅ Correct: Proper async handling
   test('should complete async operation', () async {
     await service.performAsyncOperation();
     expect(service.isComplete, true);
   });
   ```

2. **Stream Test Failures**
   ```dart
   // ❌ Wrong: Not waiting for stream
   test('should emit values', () {
     final stream = service.watchData();
     expect(stream, emits(expectedValue));
   });

   // ✅ Correct: Using expectLater
   test('should emit values', () async {
     final stream = service.watchData();
     await expectLater(stream, emits(expectedValue));
   });
   ```

3. **Mock Setup Issues**
   ```dart
   // ❌ Wrong: Incomplete mock setup
   when(() => mockService.getData()).thenReturn([]);

   // ✅ Correct: Complete mock setup
   when(() => mockService.getData()).thenAnswer((_) async => []);
   when(() => mockService.isInitialized).thenReturn(true);
   ```

### Debug Test Output

Run tests with verbose output to see detailed information:

```bash
# Verbose test output
flutter test --reporter expanded

# Debug specific test
flutter test test/path/to/test.dart --reporter expanded
```

## 📞 Getting Help

If you encounter issues with tests:

1. **Check Test Documentation**: Review this README and inline documentation
2. **Run Individual Tests**: Isolate failing tests to identify root cause
3. **Check Mock Setup**: Ensure all mocks are properly configured
4. **Verify Test Environment**: Ensure all dependencies are installed
5. **Review Error Messages**: Flutter test provides detailed error information

## 🤝 Contributing Tests

When adding new features:

1. **Write Tests First**: Follow TDD when possible
2. **Update Documentation**: Keep this README current
3. **Add Performance Tests**: Include benchmarks for new features
4. **Test Edge Cases**: Cover error scenarios and boundary conditions
5. **Update CI Configuration**: Ensure new tests run in CI/CD

---

Happy Testing! 🎉