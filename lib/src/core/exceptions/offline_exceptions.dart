/// Base exception class for offline-first package
abstract class OfflineException implements Exception {
  const OfflineException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'OfflineException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when sync operations fail
class SyncException extends OfflineException {
  const SyncException(
    super.message, {
    super.code,
    this.entityType,
    this.entityId,
    this.retryable = true,
  });

  final String? entityType;
  final String? entityId;
  final bool retryable;

  @override
  String toString() {
    final entityInfo = entityType != null && entityId != null ? ' (Entity: $entityType:$entityId)' : '';
    return 'SyncException: $message$entityInfo${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when database operations fail
class DatabaseException extends OfflineException {
  const DatabaseException(
    super.message, {
    super.code,
    this.tableName,
    this.operation,
  });

  final String? tableName;
  final String? operation;

  @override
  String toString() {
    final details = [
      if (tableName != null) 'Table: $tableName',
      if (operation != null) 'Operation: $operation',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'DatabaseException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when connectivity is required but not available
class ConnectivityException extends OfflineException {
  const ConnectivityException(
    super.message, {
    super.code,
    this.requiredConnectionType,
  });

  final String? requiredConnectionType;

  @override
  String toString() {
    final typeInfo = requiredConnectionType != null ? ' (Required: $requiredConnectionType)' : '';
    return 'ConnectivityException: $message$typeInfo${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when file operations fail
class FileException extends OfflineException {
  const FileException(
    super.message, {
    super.code,
    this.filePath,
    this.operation,
  });

  final String? filePath;
  final String? operation;

  @override
  String toString() {
    final details = [
      if (filePath != null) 'File: $filePath',
      if (operation != null) 'Operation: $operation',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'FileException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when serialization/deserialization fails
class SerializationException extends OfflineException {
  const SerializationException(
    super.message, {
    super.code,
    this.entityType,
    this.operation,
  });

  final String? entityType;
  final String? operation; // 'serialize' or 'deserialize'

  @override
  String toString() {
    final details = [
      if (entityType != null) 'Entity: $entityType',
      if (operation != null) 'Operation: $operation',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'SerializationException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when configuration is invalid or missing
class ConfigurationException extends OfflineException {
  const ConfigurationException(
    super.message, {
    super.code,
    this.configKey,
  });

  final String? configKey;

  @override
  String toString() {
    final keyInfo = configKey != null ? ' (Key: $configKey)' : '';
    return 'ConfigurationException: $message$keyInfo${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when validation fails
class ValidationException extends OfflineException {
  const ValidationException(
    super.message, {
    super.code,
    this.fieldName,
    this.value,
  });

  final String? fieldName;
  final dynamic value;

  @override
  String toString() {
    final details = [
      if (fieldName != null) 'Field: $fieldName',
      if (value != null) 'Value: $value',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'ValidationException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when retry limit is exceeded
class RetryLimitExceededException extends OfflineException {
  const RetryLimitExceededException(
    super.message, {
    super.code,
    this.maxRetries,
    this.lastError,
  });

  final int? maxRetries;
  final String? lastError;

  @override
  String toString() {
    final details = [
      if (maxRetries != null) 'Max retries: $maxRetries',
      if (lastError != null) 'Last error: $lastError',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'RetryLimitExceededException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when attempting to perform operations on uninitialized services
class NotInitializedException extends OfflineException {
  const NotInitializedException(
    super.message, {
    super.code,
    this.serviceName,
  });

  final String? serviceName;

  @override
  String toString() {
    final serviceInfo = serviceName != null ? ' (Service: $serviceName)' : '';
    return 'NotInitializedException: $message$serviceInfo${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when quota or limits are exceeded
class QuotaExceededException extends OfflineException {
  const QuotaExceededException(
    super.message, {
    super.code,
    this.quotaType,
    this.currentValue,
    this.maxValue,
  });

  final String? quotaType;
  final dynamic currentValue;
  final dynamic maxValue;

  @override
  String toString() {
    final details = [
      if (quotaType != null) 'Quota: $quotaType',
      if (currentValue != null && maxValue != null) 'Usage: $currentValue/$maxValue',
      if (code != null) 'Code: $code',
    ].join(', ');

    return 'QuotaExceededException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}
