import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'models/sync_item_test.dart' as sync_item_test;
import 'models/upload_status_test.dart' as upload_status_test;
import 'utils/sync_utils_test.dart' as sync_utils_test;
import 'utils/retry_policy_test.dart' as retry_policy_test;
import 'bloc/sync_bloc_test.dart' as sync_bloc_test;
import 'widgets/sync_status_widgets_test.dart' as sync_widgets_test;
import 'integration/offline_sync_integration_test.dart' as integration_test;

void main() {
  group('Offline First Package Tests', () {
    group('Models', () {
      sync_item_test.main();
      upload_status_test.main();
    });

    group('Utils', () {
      sync_utils_test.main();
      retry_policy_test.main();
    });

    group('BLoC', () {
      sync_bloc_test.main();
    });

    group('Widgets', () {
      sync_widgets_test.main();
    });

    group('Integration', () {
      integration_test.main();
    });
  });
}
