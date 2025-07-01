import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

// Mock classes
class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// Fake classes for fallback values
class FakeSyncItem extends Fake implements SyncItem {}

void main() {
  // Register fallback values
  setUpAll(() {
    registerFallbackValue(FakeSyncItem());
    registerFallbackValue(<SyncItem>[]);
  });

  group('SyncBloc', () {
    late SyncBloc syncBloc;
    late MockSyncManager mockSyncManager;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      mockSyncManager = MockSyncManager();
      mockConnectivityService = MockConnectivityService();

      // Clear any previous interactions but keep the mock setup
      clearInteractions(mockSyncManager);
      clearInteractions(mockConnectivityService);

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

    tearDown(() async {
      await syncBloc.close();
    });

    test('initial state is SyncInitial', () {
      expect(syncBloc.state, isA<SyncInitial>());
    });

    group('SyncInitialize', () {
      blocTest<SyncBloc, SyncState>(
        'emits [SyncInitializing, SyncIdle] when initialization succeeds',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          // Set up fresh mocks for this test only
          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        act: (bloc) => bloc.add(const SyncInitialize()),
        expect: () => [
          isA<SyncInitializing>(),
          isA<SyncIdle>(),
        ],
      );

      test('should dispose services when bloc is closed', () async {
        // Create fresh mocks for this test to avoid interference with tearDown
        final freshSyncManager = MockSyncManager();
        final freshConnectivityService = MockConnectivityService();

        // Track if dispose was called
        bool syncManagerDisposeCalled = false;
        bool connectivityServiceDisposeCalled = false;

        // Set up the fresh mocks
        when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
        when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
        when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
        when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
        when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
        when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
        when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
          (_) => Stream.value(
            const SyncProgress(
              total: 0,
              completed: 0,
              failed: 0,
              inProgress: 0,
            ),
          ),
        );
        when(() => freshSyncManager.dispose()).thenAnswer((_) async {
          syncManagerDisposeCalled = true;
        });
        when(() => freshConnectivityService.dispose()).thenAnswer((_) async {
          connectivityServiceDisposeCalled = true;
        });

        final testBloc = SyncBloc(
          syncManager: freshSyncManager,
          connectivityService: freshConnectivityService,
        );

        await testBloc.close();

        // Verify that dispose was called by checking our tracking variables
        expect(syncManagerDisposeCalled, true);
        expect(connectivityServiceDisposeCalled, true);
      });

      blocTest<SyncBloc, SyncState>(
        'emits [SyncInitializing, SyncError] when initialization fails',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenThrow(Exception('Initialization failed'));
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.startAutoSync()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when start auto sync fails',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.startAutoSync()).thenThrow(Exception('Failed to start auto sync'));

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.stopAutoSync()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
      );
    });

    group('SyncTriggerSync', () {
      blocTest<SyncBloc, SyncState>(
        'triggers sync when connected',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.syncNow()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncTriggerSync()),
      );

      blocTest<SyncBloc, SyncState>(
        'emits paused state when not connected',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => false);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(false));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        seed: () => const SyncIdle(
          isConnected: false,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncTriggerSync()),
        expect: () => [isA<SyncPaused>()],
      );
    });

    group('SyncQueueItem', () {
      blocTest<SyncBloc, SyncState>(
        'queues item successfully',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.queueForSync(any())).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        ),
        act: (bloc) => bloc.add(SyncQueueItem(_createTestSyncItem())),
        expect: () => [isA<SyncSuccess>()],
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when queueing fails',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.queueForSync(any())).thenThrow(Exception('Queue failed'));

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.retryFailed()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 1, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncRetryFailed()),
        expect: () => [isA<SyncSuccess>()],
      );
    });

    group('SyncRetryItem', () {
      blocTest<SyncBloc, SyncState>(
        'retries specific item successfully',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.retrySyncItem(any())).thenAnswer((_) async => SyncResult.success());

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
        seed: () => const SyncIdle(
          isConnected: true,
          autoSyncEnabled: true,
          syncQueue: [],
          progress: SyncProgress(total: 0, completed: 0, failed: 1, inProgress: 0),
        ),
        act: (bloc) => bloc.add(const SyncRetryItem('item-1')),
        expect: () => [isA<SyncSuccess>()],
      );

      blocTest<SyncBloc, SyncState>(
        'emits error when retry fails',
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});
          when(() => freshSyncManager.retrySyncItem(any())).thenAnswer((_) async => SyncResult.failure('Retry failed'));

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => false);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(false));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
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
        build: () {
          final freshSyncManager = MockSyncManager();
          final freshConnectivityService = MockConnectivityService();

          when(() => freshConnectivityService.initialize()).thenAnswer((_) async {});
          when(() => freshSyncManager.initialize()).thenAnswer((_) async {});
          when(() => freshConnectivityService.isConnected()).thenAnswer((_) async => true);
          when(() => freshSyncManager.getSyncQueue()).thenAnswer((_) async => []);
          when(() => freshConnectivityService.watchConnectivity()).thenAnswer((_) => Stream.value(true));
          when(() => freshSyncManager.watchSyncQueue()).thenAnswer((_) => Stream.value([]));
          when(() => freshSyncManager.watchSyncStatus()).thenAnswer((_) => Stream.value(SyncStatus.idle));
          when(() => freshSyncManager.watchSyncProgress()).thenAnswer(
            (_) => Stream.value(
              const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              ),
            ),
          );
          when(() => freshSyncManager.dispose()).thenAnswer((_) async {});
          when(() => freshConnectivityService.dispose()).thenAnswer((_) async {});

          return SyncBloc(
            syncManager: freshSyncManager,
            connectivityService: freshConnectivityService,
          );
        },
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
