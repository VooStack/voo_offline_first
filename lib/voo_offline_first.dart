/// A Flutter package for offline-first functionality with clean architecture
library voo_offline_first;

// Core Interfaces
export 'src/core/interfaces/offline_repository.dart';
export 'src/core/interfaces/sync_manager.dart';
export 'src/core/interfaces/connectivity_service.dart';

// Models
export 'src/core/models/sync_item.dart';
export 'src/core/models/upload_status.dart';
export 'src/core/models/sync_result.dart';

// Annotations for Code Generation
export 'src/annotations/offline_entity.dart';
export 'src/annotations/sync_field.dart';

// Base Implementations
export 'src/repositories/base_offline_repository.dart';
export 'src/sync/sync_manager_impl.dart';
export 'src/connectivity/connectivity_service_impl.dart';

// Database - Export both the tables and the database class
export 'src/database/tables.dart';
export 'src/database/sync_database.dart' hide debugPrint;

// Bloc
export 'src/bloc/sync_bloc.dart';
export 'src/bloc/sync_state.dart';
export 'src/bloc/sync_event.dart';

// Widgets
export 'src/widgets/sync_status_widgets.dart';

// Exceptions
export 'src/core/exceptions/offline_exceptions.dart';

// Utils
export 'src/utils/sync_utils.dart';
export 'src/utils/retry_policy.dart';
