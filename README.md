# 🚀 Offline First Flutter Package

[![pub package](https://img.shields.io/pub/v/offline_first.svg)](https://pub.dev/packages/offline_first)
[![GitHub license](https://img.shields.io/github/license/yourcompany/offline_first)](https://github.com/yourcompany/offline_first/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/yourcompany/offline_first)](https://github.com/yourcompany/offline_first/stargazers)

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

- **Field Data Collection**: Perfect for apps like GoodCatch safety reporting
- **Mobile-First Applications**: Apps that prioritize offline functionality
- **IoT and Remote Work**: Applications for areas with poor connectivity
- **Enterprise Solutions**: Business apps requiring reliable data synchronization
- **Social and Content Apps**: Apps where users create content offline

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  offline_first: ^1.0.0
  
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

dev_dependencies:
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  json_serializable: ^6.7.0
```

Then run:
```bash
flutter pub get
dart run build_runner build
```

## 🚀 Quick Start

### 1. Define Your Entity

Create your data model with offline annotations:

```dart
@OfflineEntity(
  tableName: 'good_catches',
  endpoint: '/api/good-catches',
  syncFields: ['images', 'location'],
  syncPriority: SyncPriority.high,
)
@JsonSerializable()
class GoodCatch extends Equatable {
  const GoodCatch({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.images,
    required this.createdAt,
    required this.reporterId,
  });

  final String id;
  final String title;
  final String description;
  
  @SyncField(type: SyncFieldType.location, priority: SyncFieldPriority.high)
  final GoodCatchLocation location;
  
  @SyncField(type: SyncFieldType.fileList)
  final List<String> images;
  
  final DateTime createdAt;
  final String reporterId;

  // Required methods
  GoodCatch copyWith({...});
  factory GoodCatch.fromJson(Map<String, dynamic> json) => _$GoodCatchFromJson(json);
  Map<String, dynamic> toJson() => _$GoodCatchToJson(this);
  
  @override
  List<Object?> get props => [id, title, description, location, images, createdAt, reporterId];
}
```

### 2. Create Your Repository

Extend the base repository:

```dart
class GoodCatchRepository extends BaseOfflineRepository<GoodCatch> {
  GoodCatchRepository({
    required super.database,
    required super.syncManager,
  }) : super(
    entityType: 'GoodCatch',
    offlineEntity: const OfflineEntity(
      tableName: 'good_catches',
      endpoint: '/api/good-catches',
    ),
  );

  // Implement required abstract methods
  @override
  Map<String, dynamic> toJson(GoodCatch entity) => entity.toJson();

  @override
  GoodCatch fromJson(Map<String, dynamic> json) => GoodCatch.fromJson(json);

  @override
  String getId(GoodCatch entity) => entity.id;

  @override
  GoodCatch setId(GoodCatch entity, String id) => entity.copyWith(id: id);

  // Implement CRUD operations (see full example in documentation)
  @override
  Future<void> insertEntity(GoodCatch entity) async {
    // Your Drift table insert logic
  }
  
  // ... other required methods
}
```

### 3. Setup Your App

Initialize the offline-first system:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OfflineFirstProvider(
        child: HomeScreen(),
      ),
    );
  }
}

class OfflineFirstProvider extends StatefulWidget {
  final Widget child;
  const OfflineFirstProvider({required this.child});

  @override
  State<OfflineFirstProvider> createState() => _OfflineFirstProviderState();
}

class _OfflineFirstProviderState extends State<OfflineFirstProvider> {
  late final SyncDatabase database;
  late final SyncManager syncManager;
  late final ConnectivityService connectivityService;
  late final GoodCatchRepository repository;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize core services
    database = SyncDatabase();
    connectivityService = ConnectivityServiceImpl();
    await connectivityService.initialize();

    syncManager = SyncManagerImpl(
      database: database,
      connectivityService: connectivityService,
      dio: Dio(BaseOptions(baseUrl: 'https://your-api.com')),
    );
    await syncManager.initialize();

    repository = GoodCatchRepository(
      database: database,
      syncManager: syncManager,
    );

    // Start auto-sync
    await syncManager.startAutoSync();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GoodCatchRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SyncBloc(
              syncManager: syncManager,
              connectivityService: connectivityService,
            )..add(const SyncInitialize()),
          ),
          BlocProvider(
            create: (context) => GoodCatchBloc(repository)
              ..add(LoadGoodCatchs()),
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
```

### 4. Use in Your UI

Display sync status and manage offline data:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Catches'),
        actions: [
          const SyncStatusIndicator(showText: true),
        ],
      ),
      body: Column(
        children: [
          // Show offline banner when not connected
          const OfflineBanner(),
          
          // Show sync progress
          const SyncProgressCard(),
          
          // Your main content
          Expanded(
            child: BlocBuilder<GoodCatchBloc, GoodCatchState>(
              builder: (context, state) {
                if (state is GoodCatchLoaded) {
                  return ListView.builder(
                    itemCount: state.entities.length,
                    itemBuilder: (context, index) {
                      final item = state.entities[index];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.description),
                        trailing: StreamBuilder<UploadStatus?>(
                          stream: repository.watchUploadStatus(item.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ItemSyncStatus(
                                status: snapshot.data!,
                                compact: true,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      );
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const SyncFab(),
    );
  }
}
```

## 🏗️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│             UI Layer                │
│  ┌─────────────┐ ┌─────────────┐   │
│  │   Widgets   │ │    BLoCs    │   │
│  └─────────────┘ └─────────────┘   │
└─────────────────────────────────────┘
           │
┌─────────────────────────────────────┐
│           Domain Layer              │
│  ┌─────────────┐ ┌─────────────┐   │
│  │ Interfaces  │ │   Models    │   │
│  └─────────────┘ └─────────────┘   │
└─────────────────────────────────────┘
           │
┌─────────────────────────────────────┐
│            Data Layer               │
│  ┌─────────────┐ ┌─────────────┐   │
│  │Repositories │ │  Database   │   │
│  └─────────────┘ └─────────────┘   │
└─────────────────────────────────────┘
```

### Core Components

- **OfflineRepository**: Abstract interface for data access
- **SyncManager**: Handles sync operations and queuing
- **ConnectivityService**: Monitors network status
- **SyncDatabase**: Drift-based local storage
- **SyncBloc**: State management for sync operations

## 🎯 Advanced Usage

### Custom Sync Handlers

Implement custom sync logic for specific entity types:

```dart
class GoodCatchSyncHandler implements SyncHandler {
  @override
  Future<SyncResult> sync(SyncItem item) async {
    try {
      final goodCatch = GoodCatch.fromJson(item.data);
      
      // Upload images first
      final uploadedImageUrls = <String>[];
      for (final imagePath in goodCatch.images) {
        final imageUrl = await _uploadImage(imagePath);
        uploadedImageUrls.add(imageUrl);
      }
      
      // Update the good catch with uploaded image URLs
      final updatedData = goodCatch.copyWith(
        images: uploadedImageUrls,
      ).toJson();
      
      // Send to server
      final response = await dio.post(
        item.endpoint ?? '/api/good-catches',
        data: updatedData,
      );
      
      return response.statusCode == 200
          ? SyncResult.success(responseData: response.data)
          : SyncResult.failure('HTTP ${response.statusCode}');
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
}

// Register the handler
syncManager.registerSyncHandler('GoodCatch', GoodCatchSyncHandler());
```

### Background Sync

Set up background synchronization:

```dart
class BackgroundSyncService {
  static Future<void> initialize() async {
    Workmanager().initialize(callbackDispatcher);
    
    Workmanager().registerPeriodicTask(
      'sync-task',
      'syncOfflineData',
      frequency: const Duration(hours: 1),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final syncManager = await SyncManager.getInstance();
    await syncManager.syncNow();
    return Future.value(true);
  });
}
```

### Sync Strategies

Configure different sync approaches:

```dart
// Immediate sync (default)
syncManager.setSyncStrategy(SyncStrategy.immediate);

// Batched sync for efficiency
syncManager.setSyncStrategy(SyncStrategy.batched);

// Scheduled sync
syncManager.setSyncStrategy(SyncStrategy.scheduled);
```

### Code Generation

Run these commands for code generation:

```bash
# Generate all code
dart run build_runner build

# Watch for changes during development
dart run build_runner watch

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## 📚 API Reference

### Core Interfaces

#### OfflineRepository<T>
```dart
abstract class OfflineRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> save(T entity);
  Future<void> delete(String id);
  Future<List<T>> getPendingSync();
  Stream<List<T>> watchAll();
  // ... more methods
}
```

#### SyncManager
```dart
abstract class SyncManager {
  Future<void> initialize();
  Future<void> queueForSync(SyncItem item);
  Future<void> startAutoSync();
  Future<void> syncNow();
  Stream<SyncStatus> watchSyncStatus();
  // ... more methods
}
```

### Models

#### SyncItem
Represents an item in the sync queue with priority, dependencies, and retry logic.

#### UploadStatus
Tracks upload progress and status (pending, uploading, completed, failed).

#### SyncResult
Result of a sync operation with success/failure and response data.

### Widgets

#### SyncStatusIndicator
Shows current sync status with icon and optional text.

#### SyncProgressCard
Displays detailed sync progress with statistics and controls.

#### ItemSyncStatus
Shows sync status for individual items (compact or detailed view).

#### OfflineBanner
Alerts users when the app is offline with retry option.

#### SyncFab
Floating action button for manual sync with progress indicator.

### Annotations

#### @OfflineEntity
```dart
@OfflineEntity(
  tableName: 'table_name',
  endpoint: '/api/endpoint',
  syncFields: ['field1', 'field2'],
  syncPriority: SyncPriority.high,
)
```

#### @SyncField
```dart
@SyncField(
  type: SyncFieldType.fileList,
  compress: true,
  priority: SyncFieldPriority.high,
)
```

## 🔧 Configuration

### Database Configuration

Configure Drift in `build.yaml`:

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          compact_query_methods: true
          use_data_class_name_for_companions: true
          case_from_dart_to_sql: snake_case
```

### Network Configuration

Setup Dio with interceptors:

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://your-api.com',
  connectTimeout: const Duration(seconds: 10),
));

// Add authentication
dio.interceptors.add(AuthInterceptor());

// Add logging
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

### Sync Configuration

Customize sync behavior:

```dart
final syncManager = SyncManagerImpl(
  database: database,
  connectivityService: connectivityService,
  dio: dio,
  retryPolicy: ExponentialBackoffRetryPolicy(
    maxRetries: 5,
    baseDelay: Duration(seconds: 2),
  ),
);
```

## 💡 Best Practices

### 1. Entity Design
- Keep entities simple and focused
- Use immutable data structures
- Implement proper `copyWith` methods
- Add comprehensive `props` for Equatable

### 2. Sync Fields
- Only mark fields that truly need special handling
- Use appropriate `SyncFieldType` for data
- Consider compression for large data
- Set proper priorities

### 3. Error Handling
- Implement proper error handling in repositories
- Use typed exceptions for different error scenarios
- Provide meaningful error messages to users
- Log errors for debugging

### 4. Performance
- Use pagination for large datasets
- Implement proper indexing in database tables
- Batch operations when possible
- Monitor sync queue size

### 5. Testing
```dart
// Test your repositories
testWidgets('should save entity offline', (tester) async {
  final repository = MockGoodCatchRepository();
  final entity = GoodCatch(...);
  
  await repository.save(entity);
  
  verify(repository.save(entity)).called(1);
  expect(await repository.getById(entity.id), equals(entity));
});

// Test sync operations
test('should sync pending items', () async {
  final syncManager = MockSyncManager();
  
  await syncManager.syncNow();
  
  verify(syncManager.syncNow()).called(1);
});
```

## 🚫 Troubleshooting

### Common Issues

**Build Runner Issues**
```bash
# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# If still having issues
flutter clean
flutter pub get
dart run build_runner build
```

**Database Migration Issues**
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Add your migration logic
        await migrator.addColumn(goodCatches, goodCatches.newColumn);
      }
    },
  );
}
```

**Sync Issues**
- Check network connectivity
- Verify API endpoints are correct
- Review error logs in sync status
- Ensure proper authentication headers

**Performance Issues**
- Implement pagination for large datasets
- Use proper database indexes
- Avoid frequent sync operations
- Monitor memory usage

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/ColtonDevAcc/offline_first.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Create a feature branch: `git checkout -b feature/amazing-feature`
6. Make your changes and add tests
7. Ensure tests pass: `flutter test`
8. Commit your changes: `git commit -m 'Add amazing feature'`
9. Push to your branch: `git push origin feature/amazing-feature`
10. Open a Pull Request

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Write tests for new features
- Document public APIs
- Use meaningful commit messages
- Keep PRs focused and small

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Drift](https://drift.simonbinder.eu/) for excellent database support
- [BLoC](https://bloclibrary.dev/) for state management
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus) for connectivity monitoring
- [Dio](https://pub.dev/packages/dio) for HTTP client

## 📞 Support

- 📧 Email: support@voostack.com
- 🐛 Issues: [GitHub Issues](https://github.com/voostack/offline_first/issues)
- 📖 Documentation: [Full Documentation](https://docs.voostack.com/offline_first)
- 💬 Discussions: [GitHub Discussions](https://github.com/voostack/offline_first/discussions)

---

Made with ❤️ by [Your Company](https://voostack.com)