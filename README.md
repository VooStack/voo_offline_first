# 🚀 VooOfflineFirst - Flutter Offline-First Package

[![pub package](https://img.shields.io/pub/v/voo_offline_first.svg)](https://pub.dev/packages/voo_offline_first)
[![GitHub license](https://img.shields.io/github/license/voostack/voo_offline_first)](https://github.com/voostack/voo_offline_first/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/voostack/voo_offline_first)](https://github.com/voostack/voo_offline_first/stargazers)

A comprehensive Flutter package that enables **offline-first functionality** with automatic synchronization, built with **clean architecture** principles and powered by **Drift** database and **BLoC** state management.

Perfect for field applications, mobile-first experiences, and any app that needs to work reliably without constant internet connectivity.

## ✨ Features

- 🔄 **Automatic Sync**: Seamlessly sync data when connectivity is restored
- 💾 **Robust Local Storage**: Powered by Drift for reliable local database management  
- 🏗️ **Clean Architecture**: Well-structured interfaces and implementations for maintainable code
- 🔌 **Smart Connectivity**: Intelligent connectivity detection and handling
- 📱 **Reactive State Management**: Built-in BLoC integration for real-time UI updates
- 🎯 **Code Generation**: Automatic repository and table generation with build_runner
- 🔁 **Intelligent Retry Logic**: Smart retry mechanisms with exponential backoff
- 📊 **Progress Tracking**: Real-time sync progress and status monitoring
- 🎨 **Pre-built UI Components**: Ready-to-use widgets for sync status and progress
- 📱 **Background Sync**: Support for background synchronization
- 🔒 **Offline Security**: Secure local data storage with optional encryption
- ⚡ **High Performance**: Optimized for large datasets and frequent sync operations

## 🎯 Use Cases

- **Field Data Collection**: Perfect for apps like safety reporting, inspections, surveys
- **Mobile-First Applications**: Apps that prioritize offline functionality
- **IoT and Remote Work**: Applications for areas with poor connectivity
- **Enterprise Solutions**: Business apps requiring reliable data synchronization
- **Social and Content Apps**: Apps where users create content offline

## 📦 Installation

### Step 1: Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # Core package
  voo_offline_first: ^1.0.0
  
  # Required peer dependencies
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  dio: ^5.3.0
  bloc: ^8.1.0
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5
  connectivity_plus: ^5.0.0
  uuid: ^4.0.0
  json_annotation: ^4.8.0
  path_provider: ^2.1.0

dev_dependencies:
  # Code generation
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  json_serializable: ^6.7.0
```

### Step 2: Install Packages

```bash
flutter pub get
```

### Step 3: Run Code Generation

```bash
dart run build_runner build
```

## 🚀 Quick Start Guide

Let's build a simple task management app that works offline!

### Step 1: Define Your Data Model

Create `lib/models/task.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

part 'task.g.dart';

@OfflineEntity(
  tableName: 'tasks',
  endpoint: '/api/tasks',
  syncPriority: SyncPriority.normal,
)
@JsonSerializable()
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  // Required for serialization
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  // Required for state management
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, createdAt];
}
```

### Step 2: Create Database Tables

Create `lib/database/app_database.dart`:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:voo_offline_first/voo_offline_first.dart';
import '../models/task.dart';

part 'app_database.g.dart';

// Define your app's tables
@DataClassName('TaskData')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Tasks, SyncItems, EntityMetadataTable, FileSyncItems, SyncConfigs],
  include: {'package:voo_offline_first/src/database/tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.db'));
    return NativeDatabase(file);
  });
}
```

### Step 3: Create Repository

Create `lib/repositories/task_repository.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../models/task.dart';
import '../database/app_database.dart';

class TaskRepository extends BaseOfflineRepository<Task> {
  TaskRepository({
    required AppDatabase database,
    required SyncManager syncManager,
  }) : _appDatabase = database, 
       super(
         database: database,
         syncManager: syncManager,
         entityType: 'Task',
         offlineEntity: const OfflineEntity(
           tableName: 'tasks',
           endpoint: '/api/tasks',
         ),
       );

  final AppDatabase _appDatabase;

  @override
  String get tableName => 'tasks';

  @override
  Map<String, dynamic> toJson(Task entity) => entity.toJson();

  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);

  @override
  String getId(Task entity) => entity.id;

  @override
  Task setId(Task entity, String id) => entity.copyWith(id: id);

  @override
  Future<void> insertEntity(Task entity) async {
    await _appDatabase.into(_appDatabase.tasks).insert(
      TasksCompanion.insert(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isCompleted: entity.isCompleted,
        createdAt: entity.createdAt,
      ),
    );
  }

  @override
  Future<void> updateEntity(Task entity) async {
    await (_appDatabase.update(_appDatabase.tasks)
          ..where((tbl) => tbl.id.equals(entity.id)))
        .write(TasksCompanion(
          title: Value(entity.title),
          description: Value(entity.description),
          isCompleted: Value(entity.isCompleted),
        ));
  }

  @override
  Future<void> deleteEntityById(String id) async {
    await (_appDatabase.delete(_appDatabase.tasks)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<Task?> getEntityById(String id) async {
    final query = _appDatabase.select(_appDatabase.tasks)
      ..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _convertToTask(result) : null;
  }

  @override
  Future<List<Task>> getAllEntities() async {
    final query = _appDatabase.select(_appDatabase.tasks);
    final results = await query.get();
    return results.map(_convertToTask).toList();
  }

  @override
  Future<List<Task>> getEntitiesWhere(Map<String, dynamic> criteria) async {
    var query = _appDatabase.select(_appDatabase.tasks);
    
    if (criteria.containsKey('isCompleted')) {
      query = query..where((tbl) => tbl.isCompleted.equals(criteria['isCompleted']));
    }
    
    final results = await query.get();
    return results.map(_convertToTask).toList();
  }

  @override
  Stream<List<Task>> watchAllEntities() {
    return _appDatabase.select(_appDatabase.tasks).watch()
        .map((rows) => rows.map(_convertToTask).toList());
  }

  @override
  Stream<List<Task>> watchEntitiesWhere(Map<String, dynamic> criteria) {
    var query = _appDatabase.select(_appDatabase.tasks);
    
    if (criteria.containsKey('isCompleted')) {
      query = query..where((tbl) => tbl.isCompleted.equals(criteria['isCompleted']));
    }
    
    return query.watch().map((rows) => rows.map(_convertToTask).toList());
  }

  Task _convertToTask(TaskData data) {
    return Task(
      id: data.id,
      title: data.title,
      description: data.description,
      isCompleted: data.isCompleted,
      createdAt: data.createdAt,
    );
  }
}
```

### Step 4: Set Up BLoC

Create `lib/blocs/task/task_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../../repositories/task_repository.dart';

// Events
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}
class AddTask extends TaskEvent {
  final String title;
  final String description;
  AddTask({required this.title, required this.description});
  @override
  List<Object?> get props => [title, description];
}

class ToggleTask extends TaskEvent {
  final String taskId;
  ToggleTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

// States
abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  TaskLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final _uuid = const Uuid();

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final task = Task(
        id: _uuid.v4(),
        title: event.title,
        description: event.description,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await repository.save(task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TaskState> emit) async {
    try {
      final task = await repository.getById(event.taskId);
      if (task != null) {
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        await repository.save(updatedTask);
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await repository.delete(event.taskId);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
```

### Step 5: Initialize Services

Create `lib/services/app_services.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../database/app_database.dart';
import '../repositories/task_repository.dart';

class AppServices {
  static late AppDatabase database;
  static late ConnectivityService connectivityService;
  static late SyncManager syncManager;
  static late TaskRepository taskRepository;

  static Future<void> initialize() async {
    // Initialize database
    database = AppDatabase();

    // Initialize connectivity service
    connectivityService = ConnectivityServiceImpl();
    await connectivityService.initialize();

    // Initialize sync manager
    syncManager = SyncManagerImpl(
      database: database,
      connectivityService: connectivityService,
      dio: Dio(BaseOptions(
        baseUrl: 'https://your-api.com', // Replace with your API URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )),
    );
    await syncManager.initialize();

    // Initialize repositories
    taskRepository = TaskRepository(
      database: database,
      syncManager: syncManager,
    );

    // Start auto-sync
    await syncManager.startAutoSync();
  }

  static Future<void> dispose() async {
    await syncManager.dispose();
    await connectivityService.dispose();
    await database.close();
  }
}
```

### Step 6: Set Up Main App

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import 'services/app_services.dart';
import 'blocs/task/task_bloc.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await AppServices.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SyncBloc(
              syncManager: AppServices.syncManager,
              connectivityService: AppServices.connectivityService,
            )..add(const SyncInitialize()),
          ),
          BlocProvider(
            create: (context) => TaskBloc(repository: AppServices.taskRepository)
              ..add(LoadTasks()),
          ),
        ],
        child: const TaskListScreen(),
      ),
    );
  }
}
```

### Step 7: Create UI

Create `lib/screens/task_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../blocs/task/task_bloc.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: const [
          SyncStatusIndicator(showText: true),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Show offline banner when disconnected
          const OfflineBanner(),
          
          // Show sync progress
          const SyncProgressCard(),
          
          // Task list
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet. Add one below!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        subtitle: Text(task.description),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) {
                            context.read<TaskBloc>().add(ToggleTask(task.id));
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<TaskBloc>().add(DeleteTask(task.id));
                          },
                        ),
                      );
                    },
                  );
                } else if (state is TaskError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "add",
            onPressed: () => _showAddTaskDialog(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          const SyncFab(),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TaskBloc>().add(AddTask(
                  title: titleController.text,
                  description: descriptionController.text,
                ));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
```

### Step 8: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 9: Test Your App

```bash
flutter run
```

## 🎉 Congratulations!

You now have a fully functional offline-first task app! The app will:

- ✅ Work completely offline
- ✅ Store data locally using Drift
- ✅ Automatically sync when internet is available
- ✅ Show sync status in the UI
- ✅ Handle connectivity changes gracefully

## 📚 Next Steps

### Add File Sync

For apps that need to sync files (images, documents):

```dart
@OfflineEntity(
  tableName: 'reports',
  endpoint: '/api/reports',
  syncFields: ['images', 'documents'], // Mark file fields
)
class Report {
  @SyncField(type: SyncFieldType.fileList)
  final List<String> images;
  
  @SyncField(type: SyncFieldType.file)
  final String? documentPath;
  
  // ... other fields
}
```

### Custom Sync Logic

```dart
class CustomSyncHandler implements SyncHandler {
  @override
  Future<SyncResult> sync(SyncItem item) async {
    // Your custom sync logic here
    try {
      // Upload files first
      await uploadFiles(item.data);
      
      // Then sync the main data
      final response = await api.post('/custom-endpoint', data: item.data);
      
      return SyncResult.success(responseData: response.data);
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
}

// Register the custom handler
syncManager.registerSyncHandler('Report', CustomSyncHandler());
```

### Background Sync

For syncing when app is in background:

```dart
// Add to pubspec.yaml
// workmanager: ^0.5.1

// Initialize background tasks
await Workmanager().initialize(callbackDispatcher);
await Workmanager().registerPeriodicTask(
  'sync-task',
  'syncData',
  frequency: const Duration(hours: 1),
);

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize your sync manager and run sync
    await AppServices.initialize();
    await AppServices.syncManager.syncNow();
    return Future.value(true);
  });
}
```

## 🛠️ Configuration

### Database Migration

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (migrator, from, to) async {
    if (from < 2) {
      await migrator.addColumn(tasks, tasks.priority);
    }
  },
);
```

### Custom Retry Policy

```dart
final customRetryPolicy = SmartRetryPolicy(
  maxRetries: 5,
  baseDelay: const Duration(seconds: 2),
  maxDelay: const Duration(minutes: 10),
);

final syncManager = SyncManagerImpl(
  database: database,
  connectivityService: connectivityService,
  dio: dio,
  retryPolicy: customRetryPolicy,
);
```

### Authentication

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${getToken()}';
    handler.next(options);
  }
}

final dio = Dio()..interceptors.add(AuthInterceptor());
```

## 🐛 Troubleshooting

### Common Issues

**1. Build Runner Issues**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**2. Sync Not Working**
- Check your API endpoint URLs
- Verify internet connectivity
- Check authentication headers
- Look at sync error logs in the UI

**3. Database Issues**
```dart
// Reset database during development
await database.close();
final dbFile = File(p.join(dbFolder.path, 'app_database.db'));
if (await dbFile.exists()) {
  await dbFile.delete();
}
```

**4. Performance Issues**
- Use pagination for large datasets
- Implement proper database indexes
- Monitor sync queue size

### Enable Debug Logging

```dart
// Add to main.dart for development
if (kDebugMode) {
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- 📧 Email: support@voostack.com
- 🐛 Issues: [GitHub Issues](https://github.com/voostack/voo_offline_first/issues)
- 📖 Documentation: [Full Documentation](https://docs.voostack.com/voo_offline_first)
- 💬 Discussions: [GitHub Discussions](https://github.com/voostack/voo_offline_first/discussions)

---

Made with ❤️ by [VooStack](https://voostack.com)