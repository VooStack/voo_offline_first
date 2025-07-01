# Offline First Flutter Package

A comprehensive Flutter package for building offline-first applications with Clean Architecture, featuring automatic synchronization, conflict resolution, and seamless offline/online transitions.

## Features

- 🔄 **Automatic Synchronization** - Syncs data automatically when connection is restored
- 📱 **Offline-First Architecture** - Works seamlessly offline with local storage
- 🏗️ **Clean Architecture** - Built with separation of concerns and SOLID principles
- 💾 **Drift Database** - Powerful SQLite abstraction with type safety
- 🔀 **Conflict Resolution** - Customizable strategies for handling sync conflicts
- 📊 **Sync Status Monitoring** - Real-time sync status with UI components
- 🎯 **Developer Friendly** - Reduces boilerplate with base classes and utilities
- 🧪 **Testable** - Designed with testing in mind

## Installation

```yaml
dependencies:
  voo_offline_first: ^0.0.1
```

## Quick Start

### 1. Define Your Entity

```dart
import 'package:voo_offline_first/voo_offline_first.dart';

class Todo extends SyncableEntity {
  final String title;
  final String description;
  final bool isCompleted;

  const Todo({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.syncStatus,
    required this.title,
    required this.description,
    required this.isCompleted,
    super.lastSyncedAt,
    super.isDeleted,
    super.syncError,
  });
}
```

### 2. Create Your Model

```dart
@JsonSerializable()
class TodoModel extends SyncableModel<Todo> {
  final String title;
  final String description;
  final bool isCompleted;

  // ... constructor and methods
}
```

### 3. Setup Repository

```dart
class TodoRepositoryImpl extends BaseRepositoryImpl<Todo, TodoModel> {
  TodoRepositoryImpl({
    required super.localDataSource,
    required super.remoteDataSource,
    required super.networkInfo,
  });

  @override
  TodoModel entityToModel(Todo entity) => TodoModel.fromEntity(entity);
}
```

### 4. Use in UI

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Todos'),
      actions: [
        SyncStatusIcon(syncManager: _syncManager),
      ],
    ),
    body: OfflineBuilder(
      networkInfo: _networkInfo,
      builder: (context, isOnline) {
        return TodoList(isOnline: isOnline);
      },
    ),
  );
}
```

## Core Components

### Entities

- `BaseEntity` - Base class for all domain entities
- `SyncableEntity` - Extended base for entities that need synchronization

### Models

- `BaseModel<T>` - Base class for data models with JSON serialization
- `SyncableModel<T>` - Extended base for syncable data models

### Repositories

- `BaseRepository<T>` - Repository interface with common operations
- `BaseRepositoryImpl<T, M>` - Offline-first repository implementation

### Data Sources

- `LocalDataSource<T, M>` - Interface for local storage operations
- `RemoteDataSource<T, M>` - Interface for remote API operations

### Synchronization

- `SyncManager` - Manages automatic synchronization
- `SyncHandler` - Handles sync logic for specific entity types
- `SyncState` - Represents current synchronization status

### UI Components

- `OfflineBuilder` - Rebuilds UI based on connectivity status
- `OfflineIndicator` - Shows offline status
- `SyncIndicator` - Displays sync progress and errors
- `SyncStatusIcon` - Minimal sync status indicator

## Architecture

```
lib/
├── domain/
│   ├── entities/        # Business objects
│   ├── repositories/    # Repository interfaces
│   └── usecases/       # Business logic
├── data/
│   ├── models/         # Data models with serialization
│   ├── datasources/    # Local and remote data sources
│   └── repositories/   # Repository implementations
└── presentation/
    └── widgets/        # UI components
```

## Advanced Usage

### Custom Sync Intervals

```dart
final syncManager = SyncManagerImpl(
  networkInfo: networkInfo,
  prefs: prefs,
  syncInterval: const Duration(minutes: 10),
);
```

### Conflict Resolution

```dart
class CustomSyncHandler extends SyncHandler {
  @override
  Future<void> resolveConflict(dynamic local, dynamic remote) async {
    // Implement your conflict resolution strategy
    // Options: last-write-wins, merge, user-choice
  }
}
```

### Batch Operations

```dart
final todos = List.generate(10, (i) => Todo(...));
await repository.batchCreate(todos);
```

### Error Handling

```dart
final result = await repository.create(todo);

result.fold(
  (failure) => handleError(failure),
  (todo) => handleSuccess(todo),
);
```

## Widget Examples

### Offline Builder

```dart
OfflineBuilder(
  networkInfo: networkInfo,
  builder: (context, isOnline) {
    return Column(
      children: [
        if (!isOnline) OfflineBanner(),
        TodoList(),
      ],
    );
  },
);
```

### Sync Indicator

```dart
SyncIndicator(
  syncManager: syncManager,
  showErrors: true,
  showProgress: true,
  builder: (context, state) {
    if (state.isSyncing) {
      return LinearProgressIndicator(value: state.progress);
    }
    return const SizedBox.shrink();
  },
);
```

## Configuration

### Database Configuration

```dart
final config = DatabaseConfig(
  name: 'my_app.db',
  schemaVersion: 1,
  tables: [todos, users],
  migrationStrategy: MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // Handle migrations
    },
  ),
);
```

### Network Configuration

```dart
final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  headers: {'Authorization': 'Bearer $token'},
));
```

## Best Practices

1. **Entity Design**
   - Always extend `SyncableEntity` for synchronized data
   - Use `uuid` package for generating unique IDs
   - Include proper timestamps for conflict resolution

2. **Error Handling**
   - Always handle both online and offline scenarios
   - Provide user feedback for sync status
   - Implement retry mechanisms for failed syncs

3. **Performance**
   - Use pagination for large datasets
   - Implement proper indexing in Drift tables
   - Batch operations when possible

4. **Testing**
   - Mock network conditions
   - Test sync conflict scenarios
   - Verify offline functionality

## Example App

Check out the [example](example/) directory for a complete Todo application demonstrating all features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

```
MIT License

Copyright (c) 2025 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```