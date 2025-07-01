import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

// Mock classes
class MockSyncBloc extends Mock implements SyncBloc {}

void main() {
  group('SyncStatusIndicator', () {
    late MockSyncBloc mockSyncBloc;

    setUp(() {
      mockSyncBloc = MockSyncBloc();
    });

    Widget createWidget({SyncState? initialState}) {
      when(() => mockSyncBloc.state).thenReturn(
        initialState ??
            const SyncIdle(
              isConnected: true,
              autoSyncEnabled: true,
              syncQueue: [],
              progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
            ),
      );
      when(() => mockSyncBloc.stream).thenAnswer((_) => const Stream.empty());

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SyncBloc>.value(
            value: mockSyncBloc,
            child: const SyncStatusIndicator(),
          ),
        ),
      );
    }

    testWidgets('shows cloud done icon when connected and idle', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('shows cloud off icon when disconnected', (tester) async {
      const state = SyncIdle(
        isConnected: false,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows circular progress when syncing', (tester) async {
      const state = SyncInProgress(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 10, completed: 3, failed: 0, inProgress: 2),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error icon when in error state', (tester) async {
      const state = SyncError(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        error: 'Test error',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows pause icon when paused', (tester) async {
      const state = SyncPaused(
        isConnected: false,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        reason: 'No connection',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.pause_circle), findsOneWidget);
    });

    testWidgets('shows success icon when completed', (tester) async {
      const state = SyncSuccess(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 5, completed: 5, failed: 0, inProgress: 0),
        message: 'All synced',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays status text when showText is true', (tester) async {
      const state = SyncIdle(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<SyncBloc>.value(
              value: mockSyncBloc,
              child: const SyncStatusIndicator(showText: true),
            ),
          ),
        ),
      );

      when(() => mockSyncBloc.state).thenReturn(state);
      when(() => mockSyncBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pump();

      expect(find.text('All synced'), findsOneWidget);
    });

    testWidgets('hides text when showText is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<SyncBloc>.value(
              value: mockSyncBloc,
              child: const SyncStatusIndicator(showText: false),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });
  });

  group('ItemSyncStatus', () {
    testWidgets('shows pending status correctly', (tester) async {
      const status = UploadStatus(state: UploadState.pending);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemSyncStatus(status: status),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.text('Pending upload'), findsOneWidget);
    });

    testWidgets('shows uploading status with progress', (tester) async {
      const status = UploadStatus(
        state: UploadState.uploading,
        progress: 0.65,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemSyncStatus(status: status),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('shows completed status', (tester) async {
      const status = UploadStatus(state: UploadState.completed);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemSyncStatus(status: status),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.text('Uploaded'), findsOneWidget);
    });

    testWidgets('shows failed status with error message', (tester) async {
      const status = UploadStatus(
        state: UploadState.failed,
        error: 'Network timeout',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemSyncStatus(status: status),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Upload failed'), findsOneWidget);
      expect(find.text('Network timeout'), findsOneWidget);
    });

    testWidgets('shows compact status when compact is true', (tester) async {
      const status = UploadStatus(state: UploadState.completed);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemSyncStatus(status: status, compact: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.text('Uploaded'), findsNothing); // No text in compact mode
    });
  });

  group('OfflineBanner', () {
    late MockSyncBloc mockSyncBloc;

    setUp(() {
      mockSyncBloc = MockSyncBloc();
    });

    Widget createWidget({required bool isConnected}) {
      final state = SyncIdle(
        isConnected: isConnected,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: const SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
      );

      when(() => mockSyncBloc.state).thenReturn(state);
      when(() => mockSyncBloc.stream).thenAnswer((_) => const Stream.empty());

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SyncBloc>.value(
            value: mockSyncBloc,
            child: const OfflineBanner(),
          ),
        ),
      );
    }

    testWidgets('shows banner when offline', (tester) async {
      await tester.pumpWidget(createWidget(isConnected: false));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(
        find.text('You are offline. Changes will sync when connection is restored.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides banner when online', (tester) async {
      await tester.pumpWidget(createWidget(isConnected: true));

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('retry button triggers sync', (tester) async {
      await tester.pumpWidget(createWidget(isConnected: false));

      await tester.tap(find.text('Retry'));

      verify(() => mockSyncBloc.add(const SyncTriggerSync())).called(1);
    });
  });

  group('SyncFab', () {
    late MockSyncBloc mockSyncBloc;

    setUp(() {
      mockSyncBloc = MockSyncBloc();
    });

    Widget createWidget({SyncState? initialState}) {
      when(() => mockSyncBloc.state).thenReturn(
        initialState ??
            const SyncIdle(
              isConnected: true,
              autoSyncEnabled: true,
              syncQueue: [],
              progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
            ),
      );
      when(() => mockSyncBloc.stream).thenAnswer((_) => const Stream.empty());

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SyncBloc>.value(
            value: mockSyncBloc,
            child: const SyncFab(),
          ),
        ),
      );
    }

    testWidgets('shows sync icon in idle state', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows progress indicator when syncing', (tester) async {
      const state = SyncInProgress(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 10, completed: 3, failed: 0, inProgress: 2),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows error icon in error state', (tester) async {
      const state = SyncError(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        error: 'Test error',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    });

    testWidgets('shows check icon in success state', (tester) async {
      const state = SyncSuccess(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 5, completed: 5, failed: 0, inProgress: 0),
        message: 'All synced',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('triggers sync when tapped in idle state', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byType(FloatingActionButton));

      verify(() => mockSyncBloc.add(const SyncTriggerSync())).called(1);
    });

    testWidgets('triggers sync when tapped in paused state', (tester) async {
      const state = SyncPaused(
        isConnected: false,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
        reason: 'No connection',
      );

      await tester.pumpWidget(createWidget(initialState: state));

      await tester.tap(find.byType(FloatingActionButton));

      verify(() => mockSyncBloc.add(const SyncTriggerSync())).called(1);
    });

    testWidgets('does not trigger sync when tapped during sync', (tester) async {
      const state = SyncInProgress(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 10, completed: 3, failed: 0, inProgress: 2),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      await tester.tap(find.byType(FloatingActionButton));

      verifyNever(() => mockSyncBloc.add(const SyncTriggerSync()));
    });
  });

  group('SyncProgressCard', () {
    late MockSyncBloc mockSyncBloc;

    setUp(() {
      mockSyncBloc = MockSyncBloc();
    });

    Widget createWidget({SyncState? initialState}) {
      when(() => mockSyncBloc.state).thenReturn(
        initialState ??
            const SyncIdle(
              isConnected: true,
              autoSyncEnabled: true,
              syncQueue: [],
              progress: SyncProgress(total: 10, completed: 7, failed: 2, inProgress: 1),
            ),
      );
      when(() => mockSyncBloc.stream).thenAnswer((_) => const Stream.empty());

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SyncBloc>.value(
            value: mockSyncBloc,
            child: const SyncProgressCard(),
          ),
        ),
      );
    }

    testWidgets('displays connection status', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('displays offline status when disconnected', (tester) async {
      const state = SyncIdle(
        isConnected: false,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('displays progress information', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('7/10 completed'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
    });

    testWidgets('displays progress chips', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Pending: 0'), findsOneWidget);
      expect(find.text('In Progress: 1'), findsOneWidget);
      expect(find.text('Failed: 2'), findsOneWidget);
    });

    testWidgets('shows sync button in idle state', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows pause button during sync', (tester) async {
      const state = SyncInProgress(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 10, completed: 3, failed: 0, inProgress: 2),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('sync button triggers manual sync', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.sync));

      verify(() => mockSyncBloc.add(const SyncTriggerSync())).called(1);
    });

    testWidgets('displays no items message when queue is empty', (tester) async {
      const state = SyncIdle(
        isConnected: true,
        autoSyncEnabled: true,
        syncQueue: [],
        progress: SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0),
      );

      await tester.pumpWidget(createWidget(initialState: state));

      expect(find.text('No items to sync'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
