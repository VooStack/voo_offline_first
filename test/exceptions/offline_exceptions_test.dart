import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

void main() {
  group('OfflineExceptions', () {
    group('OfflineException Base Class', () {
      test('should create exception with message only', () {
        const exception = _TestOfflineException('Test error message');

        expect(exception.message, 'Test error message');
        expect(exception.code, isNull);
        expect(exception.toString(), 'OfflineException: Test error message');
      });

      test('should create exception with message and code', () {
        const exception = _TestOfflineException('Test error message', code: 'TEST_001');

        expect(exception.message, 'Test error message');
        expect(exception.code, 'TEST_001');
        expect(exception.toString(), 'OfflineException: Test error message (Code: TEST_001)');
      });
    });

    group('SyncException', () {
      test('should create sync exception with basic information', () {
        const exception = SyncException('Sync failed');

        expect(exception.message, 'Sync failed');
        expect(exception.entityType, isNull);
        expect(exception.entityId, isNull);
        expect(exception.retryable, true);
        expect(exception.toString(), 'SyncException: Sync failed');
      });

      test('should create sync exception with full information', () {
        const exception = SyncException(
          'Sync failed due to network error',
          code: 'SYNC_001',
          entityType: 'User',
          entityId: 'user-123',
          retryable: false,
        );

        expect(exception.message, 'Sync failed due to network error');
        expect(exception.code, 'SYNC_001');
        expect(exception.entityType, 'User');
        expect(exception.entityId, 'user-123');
        expect(exception.retryable, false);
        expect(
          exception.toString(),
          'SyncException: Sync failed due to network error (Entity: User:user-123) (Code: SYNC_001)',
        );
      });

      test('should create sync exception with partial entity information', () {
        const exceptionWithType = SyncException(
          'Entity type error',
          entityType: 'Product',
        );

        expect(exceptionWithType.toString(), 'SyncException: Entity type error');

        const exceptionWithId = SyncException(
          'Entity ID error',
          entityId: 'product-456',
        );

        expect(exceptionWithId.toString(), 'SyncException: Entity ID error');
      });
    });

    group('DatabaseException', () {
      test('should create database exception with basic information', () {
        const exception = DatabaseException('Database connection failed');

        expect(exception.message, 'Database connection failed');
        expect(exception.tableName, isNull);
        expect(exception.operation, isNull);
        expect(exception.toString(), 'DatabaseException: Database connection failed');
      });

      test('should create database exception with full information', () {
        const exception = DatabaseException(
          'Failed to insert record',
          code: 'DB_001',
          tableName: 'users',
          operation: 'insert',
        );

        expect(exception.message, 'Failed to insert record');
        expect(exception.code, 'DB_001');
        expect(exception.tableName, 'users');
        expect(exception.operation, 'insert');
        expect(
          exception.toString(),
          'DatabaseException: Failed to insert record (Table: users, Operation: insert, Code: DB_001)',
        );
      });

      test('should handle partial database information', () {
        const exceptionWithTable = DatabaseException(
          'Table error',
          tableName: 'products',
        );

        expect(
          exceptionWithTable.toString(),
          'DatabaseException: Table error (Table: products)',
        );

        const exceptionWithOperation = DatabaseException(
          'Operation error',
          operation: 'update',
        );

        expect(
          exceptionWithOperation.toString(),
          'DatabaseException: Operation error (Operation: update)',
        );
      });
    });

    group('ConnectivityException', () {
      test('should create connectivity exception with basic information', () {
        const exception = ConnectivityException('No internet connection');

        expect(exception.message, 'No internet connection');
        expect(exception.requiredConnectionType, isNull);
        expect(exception.toString(), 'ConnectivityException: No internet connection');
      });

      test('should create connectivity exception with connection type', () {
        const exception = ConnectivityException(
          'WiFi connection required',
          code: 'CONN_001',
          requiredConnectionType: 'WiFi',
        );

        expect(exception.message, 'WiFi connection required');
        expect(exception.code, 'CONN_001');
        expect(exception.requiredConnectionType, 'WiFi');
        expect(
          exception.toString(),
          'ConnectivityException: WiFi connection required (Required: WiFi) (Code: CONN_001)',
        );
      });
    });

    group('FileException', () {
      test('should create file exception with basic information', () {
        const exception = FileException('File not found');

        expect(exception.message, 'File not found');
        expect(exception.filePath, isNull);
        expect(exception.operation, isNull);
        expect(exception.toString(), 'FileException: File not found');
      });

      test('should create file exception with full information', () {
        const exception = FileException(
          'Failed to read file',
          code: 'FILE_001',
          filePath: '/path/to/file.txt',
          operation: 'read',
        );

        expect(exception.message, 'Failed to read file');
        expect(exception.code, 'FILE_001');
        expect(exception.filePath, '/path/to/file.txt');
        expect(exception.operation, 'read');
        expect(
          exception.toString(),
          'FileException: Failed to read file (File: /path/to/file.txt, Operation: read, Code: FILE_001)',
        );
      });
    });

    group('SerializationException', () {
      test('should create serialization exception with basic information', () {
        const exception = SerializationException('JSON parse error');

        expect(exception.message, 'JSON parse error');
        expect(exception.entityType, isNull);
        expect(exception.operation, isNull);
        expect(exception.toString(), 'SerializationException: JSON parse error');
      });

      test('should create serialization exception with full information', () {
        const exception = SerializationException(
          'Failed to serialize entity',
          code: 'SER_001',
          entityType: 'User',
          operation: 'serialize',
        );

        expect(exception.message, 'Failed to serialize entity');
        expect(exception.code, 'SER_001');
        expect(exception.entityType, 'User');
        expect(exception.operation, 'serialize');
        expect(
          exception.toString(),
          'SerializationException: Failed to serialize entity (Entity: User, Operation: serialize, Code: SER_001)',
        );
      });

      test('should handle different operations', () {
        const serializeException = SerializationException(
          'Serialize error',
          operation: 'serialize',
        );

        expect(
          serializeException.toString(),
          'SerializationException: Serialize error (Operation: serialize)',
        );

        const deserializeException = SerializationException(
          'Deserialize error',
          operation: 'deserialize',
        );

        expect(
          deserializeException.toString(),
          'SerializationException: Deserialize error (Operation: deserialize)',
        );
      });
    });

    group('ConfigurationException', () {
      test('should create configuration exception with basic information', () {
        const exception = ConfigurationException('Invalid configuration');

        expect(exception.message, 'Invalid configuration');
        expect(exception.configKey, isNull);
        expect(exception.toString(), 'ConfigurationException: Invalid configuration');
      });

      test('should create configuration exception with config key', () {
        const exception = ConfigurationException(
          'Missing required configuration',
          code: 'CONFIG_001',
          configKey: 'api.baseUrl',
        );

        expect(exception.message, 'Missing required configuration');
        expect(exception.code, 'CONFIG_001');
        expect(exception.configKey, 'api.baseUrl');
        expect(
          exception.toString(),
          'ConfigurationException: Missing required configuration (Key: api.baseUrl) (Code: CONFIG_001)',
        );
      });
    });

    group('ValidationException', () {
      test('should create validation exception with basic information', () {
        const exception = ValidationException('Invalid input');

        expect(exception.message, 'Invalid input');
        expect(exception.fieldName, isNull);
        expect(exception.value, isNull);
        expect(exception.toString(), 'ValidationException: Invalid input');
      });

      test('should create validation exception with field information', () {
        const exception = ValidationException(
          'Email format is invalid',
          code: 'VAL_001',
          fieldName: 'email',
          value: 'invalid-email',
        );

        expect(exception.message, 'Email format is invalid');
        expect(exception.code, 'VAL_001');
        expect(exception.fieldName, 'email');
        expect(exception.value, 'invalid-email');
        expect(
          exception.toString(),
          'ValidationException: Email format is invalid (Field: email, Value: invalid-email, Code: VAL_001)',
        );
      });

      test('should handle different value types', () {
        const stringException = ValidationException(
          'String validation error',
          fieldName: 'name',
          value: 'test-string',
        );

        expect(
          stringException.toString(),
          'ValidationException: String validation error (Field: name, Value: test-string)',
        );

        const numberException = ValidationException(
          'Number validation error',
          fieldName: 'age',
          value: 42,
        );

        expect(
          numberException.toString(),
          'ValidationException: Number validation error (Field: age, Value: 42)',
        );

        const nullException = ValidationException(
          'Null validation error',
          fieldName: 'optional',
          value: null,
        );

        expect(
          nullException.toString(),
          'ValidationException: Null validation error (Field: optional, Value: null)',
        );
      });
    });

    group('RetryLimitExceededException', () {
      test('should create retry limit exception with basic information', () {
        const exception = RetryLimitExceededException('Maximum retries exceeded');

        expect(exception.message, 'Maximum retries exceeded');
        expect(exception.maxRetries, isNull);
        expect(exception.lastError, isNull);
        expect(exception.toString(), 'RetryLimitExceededException: Maximum retries exceeded');
      });

      test('should create retry limit exception with retry information', () {
        const exception = RetryLimitExceededException(
          'Failed after multiple attempts',
          code: 'RETRY_001',
          maxRetries: 5,
          lastError: 'Network timeout',
        );

        expect(exception.message, 'Failed after multiple attempts');
        expect(exception.code, 'RETRY_001');
        expect(exception.maxRetries, 5);
        expect(exception.lastError, 'Network timeout');
        expect(
          exception.toString(),
          'RetryLimitExceededException: Failed after multiple attempts (Max retries: 5, Last error: Network timeout, Code: RETRY_001)',
        );
      });
    });

    group('NotInitializedException', () {
      test('should create not initialized exception with basic information', () {
        const exception = NotInitializedException('Service not initialized');

        expect(exception.message, 'Service not initialized');
        expect(exception.serviceName, isNull);
        expect(exception.toString(), 'NotInitializedException: Service not initialized');
      });

      test('should create not initialized exception with service name', () {
        const exception = NotInitializedException(
          'Service must be initialized before use',
          code: 'INIT_001',
          serviceName: 'SyncManager',
        );

        expect(exception.message, 'Service must be initialized before use');
        expect(exception.code, 'INIT_001');
        expect(exception.serviceName, 'SyncManager');
        expect(
          exception.toString(),
          'NotInitializedException: Service must be initialized before use (Service: SyncManager) (Code: INIT_001)',
        );
      });
    });

    group('QuotaExceededException', () {
      test('should create quota exceeded exception with basic information', () {
        const exception = QuotaExceededException('Storage quota exceeded');

        expect(exception.message, 'Storage quota exceeded');
        expect(exception.quotaType, isNull);
        expect(exception.currentValue, isNull);
        expect(exception.maxValue, isNull);
        expect(exception.toString(), 'QuotaExceededException: Storage quota exceeded');
      });

      test('should create quota exceeded exception with quota information', () {
        const exception = QuotaExceededException(
          'Database size limit reached',
          code: 'QUOTA_001',
          quotaType: 'database_size',
          currentValue: 1024,
          maxValue: 512,
        );

        expect(exception.message, 'Database size limit reached');
        expect(exception.code, 'QUOTA_001');
        expect(exception.quotaType, 'database_size');
        expect(exception.currentValue, 1024);
        expect(exception.maxValue, 512);
        expect(
          exception.toString(),
          'QuotaExceededException: Database size limit reached (Quota: database_size, Usage: 1024/512, Code: QUOTA_001)',
        );
      });

      test('should handle different value types for quota', () {
        const stringQuotaException = QuotaExceededException(
          'String quota exceeded',
          quotaType: 'api_calls',
          currentValue: '150',
          maxValue: '100',
        );

        expect(
          stringQuotaException.toString(),
          'QuotaExceededException: String quota exceeded (Quota: api_calls, Usage: 150/100)',
        );

        const doubleQuotaException = QuotaExceededException(
          'Storage quota exceeded',
          quotaType: 'storage_gb',
          currentValue: 2.5,
          maxValue: 2.0,
        );

        expect(
          doubleQuotaException.toString(),
          'QuotaExceededException: Storage quota exceeded (Quota: storage_gb, Usage: 2.5/2.0)',
        );
      });
    });

    group('Exception Inheritance', () {
      test('all custom exceptions should extend OfflineException', () {
        const syncException = SyncException('test');
        const databaseException = DatabaseException('test');
        const connectivityException = ConnectivityException('test');
        const fileException = FileException('test');
        const serializationException = SerializationException('test');
        const configurationException = ConfigurationException('test');
        const validationException = ValidationException('test');
        const retryLimitException = RetryLimitExceededException('test');
        const notInitializedException = NotInitializedException('test');
        const quotaExceededException = QuotaExceededException('test');

        expect(syncException, isA<OfflineException>());
        expect(databaseException, isA<OfflineException>());
        expect(connectivityException, isA<OfflineException>());
        expect(fileException, isA<OfflineException>());
        expect(serializationException, isA<OfflineException>());
        expect(configurationException, isA<OfflineException>());
        expect(validationException, isA<OfflineException>());
        expect(retryLimitException, isA<OfflineException>());
        expect(notInitializedException, isA<OfflineException>());
        expect(quotaExceededException, isA<OfflineException>());
      });

      test('all custom exceptions should implement Exception', () {
        const syncException = SyncException('test');
        const databaseException = DatabaseException('test');
        const connectivityException = ConnectivityException('test');
        const fileException = FileException('test');
        const serializationException = SerializationException('test');
        const configurationException = ConfigurationException('test');
        const validationException = ValidationException('test');
        const retryLimitException = RetryLimitExceededException('test');
        const notInitializedException = NotInitializedException('test');
        const quotaExceededException = QuotaExceededException('test');

        expect(syncException, isA<Exception>());
        expect(databaseException, isA<Exception>());
        expect(connectivityException, isA<Exception>());
        expect(fileException, isA<Exception>());
        expect(serializationException, isA<Exception>());
        expect(configurationException, isA<Exception>());
        expect(validationException, isA<Exception>());
        expect(retryLimitException, isA<Exception>());
        expect(notInitializedException, isA<Exception>());
        expect(quotaExceededException, isA<Exception>());
      });
    });

    group('Exception Usage Scenarios', () {
      test('should be throwable and catchable', () {
        expect(
          () => throw const SyncException('Test sync error'),
          throwsA(isA<SyncException>()),
        );

        expect(
          () => throw const DatabaseException('Test database error'),
          throwsA(isA<DatabaseException>()),
        );

        expect(
          () => throw const ConnectivityException('Test connectivity error'),
          throwsA(isA<ConnectivityException>()),
        );
      });

      test('should be catchable as OfflineException', () {
        try {
          throw const SyncException('Test error');
        } on OfflineException catch (e) {
          expect(e.message, 'Test error');
          expect(e, isA<SyncException>());
        }
      });

      test('should be catchable as specific exception type', () {
        try {
          throw const DatabaseException(
            'Connection failed',
            tableName: 'users',
            operation: 'select',
          );
        } on DatabaseException catch (e) {
          expect(e.message, 'Connection failed');
          expect(e.tableName, 'users');
          expect(e.operation, 'select');
        }
      });

      test('should preserve stack trace when re-thrown', () {
        try {
          _throwNestedSyncException();
        } on SyncException catch (e, stackTrace) {
          expect(e.message, 'Nested sync error');
          expect(stackTrace, isNotNull);
          expect(stackTrace.toString(), contains('_throwNestedSyncException'));
        }
      });
    });

    group('Exception Messages and Formatting', () {
      test('should format messages consistently', () {
        const exceptions = [
          SyncException('Sync error message'),
          DatabaseException('Database error message'),
          ConnectivityException('Connectivity error message'),
          FileException('File error message'),
          SerializationException('Serialization error message'),
          ConfigurationException('Configuration error message'),
          ValidationException('Validation error message'),
          RetryLimitExceededException('Retry limit error message'),
          NotInitializedException('Not initialized error message'),
          QuotaExceededException('Quota exceeded error message'),
        ];

        for (final exception in exceptions) {
          final str = exception.toString();
          expect(str, contains('Exception: '));
          expect(str, contains(exception.message));
        }
      });

      test('should handle empty and special characters in messages', () {
        const emptyMessageException = SyncException('');
        expect(emptyMessageException.toString(), 'SyncException: ');

        const specialCharsException = DatabaseException('Error with "quotes" and \n newlines');
        expect(specialCharsException.message, 'Error with "quotes" and \n newlines');

        const unicodeException = FileException('Unicode error: 测试错误 🚫');
        expect(unicodeException.message, 'Unicode error: 测试错误 🚫');
      });
    });
  });
}

// Test implementation of abstract OfflineException
class _TestOfflineException extends OfflineException {
  const _TestOfflineException(super.message, {super.code});
}

// Helper function for testing stack traces
void _throwNestedSyncException() {
  _throwSyncException();
}

void _throwSyncException() {
  throw const SyncException('Nested sync error');
}
