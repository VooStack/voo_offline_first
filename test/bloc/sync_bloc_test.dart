import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      when(() => mockConnectivityService.watchConnectivity())
          .thenAnswer((_) => Stream.value(true));
      when(() => mockSyncManager.watchSyncQueue())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockSyncManager.watchSyncStatus())
          .thenAnswer((_) => Stream.value(SyncStatus.idle));
      when(() => mockSyncManager.watchSyncProgress())
          .thenAnswer((_) => Stream.value(const SyncProgress(
                total: 0,
                completed: 0,
                failed: 0,
                inProgress: 0,
              )));
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
          when(() => mockSyncManager.initialize())
              .thenThrow(Exception('Initialization failed'));
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
          when(() => mockSyncManager.startAutoSync())
              .thenThrow(Exception('Failed to start auto sync'));
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