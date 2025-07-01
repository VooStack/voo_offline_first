import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

// Mock classes
class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('SyncBloc', () {
    late SyncBloc syncBloc;
    late MockSyncManager mockSyncManager;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      mockSyncManager = MockSyncManager();
      mockConnectivityService = MockConnectivityService();

      // Set up default mock behaviors
      when(() => mockConnectivityService.initialize()).thenAnswer((_) async {});
      when(() => mockSyncManager.initialize()).thenAnswer((_) async {});
      when(() => mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(() => mockSyncManager.getSyncQueue()).thenAnswer((_) async => []);
      when(() => mockConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
      when(() => mockSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
      when(() => mockSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
      when(() => mockSyncManager.watchSyncProgress()).thenAnswer(
        (_) => Stream.value(
          const SyncProgress(
            total: 0,
            completed: 0,
            failed: 0,
            inProgress: 0,
          ),
        ),
      );
      when(() => mockSyncManager.dispose()).thenAnswer((_) async {});
      when(() => mockConnectivityService.dispose()).thenAnswer((_) async {});

      syncBloc = SyncBloc(
        syncManager: mockSyncManager,
        connectivityService: mockConnectivityService,
      );
    });

    tearDown(() {
      syncBloc.close();
    });

    test('initial state is SyncInitial', () {
      expect(syncBloc.state, isA<SyncInitial>());
    });

    group('SyncInitialize', () {
      blocTest<SyncBloc, SyncState>(
        'emits [SyncInitializing, SyncIdle] when initialization succeeds',
        build: () => syncBloc,
        act: (bloc) => bloc.add(const SyncInitialize()),
        expect: () => [
          isA<SyncInitializing>(),
          isA<SyncIdle>(),
        ],
        verify: (_) {
          verify(() => mockConnectivityService.initialize()).called(1);
          verify(() => mockSyncManager.initialize()).called(1);
          verify(() => mockConnectivityService.isConnected()).called(1);
          verify(() => mockSyncManager.getSyncQueue()).called(1);
        },
      );

      blocTest<SyncBloc, SyncState>(
        'emits [SyncInitializing, SyncError] when initialization fails',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.initialize()).thenThrow(Exception('Initialization failed'));
        },
        act: (bloc) => bloc.add(const SyncInitialize()),
        expect: () => [
          isA<SyncInitializing>(),
          isA<SyncError>(),
        ],
      );
    });

    group('SyncStartAutoSync', () {
      blocTest<SyncBloc, SyncState>(
        'starts auto sync and updates state',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.startAutoSync()).thenAnswer((_) async {});
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: false,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncStartAutoSync()),
        expect: () => [
          predicate<SyncState>((state) {
            return state is SyncIdle && state.autoSyncEnabled == true;
          }),
        ],
        verify: (_) {
          verify(() => mockSyncManager.startAutoSync()).called(1);
        },
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when start auto sync fails',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.startAutoSync()).thenThrow(Exception('Failed to start auto sync'));
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: false,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncStartAutoSync()),
        expect: () => [isA<SyncError>()],
      );
    });

    group('SyncStopAutoSync', () {
      blocTest<SyncBloc, SyncState>(
        'stops auto sync and updates state',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.stopAutoSync()).thenAnswer((_) async {});
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncStopAutoSync()),
        expect: () => [
          predicate<SyncState>((state) {
            return state is SyncIdle && state.autoSyncEnabled == false;
          }),
        ],
        verify: (_) {
          verify(() => mockSyncManager.stopAutoSync()).called(1);
        },
      );
    });

    group('SyncTriggerSync', () {
      blocTest<SyncBloc, SyncState>(
        'triggers sync when connected',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.syncNow()).thenAnswer((_) async {});
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncTriggerSync()),
        verify: (_) {
          verify(() => mockSyncManager.syncNow()).called(1);
        },
      );

      blocTest<SyncBloc, SyncState>(
        'emits paused state when not connected',
        build: () => syncBloc,
        seed: () => const SyncIdle(
          isConnected: false,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncTriggerSync()),
        expect: () => [isA<SyncPaused>()],
        verify: (_) {
          verifyNever(() => mockSyncManager.syncNow());
        },
      );
    });

    group('SyncQueueItem', () {
      blocTest<SyncBloc, SyncState>(
        'queues item successfully',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.queueForSync(any())).thenAnswer((_) async {});
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(SyncQueueItem(_createTestSyncItem())),
        expect: () => [isA<SyncSuccess>()],
        verify: (_) {
          verify(() => mockSyncManager.queueForSync(any())).called(1);
        },
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when queueing fails',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.queueForSync(any())).thenThrow(Exception('Queue failed'));
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(SyncQueueItem(_createTestSyncItem())),
        expect: () => [isA<SyncError>()],
      );
    });

    group('SyncRetryFailed', () {
      blocTest<SyncBloc, SyncState>(
        'retries failed items successfully',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.retryFailed()).thenAnswer((_) async {});
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 1, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncRetryFailed()),
        expect: () => [isA<SyncSuccess>()],
        verify: (_) {
          verify(() => mockSyncManager.retryFailed()).called(1);
        },
      );
    });

    group('SyncRetryItem', () {
      blocTest<SyncBloc, SyncState>(
        'retries specific item successfully',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.retrySyncItem(any())).thenAnswer((_) async => SyncResult.success());
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 1, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncRetryItem('item-1')),
        expect: () => [isA<SyncSuccess>()],
        verify: (_) {
          verify(() => mockSyncManager.retrySyncItem('item-1')).called(1);
        },
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when retry fails',
        build: () => syncBloc,
        setUp: () {
          when(() => mockSyncManager.retrySyncItem(any())).thenAnswer((_) async => SyncResult.failure('Retry failed'));
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 1, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncRetryItem('item-1')),
        expect: () => [isA<SyncError>()],
      );
    });

    group('SyncConnectivityChanged', () {
      blocTest<SyncBloc, SyncState>(
        'resumes from paused when connectivity restored',
        build: () => syncBloc,
        seed: () => const SyncPaused(
          isConnected: false,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
          reason: 'No connection',
        ),
        act: (bloc) => bloc.add(const SyncConnectivityChanged(true)),
        expect: () => [isA<SyncIdle>()],
      );

      blocTest<SyncBloc, SyncState>(
        'pauses when connectivity lost during sync',
        build: () => syncBloc,
        seed: () => const SyncInProgress(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 1, completed: 0, failed: 0, inProgress: 1),
        ),
        act: (bloc) => bloc.add(const SyncConnectivityChanged(false)),
        expect: () => [isA<SyncPaused>()],
      );
    });

    group('SyncStatusChanged', () {
      blocTest<SyncBloc, SyncState>(
        'transitions to syncing state',
        build: () => syncBloc,
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncStatusChanged(SyncStatus.syncing)),
        expect: () => [isA<SyncInProgress>()],
      );

      blocTest<SyncBloc, SyncState>(
        'transitions to error state',
        build: () => syncBloc,
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncStatusChanged(SyncStatus.error)),
        expect: () => [isA<SyncError>()],
      );
    });

    group('SyncProgressUpdated', () {
      blocTest<SyncBloc, SyncState>(
        'updates progress in current state',
        build: () => syncBloc,
        seed: () => const SyncInProgress(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 10, completed: 5, failed: 0, inProgress: 1),
        ),
        act: (bloc) => bloc.add(
          const SyncProgressUpdated(
            SyncProgress(total: 10, completed: 6, failed: 0, inProgress: 1),
          ),
        ),
        expect: () => [
          predicate<SyncState>((state) {
            return state is SyncInProgress && state.progress.completed == 6;
          }),
        ],
      );
    });
  });
}

// Helper function to create test sync items
SyncItem _createTestSyncItem({
  String? id,
  String? entityType,
  String? entityId,
}) {
  return SyncItem(
    id: id ?? 'test-sync-item',
    entityType: entityType ?? 'TestEntity',
    entityId: entityId ?? 'test-entity-1',
    data: const {'test': 'data'},
    createdAt: DateTime.now(),
    status: const UploadStatus(state: UploadState.pending),
    priority: SyncPriority.normal,
  );
}
