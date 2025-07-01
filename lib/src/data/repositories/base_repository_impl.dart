import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/base_entity.dart';
import '../../domain/repositories/base_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/base_model.dart';

/// Base implementation of repository with offline-first support
abstract class BaseRepositoryImpl<T extends BaseEntity, M extends BaseModel<T>> implements BaseRepository<T> {
  final LocalDataSource<T, M> localDataSource;
  final RemoteDataSource<T, M> remoteDataSource;
  final NetworkInfo networkInfo;

  const BaseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<List<T>> getAll() async {
    try {
      // Always get from local first
      final localModels = await localDataSource.getAll();
      final localEntities = localModels.map((m) => m.toEntity()).toList();

      // If online, fetch from remote and update local
      if (await networkInfo.isConnected) {
        try {
          final remoteModels = await remoteDataSource.fetchAll();
          await localDataSource.saveAll(remoteModels);
          return Right(remoteModels.map((m) => m.toEntity()).toList());
        } catch (e) {
          // If remote fails, return local data
          return Right(localEntities);
        }
      }

      return Right(localEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<T> getById(String id) async {
    try {
      // Check local first
      final localModel = await localDataSource.getById(id);

      if (localModel != null) {
        // If online, try to get fresh data
        if (await networkInfo.isConnected) {
          try {
            final remoteModel = await remoteDataSource.fetchById(id);
            await localDataSource.save(remoteModel);
            return Right(remoteModel.toEntity());
          } catch (e) {
            // If remote fails, return local
            return Right(localModel.toEntity());
          }
        }
        return Right(localModel.toEntity());
      }

      // Not in local, must fetch from remote
      if (await networkInfo.isConnected) {
        final remoteModel = await remoteDataSource.fetchById(id);
        await localDataSource.save(remoteModel);
        return Right(remoteModel.toEntity());
      } else {
        return const Left(NetworkFailure(
          message: 'No internet connection and item not in cache',
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Server error',
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<T> create(T entity) async {
    try {
      final model = entityToModel(entity);

      // Save to local first
      final savedModel = await localDataSource.save(model);

      // If online, sync to remote
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = await remoteDataSource.create(model.toJson());
          await localDataSource.update(remoteModel);
          return Right(remoteModel.toEntity());
        } catch (e) {
          // Mark for sync later
          return Right(savedModel.toEntity());
        }
      }

      return Right(savedModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Server error',
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<T> update(T entity) async {
    try {
      final model = entityToModel(entity);

      // Update local first
      final updatedModel = await localDataSource.update(model);

      // If online, sync to remote
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = await remoteDataSource.update(
            entity.id,
            model.toJson(),
          );
          await localDataSource.update(remoteModel);
          return Right(remoteModel.toEntity());
        } catch (e) {
          // Mark for sync later
          return Right(updatedModel.toEntity());
        }
      }

      return Right(updatedModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Server error',
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid delete(String id) async {
    try {
      // Mark as deleted in local
      final model = await localDataSource.getById(id);
      if (model != null) {
        // For syncable models, mark as deleted
        // For non-syncable, delete immediately
        await localDataSource.delete(id);
      }

      // If online, delete from remote
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.delete(id);
        } catch (e) {
          // Deletion will be synced later
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Server error',
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<bool> exists(String id) async {
    try {
      return Right(await localDataSource.exists(id));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<T>> getPaginated({
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final models = await localDataSource.getPaginated(
        offset: offset,
        limit: pageSize,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<T>> search(String query) async {
    try {
      final models = await localDataSource.search(query);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid clearAll() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Convert entity to model - must be implemented by concrete repositories
  M entityToModel(T entity);
}
