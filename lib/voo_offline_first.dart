/// Offline First Package - A Flutter package for building offline-first applications
library voo_offline_first;

// Core exports
export 'src/core/database/drift_database.dart';
export 'src/core/database/database_config.dart';
export 'src/core/enums/sync_status.dart';
export 'src/core/error/exceptions.dart';
export 'src/core/error/failures.dart';
export 'src/core/network/network_info.dart';
export 'src/core/sync/sync_manager.dart';
export 'src/core/sync/sync_status.dart';

// Domain exports
export 'src/domain/entities/base_entity.dart';
export 'src/domain/entities/syncable_entity.dart';
export 'src/domain/repositories/base_repository.dart';
export 'src/domain/usecases/base_usecase.dart';

// Data exports
export 'src/data/models/base_model.dart';
export 'src/data/models/syncable_model.dart';
export 'src/data/datasources/local_datasource.dart';
export 'src/data/datasources/remote_datasource.dart';
export 'src/data/repositories/base_repository_impl.dart';

// Presentation exports
export 'src/presentation/widgets/offline_builder.dart';
export 'src/presentation/widgets/sync_indicator.dart';

// Utils
export 'src/core/utils/typedef.dart';
export 'src/core/utils/constants.dart';
