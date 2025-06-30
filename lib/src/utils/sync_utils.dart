import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../core/models/sync_item.dart';
import '../core/models/upload_status.dart';

/// Utility class for sync-related operations
class SyncUtils {
  SyncUtils._();

  /// Generate a unique sync ID for an entity
  static String generateSyncId(String entityType, String entityId) {
    return '${entityType}_$entityId';
  }

  /// Extract entity information from a sync ID
  static (String entityType, String entityId) parseSyncId(String syncId) {
    final parts = syncId.split('_');
    if (parts.length < 2) {
      throw ArgumentError('Invalid sync ID format: $syncId');
    }

    final entityType = parts[0];
    final entityId = parts.sublist(1).join('_');
    return (entityType, entityId);
  }

  /// Check if a file exists and is readable
  static Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() && await file.stat().then((stat) => stat.size > 0);
    } catch (e) {
      return false;
    }
  }

  /// Calculate MD5 checksum of a file
  static Future<String> calculateFileChecksum(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    return stat.size;
  }

  /// Determine MIME type from file extension
  static String? getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    const mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.pdf': 'application/pdf',
      '.txt': 'text/plain',
      '.json': 'application/json',
      '.mp4': 'video/mp4',
      '.mov': 'video/quicktime',
      '.avi': 'video/x-msvideo',
    };

    return mimeTypes[extension];
  }

  /// Compress JSON data if it's above a certain threshold
  static String compressJsonIfNeeded(Map<String, dynamic> data, {int threshold = 1024}) {
    final jsonString = jsonEncode(data);

    if (jsonString.length > threshold) {
      // In a real implementation, you might use gzip compression
      // For now, we'll just return the original string
      return jsonString;
    }

    return jsonString;
  }

  /// Validate sync item data integrity
  static bool validateSyncItem(SyncItem item) {
    // Basic validation
    if (item.id.isEmpty || item.entityType.isEmpty || item.entityId.isEmpty) {
      return false;
    }

    // Check if data is valid JSON-serializable
    try {
      jsonEncode(item.data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if sync item is ready for upload
  static bool isReadyForUpload(SyncItem item) {
    return item.status.isPending && item.isReadyForSync && validateSyncItem(item);
  }

  /// Calculate sync priority score for sorting
  static int calculatePriorityScore(SyncItem item) {
    var score = item.priority.value * 1000;

    // Boost score for items that have been waiting longer
    final waitTime = DateTime.now().difference(item.createdAt);
    score += waitTime.inMinutes;

    // Reduce score for items that have failed multiple times
    score -= item.status.retryCount * 100;

    return score;
  }

  /// Generate a safe filename from entity data
  static String generateSafeFilename(String entityType, String entityId, String extension) {
    final sanitized = '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}';
    return '$sanitized.$extension';
  }

  /// Check if two sync items are related (same entity)
  static bool areRelated(SyncItem item1, SyncItem item2) {
    return item1.entityType == item2.entityType && item1.entityId == item2.entityId;
  }

  /// Merge sync item data (for handling updates to the same entity)
  static Map<String, dynamic> mergeSyncData(
    Map<String, dynamic> existing,
    Map<String, dynamic> update,
  ) {
    final merged = Map<String, dynamic>.from(existing);

    for (final entry in update.entries) {
      merged[entry.key] = entry.value;
    }

    return merged;
  }

  /// Extract file references from sync item data
  static List<String> extractFileReferences(Map<String, dynamic> data) {
    final files = <String>[];

    void extractFromValue(dynamic value) {
      if (value is String) {
        // Check if the string looks like a file path
        if (value.contains('/') && path.extension(value).isNotEmpty) {
          files.add(value);
        }
      } else if (value is List) {
        for (final item in value) {
          extractFromValue(item);
        }
      } else if (value is Map) {
        for (final mapValue in value.values) {
          extractFromValue(mapValue);
        }
      }
    }

    extractFromValue(data);
    return files;
  }

  /// Create a dependency graph for sync items
  static Map<String, List<String>> createDependencyGraph(List<SyncItem> items) {
    final graph = <String, List<String>>{};

    for (final item in items) {
      graph[item.id] = List.from(item.dependencies);
    }

    return graph;
  }

  /// Perform topological sort on sync items to determine upload order
  static List<SyncItem> topologicalSort(List<SyncItem> items) {
    final graph = createDependencyGraph(items);
    final itemMap = {for (final item in items) item.id: item};
    final visited = <String>{};
    final result = <SyncItem>[];

    void visit(String itemId) {
      if (visited.contains(itemId)) return;
      visited.add(itemId);

      final dependencies = graph[itemId] ?? [];
      for (final depId in dependencies) {
        if (itemMap.containsKey(depId)) {
          visit(depId);
        }
      }

      final item = itemMap[itemId];
      if (item != null) {
        result.add(item);
      }
    }

    for (final item in items) {
      visit(item.id);
    }

    return result;
  }

  /// Format sync statistics for display
  static String formatSyncStatistics(int total, int completed, int failed, int pending) {
    if (total == 0) return 'No items to sync';

    final completedPercent = ((completed / total) * 100).round();
    return '$completed/$total completed ($completedPercent%), $failed failed, $pending pending';
  }

  /// Check if network error is retryable
  static bool isRetryableError(Exception error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors that are usually temporary
    final retryableErrors = [
      'timeout',
      'connection',
      'network',
      'unreachable',
      'temporary',
      '503', // Service Unavailable
      '502', // Bad Gateway
      '500', // Internal Server Error
    ];

    return retryableErrors.any((pattern) => errorString.contains(pattern));
  }

  /// Generate upload progress message
  static String generateProgressMessage(UploadStatus status) {
    switch (status.state) {
      case UploadState.pending:
        return 'Waiting to upload...';
      case UploadState.uploading:
        final percent = (status.progress * 100).round();
        return 'Uploading... $percent%';
      case UploadState.completed:
        return 'Upload completed successfully';
      case UploadState.failed:
        return 'Upload failed: ${status.error ?? 'Unknown error'}';
      case UploadState.cancelled:
        return 'Upload cancelled';
    }
  }
}
