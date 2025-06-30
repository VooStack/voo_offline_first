// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_database.dart';

// ignore_for_file: type=lint
class $SyncItemsTable extends SyncItems
    with TableInfo<$SyncItemsTable, SyncItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endpointMeta =
      const VerificationMeta('endpoint');
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
      'endpoint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dependenciesMeta =
      const VerificationMeta('dependencies');
  @override
  late final GeneratedColumn<String> dependencies = GeneratedColumn<String>(
      'dependencies', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        data,
        createdAt,
        status,
        priority,
        endpoint,
        lastAttemptAt,
        dependencies
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_items';
  @override
  VerificationContext validateIntegrity(Insertable<SyncItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(_endpointMeta,
          endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('dependencies')) {
      context.handle(
          _dependenciesMeta,
          dependencies.isAcceptableOrUnknown(
              data['dependencies']!, _dependenciesMeta));
    } else if (isInserting) {
      context.missing(_dependenciesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      endpoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endpoint']),
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
      dependencies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dependencies'])!,
    );
  }

  @override
  $SyncItemsTable createAlias(String alias) {
    return $SyncItemsTable(attachedDatabase, alias);
  }
}

class SyncItemData extends DataClass implements Insertable<SyncItemData> {
  final String id;
  final String entityType;
  final String entityId;
  final String data;
  final DateTime createdAt;
  final String status;
  final int priority;
  final String? endpoint;
  final DateTime? lastAttemptAt;
  final String dependencies;
  const SyncItemData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.data,
      required this.createdAt,
      required this.status,
      required this.priority,
      this.endpoint,
      this.lastAttemptAt,
      required this.dependencies});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || endpoint != null) {
      map['endpoint'] = Variable<String>(endpoint);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['dependencies'] = Variable<String>(dependencies);
    return map;
  }

  SyncItemDataCompanion toCompanion(bool nullToAbsent) {
    return SyncItemDataCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      data: Value(data),
      createdAt: Value(createdAt),
      status: Value(status),
      priority: Value(priority),
      endpoint: endpoint == null && nullToAbsent
          ? const Value.absent()
          : Value(endpoint),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      dependencies: Value(dependencies),
    );
  }

  factory SyncItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncItemData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      endpoint: serializer.fromJson<String?>(json['endpoint']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      dependencies: serializer.fromJson<String>(json['dependencies']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'endpoint': serializer.toJson<String?>(endpoint),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'dependencies': serializer.toJson<String>(dependencies),
    };
  }

  SyncItemData copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? data,
          DateTime? createdAt,
          String? status,
          int? priority,
          Value<String?> endpoint = const Value.absent(),
          Value<DateTime?> lastAttemptAt = const Value.absent(),
          String? dependencies}) =>
      SyncItemData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        data: data ?? this.data,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        endpoint: endpoint.present ? endpoint.value : this.endpoint,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        dependencies: dependencies ?? this.dependencies,
      );
  SyncItemData copyWithCompanion(SyncItemDataCompanion data) {
    return SyncItemData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      dependencies: data.dependencies.present
          ? data.dependencies.value
          : this.dependencies,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncItemData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('endpoint: $endpoint, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('dependencies: $dependencies')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, data, createdAt,
      status, priority, endpoint, lastAttemptAt, dependencies);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncItemData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.endpoint == this.endpoint &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.dependencies == this.dependencies);
}

class SyncItemDataCompanion extends UpdateCompanion<SyncItemData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<int> priority;
  final Value<String?> endpoint;
  final Value<DateTime?> lastAttemptAt;
  final Value<String> dependencies;
  final Value<int> rowid;
  const SyncItemDataCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.dependencies = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncItemDataCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String data,
    required DateTime createdAt,
    required String status,
    required int priority,
    this.endpoint = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required String dependencies,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        data = Value(data),
        createdAt = Value(createdAt),
        status = Value(status),
        priority = Value(priority),
        dependencies = Value(dependencies);
  static Insertable<SyncItemData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<String>? endpoint,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? dependencies,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (endpoint != null) 'endpoint': endpoint,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (dependencies != null) 'dependencies': dependencies,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncItemDataCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? data,
      Value<DateTime>? createdAt,
      Value<String>? status,
      Value<int>? priority,
      Value<String?>? endpoint,
      Value<DateTime?>? lastAttemptAt,
      Value<String>? dependencies,
      Value<int>? rowid}) {
    return SyncItemDataCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      endpoint: endpoint ?? this.endpoint,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      dependencies: dependencies ?? this.dependencies,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (dependencies.present) {
      map['dependencies'] = Variable<String>(dependencies.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncItemDataCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('endpoint: $endpoint, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('dependencies: $dependencies, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityMetadataTableTable extends EntityMetadataTable
    with TableInfo<$EntityMetadataTableTable, EntityMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        createdAt,
        updatedAt,
        lastSyncedAt,
        needsSync,
        syncStatus,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<EntityMetadata> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityMetadata(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $EntityMetadataTableTable createAlias(String alias) {
    return $EntityMetadataTableTable(attachedDatabase, alias);
  }
}

class EntityMetadata extends DataClass implements Insertable<EntityMetadata> {
  final String id;
  final String entityType;
  final String entityId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  final String syncStatus;
  final int version;
  const EntityMetadata(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.createdAt,
      required this.updatedAt,
      this.lastSyncedAt,
      required this.needsSync,
      required this.syncStatus,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    map['sync_status'] = Variable<String>(syncStatus);
    map['version'] = Variable<int>(version);
    return map;
  }

  EntityMetadataCompanion toCompanion(bool nullToAbsent) {
    return EntityMetadataCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
      syncStatus: Value(syncStatus),
      version: Value(version),
    );
  }

  factory EntityMetadata.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityMetadata(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'version': serializer.toJson<int>(version),
    };
  }

  EntityMetadata copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? needsSync,
          String? syncStatus,
          int? version}) =>
      EntityMetadata(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        needsSync: needsSync ?? this.needsSync,
        syncStatus: syncStatus ?? this.syncStatus,
        version: version ?? this.version,
      );
  EntityMetadata copyWithCompanion(EntityMetadataCompanion data) {
    return EntityMetadata(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityMetadata(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, createdAt,
      updatedAt, lastSyncedAt, needsSync, syncStatus, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityMetadata &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync &&
          other.syncStatus == this.syncStatus &&
          other.version == this.version);
}

class EntityMetadataCompanion extends UpdateCompanion<EntityMetadata> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  final Value<String> syncStatus;
  final Value<int> version;
  final Value<int> rowid;
  const EntityMetadataCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityMetadataCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EntityMetadata> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
    Expression<String>? syncStatus,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityMetadataCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? needsSync,
      Value<String>? syncStatus,
      Value<int>? version,
      Value<int>? rowid}) {
    return EntityMetadataCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityMetadataCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileSyncItemsTable extends FileSyncItems
    with TableInfo<$FileSyncItemsTable, FileSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileSyncItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _uploadStatusMeta =
      const VerificationMeta('uploadStatus');
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
      'upload_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRequiredMeta =
      const VerificationMeta('isRequired');
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
      'is_required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_required" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityId,
        entityType,
        filePath,
        fileName,
        mimeType,
        fileSize,
        checksum,
        createdAt,
        uploadStatus,
        remoteUrl,
        isRequired
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_sync_items';
  @override
  VerificationContext validateIntegrity(Insertable<FileSyncData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('upload_status')) {
      context.handle(
          _uploadStatusMeta,
          uploadStatus.isAcceptableOrUnknown(
              data['upload_status']!, _uploadStatusMeta));
    } else if (isInserting) {
      context.missing(_uploadStatusMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('is_required')) {
      context.handle(
          _isRequiredMeta,
          isRequired.isAcceptableOrUnknown(
              data['is_required']!, _isRequiredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileSyncData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      uploadStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      isRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_required'])!,
    );
  }

  @override
  $FileSyncItemsTable createAlias(String alias) {
    return $FileSyncItemsTable(attachedDatabase, alias);
  }
}

class FileSyncData extends DataClass implements Insertable<FileSyncData> {
  final String id;
  final String entityId;
  final String entityType;
  final String filePath;
  final String fileName;
  final String? mimeType;
  final int? fileSize;
  final String? checksum;
  final DateTime createdAt;
  final String uploadStatus;
  final String? remoteUrl;
  final bool isRequired;
  const FileSyncData(
      {required this.id,
      required this.entityId,
      required this.entityType,
      required this.filePath,
      required this.fileName,
      this.mimeType,
      this.fileSize,
      this.checksum,
      required this.createdAt,
      required this.uploadStatus,
      this.remoteUrl,
      required this.isRequired});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['file_path'] = Variable<String>(filePath);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['upload_status'] = Variable<String>(uploadStatus);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['is_required'] = Variable<bool>(isRequired);
    return map;
  }

  FileSyncDataCompanion toCompanion(bool nullToAbsent) {
    return FileSyncDataCompanion(
      id: Value(id),
      entityId: Value(entityId),
      entityType: Value(entityType),
      filePath: Value(filePath),
      fileName: Value(fileName),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      createdAt: Value(createdAt),
      uploadStatus: Value(uploadStatus),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      isRequired: Value(isRequired),
    );
  }

  factory FileSyncData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileSyncData(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'filePath': serializer.toJson<String>(filePath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'checksum': serializer.toJson<String?>(checksum),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'isRequired': serializer.toJson<bool>(isRequired),
    };
  }

  FileSyncData copyWith(
          {String? id,
          String? entityId,
          String? entityType,
          String? filePath,
          String? fileName,
          Value<String?> mimeType = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          Value<String?> checksum = const Value.absent(),
          DateTime? createdAt,
          String? uploadStatus,
          Value<String?> remoteUrl = const Value.absent(),
          bool? isRequired}) =>
      FileSyncData(
        id: id ?? this.id,
        entityId: entityId ?? this.entityId,
        entityType: entityType ?? this.entityType,
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        checksum: checksum.present ? checksum.value : this.checksum,
        createdAt: createdAt ?? this.createdAt,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        isRequired: isRequired ?? this.isRequired,
      );
  FileSyncData copyWithCompanion(FileSyncDataCompanion data) {
    return FileSyncData(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      isRequired:
          data.isRequired.present ? data.isRequired.value : this.isRequired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileSyncData(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('isRequired: $isRequired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityId,
      entityType,
      filePath,
      fileName,
      mimeType,
      fileSize,
      checksum,
      createdAt,
      uploadStatus,
      remoteUrl,
      isRequired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileSyncData &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.checksum == this.checksum &&
          other.createdAt == this.createdAt &&
          other.uploadStatus == this.uploadStatus &&
          other.remoteUrl == this.remoteUrl &&
          other.isRequired == this.isRequired);
}

class FileSyncDataCompanion extends UpdateCompanion<FileSyncData> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<String> filePath;
  final Value<String> fileName;
  final Value<String?> mimeType;
  final Value<int?> fileSize;
  final Value<String?> checksum;
  final Value<DateTime> createdAt;
  final Value<String> uploadStatus;
  final Value<String?> remoteUrl;
  final Value<bool> isRequired;
  final Value<int> rowid;
  const FileSyncDataCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileSyncDataCompanion.insert({
    required String id,
    required String entityId,
    required String entityType,
    required String filePath,
    required String fileName,
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    required DateTime createdAt,
    required String uploadStatus,
    this.remoteUrl = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityId = Value(entityId),
        entityType = Value(entityType),
        filePath = Value(filePath),
        fileName = Value(fileName),
        createdAt = Value(createdAt),
        uploadStatus = Value(uploadStatus);
  static Insertable<FileSyncData> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? checksum,
    Expression<DateTime>? createdAt,
    Expression<String>? uploadStatus,
    Expression<String>? remoteUrl,
    Expression<bool>? isRequired,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (checksum != null) 'checksum': checksum,
      if (createdAt != null) 'created_at': createdAt,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (isRequired != null) 'is_required': isRequired,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileSyncDataCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityId,
      Value<String>? entityType,
      Value<String>? filePath,
      Value<String>? fileName,
      Value<String?>? mimeType,
      Value<int?>? fileSize,
      Value<String?>? checksum,
      Value<DateTime>? createdAt,
      Value<String>? uploadStatus,
      Value<String?>? remoteUrl,
      Value<bool>? isRequired,
      Value<int>? rowid}) {
    return FileSyncDataCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      isRequired: isRequired ?? this.isRequired,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileSyncDataCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('isRequired: $isRequired, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConfigsTable extends SyncConfigs
    with TableInfo<$SyncConfigsTable, SyncConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endpointMeta =
      const VerificationMeta('endpoint');
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
      'endpoint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoSyncMeta =
      const VerificationMeta('autoSync');
  @override
  late final GeneratedColumn<bool> autoSync = GeneratedColumn<bool>(
      'auto_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("auto_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _retryDelaySecondsMeta =
      const VerificationMeta('retryDelaySeconds');
  @override
  late final GeneratedColumn<int> retryDelaySeconds = GeneratedColumn<int>(
      'retry_delay_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(300));
  static const VerificationMeta _batchSizeMeta =
      const VerificationMeta('batchSize');
  @override
  late final GeneratedColumn<int> batchSize = GeneratedColumn<int>(
      'batch_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _syncFieldsMeta =
      const VerificationMeta('syncFields');
  @override
  late final GeneratedColumn<String> syncFields = GeneratedColumn<String>(
      'sync_fields', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        entityType,
        endpoint,
        autoSync,
        maxRetries,
        retryDelaySeconds,
        batchSize,
        syncFields,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_configs';
  @override
  VerificationContext validateIntegrity(Insertable<SyncConfigData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(_endpointMeta,
          endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta));
    }
    if (data.containsKey('auto_sync')) {
      context.handle(_autoSyncMeta,
          autoSync.isAcceptableOrUnknown(data['auto_sync']!, _autoSyncMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('retry_delay_seconds')) {
      context.handle(
          _retryDelaySecondsMeta,
          retryDelaySeconds.isAcceptableOrUnknown(
              data['retry_delay_seconds']!, _retryDelaySecondsMeta));
    }
    if (data.containsKey('batch_size')) {
      context.handle(_batchSizeMeta,
          batchSize.isAcceptableOrUnknown(data['batch_size']!, _batchSizeMeta));
    }
    if (data.containsKey('sync_fields')) {
      context.handle(
          _syncFieldsMeta,
          syncFields.isAcceptableOrUnknown(
              data['sync_fields']!, _syncFieldsMeta));
    } else if (isInserting) {
      context.missing(_syncFieldsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConfigData(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      endpoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endpoint']),
      autoSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_sync'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      retryDelaySeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}retry_delay_seconds'])!,
      batchSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}batch_size'])!,
      syncFields: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_fields'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncConfigsTable createAlias(String alias) {
    return $SyncConfigsTable(attachedDatabase, alias);
  }
}

class SyncConfigData extends DataClass implements Insertable<SyncConfigData> {
  final String entityType;
  final String? endpoint;
  final bool autoSync;
  final int maxRetries;
  final int retryDelaySeconds;
  final int batchSize;
  final String syncFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncConfigData(
      {required this.entityType,
      this.endpoint,
      required this.autoSync,
      required this.maxRetries,
      required this.retryDelaySeconds,
      required this.batchSize,
      required this.syncFields,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || endpoint != null) {
      map['endpoint'] = Variable<String>(endpoint);
    }
    map['auto_sync'] = Variable<bool>(autoSync);
    map['max_retries'] = Variable<int>(maxRetries);
    map['retry_delay_seconds'] = Variable<int>(retryDelaySeconds);
    map['batch_size'] = Variable<int>(batchSize);
    map['sync_fields'] = Variable<String>(syncFields);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncConfigDataCompanion toCompanion(bool nullToAbsent) {
    return SyncConfigDataCompanion(
      entityType: Value(entityType),
      endpoint: endpoint == null && nullToAbsent
          ? const Value.absent()
          : Value(endpoint),
      autoSync: Value(autoSync),
      maxRetries: Value(maxRetries),
      retryDelaySeconds: Value(retryDelaySeconds),
      batchSize: Value(batchSize),
      syncFields: Value(syncFields),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncConfigData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConfigData(
      entityType: serializer.fromJson<String>(json['entityType']),
      endpoint: serializer.fromJson<String?>(json['endpoint']),
      autoSync: serializer.fromJson<bool>(json['autoSync']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      retryDelaySeconds: serializer.fromJson<int>(json['retryDelaySeconds']),
      batchSize: serializer.fromJson<int>(json['batchSize']),
      syncFields: serializer.fromJson<String>(json['syncFields']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'endpoint': serializer.toJson<String?>(endpoint),
      'autoSync': serializer.toJson<bool>(autoSync),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'retryDelaySeconds': serializer.toJson<int>(retryDelaySeconds),
      'batchSize': serializer.toJson<int>(batchSize),
      'syncFields': serializer.toJson<String>(syncFields),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncConfigData copyWith(
          {String? entityType,
          Value<String?> endpoint = const Value.absent(),
          bool? autoSync,
          int? maxRetries,
          int? retryDelaySeconds,
          int? batchSize,
          String? syncFields,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SyncConfigData(
        entityType: entityType ?? this.entityType,
        endpoint: endpoint.present ? endpoint.value : this.endpoint,
        autoSync: autoSync ?? this.autoSync,
        maxRetries: maxRetries ?? this.maxRetries,
        retryDelaySeconds: retryDelaySeconds ?? this.retryDelaySeconds,
        batchSize: batchSize ?? this.batchSize,
        syncFields: syncFields ?? this.syncFields,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncConfigData copyWithCompanion(SyncConfigDataCompanion data) {
    return SyncConfigData(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      autoSync: data.autoSync.present ? data.autoSync.value : this.autoSync,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      retryDelaySeconds: data.retryDelaySeconds.present
          ? data.retryDelaySeconds.value
          : this.retryDelaySeconds,
      batchSize: data.batchSize.present ? data.batchSize.value : this.batchSize,
      syncFields:
          data.syncFields.present ? data.syncFields.value : this.syncFields,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConfigData(')
          ..write('entityType: $entityType, ')
          ..write('endpoint: $endpoint, ')
          ..write('autoSync: $autoSync, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('retryDelaySeconds: $retryDelaySeconds, ')
          ..write('batchSize: $batchSize, ')
          ..write('syncFields: $syncFields, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, endpoint, autoSync, maxRetries,
      retryDelaySeconds, batchSize, syncFields, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConfigData &&
          other.entityType == this.entityType &&
          other.endpoint == this.endpoint &&
          other.autoSync == this.autoSync &&
          other.maxRetries == this.maxRetries &&
          other.retryDelaySeconds == this.retryDelaySeconds &&
          other.batchSize == this.batchSize &&
          other.syncFields == this.syncFields &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncConfigDataCompanion extends UpdateCompanion<SyncConfigData> {
  final Value<String> entityType;
  final Value<String?> endpoint;
  final Value<bool> autoSync;
  final Value<int> maxRetries;
  final Value<int> retryDelaySeconds;
  final Value<int> batchSize;
  final Value<String> syncFields;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncConfigDataCompanion({
    this.entityType = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.autoSync = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.retryDelaySeconds = const Value.absent(),
    this.batchSize = const Value.absent(),
    this.syncFields = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConfigDataCompanion.insert({
    required String entityType,
    this.endpoint = const Value.absent(),
    this.autoSync = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.retryDelaySeconds = const Value.absent(),
    this.batchSize = const Value.absent(),
    required String syncFields,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : entityType = Value(entityType),
        syncFields = Value(syncFields),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncConfigData> custom({
    Expression<String>? entityType,
    Expression<String>? endpoint,
    Expression<bool>? autoSync,
    Expression<int>? maxRetries,
    Expression<int>? retryDelaySeconds,
    Expression<int>? batchSize,
    Expression<String>? syncFields,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (endpoint != null) 'endpoint': endpoint,
      if (autoSync != null) 'auto_sync': autoSync,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (retryDelaySeconds != null) 'retry_delay_seconds': retryDelaySeconds,
      if (batchSize != null) 'batch_size': batchSize,
      if (syncFields != null) 'sync_fields': syncFields,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConfigDataCompanion copyWith(
      {Value<String>? entityType,
      Value<String?>? endpoint,
      Value<bool>? autoSync,
      Value<int>? maxRetries,
      Value<int>? retryDelaySeconds,
      Value<int>? batchSize,
      Value<String>? syncFields,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SyncConfigDataCompanion(
      entityType: entityType ?? this.entityType,
      endpoint: endpoint ?? this.endpoint,
      autoSync: autoSync ?? this.autoSync,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelaySeconds: retryDelaySeconds ?? this.retryDelaySeconds,
      batchSize: batchSize ?? this.batchSize,
      syncFields: syncFields ?? this.syncFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (autoSync.present) {
      map['auto_sync'] = Variable<bool>(autoSync.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (retryDelaySeconds.present) {
      map['retry_delay_seconds'] = Variable<int>(retryDelaySeconds.value);
    }
    if (batchSize.present) {
      map['batch_size'] = Variable<int>(batchSize.value);
    }
    if (syncFields.present) {
      map['sync_fields'] = Variable<String>(syncFields.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConfigDataCompanion(')
          ..write('entityType: $entityType, ')
          ..write('endpoint: $endpoint, ')
          ..write('autoSync: $autoSync, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('retryDelaySeconds: $retryDelaySeconds, ')
          ..write('batchSize: $batchSize, ')
          ..write('syncFields: $syncFields, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SyncDatabase extends GeneratedDatabase {
  _$SyncDatabase(QueryExecutor e) : super(e);
  $SyncDatabaseManager get managers => $SyncDatabaseManager(this);
  late final $SyncItemsTable syncItems = $SyncItemsTable(this);
  late final $EntityMetadataTableTable entityMetadataTable =
      $EntityMetadataTableTable(this);
  late final $FileSyncItemsTable fileSyncItems = $FileSyncItemsTable(this);
  late final $SyncConfigsTable syncConfigs = $SyncConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [syncItems, entityMetadataTable, fileSyncItems, syncConfigs];
}

typedef $$SyncItemsTableCreateCompanionBuilder = SyncItemDataCompanion
    Function({
  required String id,
  required String entityType,
  required String entityId,
  required String data,
  required DateTime createdAt,
  required String status,
  required int priority,
  Value<String?> endpoint,
  Value<DateTime?> lastAttemptAt,
  required String dependencies,
  Value<int> rowid,
});
typedef $$SyncItemsTableUpdateCompanionBuilder = SyncItemDataCompanion
    Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> data,
  Value<DateTime> createdAt,
  Value<String> status,
  Value<int> priority,
  Value<String?> endpoint,
  Value<DateTime?> lastAttemptAt,
  Value<String> dependencies,
  Value<int> rowid,
});

class $$SyncItemsTableFilterComposer
    extends Composer<_$SyncDatabase, $SyncItemsTable> {
  $$SyncItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependencies => $composableBuilder(
      column: $table.dependencies, builder: (column) => ColumnFilters(column));
}

class $$SyncItemsTableOrderingComposer
    extends Composer<_$SyncDatabase, $SyncItemsTable> {
  $$SyncItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependencies => $composableBuilder(
      column: $table.dependencies,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncItemsTableAnnotationComposer
    extends Composer<_$SyncDatabase, $SyncItemsTable> {
  $$SyncItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get dependencies => $composableBuilder(
      column: $table.dependencies, builder: (column) => column);
}

class $$SyncItemsTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $SyncItemsTable,
    SyncItemData,
    $$SyncItemsTableFilterComposer,
    $$SyncItemsTableOrderingComposer,
    $$SyncItemsTableAnnotationComposer,
    $$SyncItemsTableCreateCompanionBuilder,
    $$SyncItemsTableUpdateCompanionBuilder,
    (
      SyncItemData,
      BaseReferences<_$SyncDatabase, $SyncItemsTable, SyncItemData>
    ),
    SyncItemData,
    PrefetchHooks Function()> {
  $$SyncItemsTableTableManager(_$SyncDatabase db, $SyncItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String?> endpoint = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<String> dependencies = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncItemDataCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            data: data,
            createdAt: createdAt,
            status: status,
            priority: priority,
            endpoint: endpoint,
            lastAttemptAt: lastAttemptAt,
            dependencies: dependencies,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String data,
            required DateTime createdAt,
            required String status,
            required int priority,
            Value<String?> endpoint = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            required String dependencies,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncItemDataCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            data: data,
            createdAt: createdAt,
            status: status,
            priority: priority,
            endpoint: endpoint,
            lastAttemptAt: lastAttemptAt,
            dependencies: dependencies,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncItemsTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $SyncItemsTable,
    SyncItemData,
    $$SyncItemsTableFilterComposer,
    $$SyncItemsTableOrderingComposer,
    $$SyncItemsTableAnnotationComposer,
    $$SyncItemsTableCreateCompanionBuilder,
    $$SyncItemsTableUpdateCompanionBuilder,
    (
      SyncItemData,
      BaseReferences<_$SyncDatabase, $SyncItemsTable, SyncItemData>
    ),
    SyncItemData,
    PrefetchHooks Function()>;
typedef $$EntityMetadataTableTableCreateCompanionBuilder
    = EntityMetadataCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> needsSync,
  Value<String> syncStatus,
  Value<int> version,
  Value<int> rowid,
});
typedef $$EntityMetadataTableTableUpdateCompanionBuilder
    = EntityMetadataCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> needsSync,
  Value<String> syncStatus,
  Value<int> version,
  Value<int> rowid,
});

class $$EntityMetadataTableTableFilterComposer
    extends Composer<_$SyncDatabase, $EntityMetadataTableTable> {
  $$EntityMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$EntityMetadataTableTableOrderingComposer
    extends Composer<_$SyncDatabase, $EntityMetadataTableTable> {
  $$EntityMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$EntityMetadataTableTableAnnotationComposer
    extends Composer<_$SyncDatabase, $EntityMetadataTableTable> {
  $$EntityMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$EntityMetadataTableTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $EntityMetadataTableTable,
    EntityMetadata,
    $$EntityMetadataTableTableFilterComposer,
    $$EntityMetadataTableTableOrderingComposer,
    $$EntityMetadataTableTableAnnotationComposer,
    $$EntityMetadataTableTableCreateCompanionBuilder,
    $$EntityMetadataTableTableUpdateCompanionBuilder,
    (
      EntityMetadata,
      BaseReferences<_$SyncDatabase, $EntityMetadataTableTable, EntityMetadata>
    ),
    EntityMetadata,
    PrefetchHooks Function()> {
  $$EntityMetadataTableTableTableManager(
      _$SyncDatabase db, $EntityMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityMetadataTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntityMetadataCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            needsSync: needsSync,
            syncStatus: syncStatus,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntityMetadataCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            needsSync: needsSync,
            syncStatus: syncStatus,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntityMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $EntityMetadataTableTable,
    EntityMetadata,
    $$EntityMetadataTableTableFilterComposer,
    $$EntityMetadataTableTableOrderingComposer,
    $$EntityMetadataTableTableAnnotationComposer,
    $$EntityMetadataTableTableCreateCompanionBuilder,
    $$EntityMetadataTableTableUpdateCompanionBuilder,
    (
      EntityMetadata,
      BaseReferences<_$SyncDatabase, $EntityMetadataTableTable, EntityMetadata>
    ),
    EntityMetadata,
    PrefetchHooks Function()>;
typedef $$FileSyncItemsTableCreateCompanionBuilder = FileSyncDataCompanion
    Function({
  required String id,
  required String entityId,
  required String entityType,
  required String filePath,
  required String fileName,
  Value<String?> mimeType,
  Value<int?> fileSize,
  Value<String?> checksum,
  required DateTime createdAt,
  required String uploadStatus,
  Value<String?> remoteUrl,
  Value<bool> isRequired,
  Value<int> rowid,
});
typedef $$FileSyncItemsTableUpdateCompanionBuilder = FileSyncDataCompanion
    Function({
  Value<String> id,
  Value<String> entityId,
  Value<String> entityType,
  Value<String> filePath,
  Value<String> fileName,
  Value<String?> mimeType,
  Value<int?> fileSize,
  Value<String?> checksum,
  Value<DateTime> createdAt,
  Value<String> uploadStatus,
  Value<String?> remoteUrl,
  Value<bool> isRequired,
  Value<int> rowid,
});

class $$FileSyncItemsTableFilterComposer
    extends Composer<_$SyncDatabase, $FileSyncItemsTable> {
  $$FileSyncItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnFilters(column));
}

class $$FileSyncItemsTableOrderingComposer
    extends Composer<_$SyncDatabase, $FileSyncItemsTable> {
  $$FileSyncItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnOrderings(column));
}

class $$FileSyncItemsTableAnnotationComposer
    extends Composer<_$SyncDatabase, $FileSyncItemsTable> {
  $$FileSyncItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => column);
}

class $$FileSyncItemsTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $FileSyncItemsTable,
    FileSyncData,
    $$FileSyncItemsTableFilterComposer,
    $$FileSyncItemsTableOrderingComposer,
    $$FileSyncItemsTableAnnotationComposer,
    $$FileSyncItemsTableCreateCompanionBuilder,
    $$FileSyncItemsTableUpdateCompanionBuilder,
    (
      FileSyncData,
      BaseReferences<_$SyncDatabase, $FileSyncItemsTable, FileSyncData>
    ),
    FileSyncData,
    PrefetchHooks Function()> {
  $$FileSyncItemsTableTableManager(_$SyncDatabase db, $FileSyncItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileSyncItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileSyncItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileSyncItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileSyncDataCompanion(
            id: id,
            entityId: entityId,
            entityType: entityType,
            filePath: filePath,
            fileName: fileName,
            mimeType: mimeType,
            fileSize: fileSize,
            checksum: checksum,
            createdAt: createdAt,
            uploadStatus: uploadStatus,
            remoteUrl: remoteUrl,
            isRequired: isRequired,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityId,
            required String entityType,
            required String filePath,
            required String fileName,
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            required DateTime createdAt,
            required String uploadStatus,
            Value<String?> remoteUrl = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileSyncDataCompanion.insert(
            id: id,
            entityId: entityId,
            entityType: entityType,
            filePath: filePath,
            fileName: fileName,
            mimeType: mimeType,
            fileSize: fileSize,
            checksum: checksum,
            createdAt: createdAt,
            uploadStatus: uploadStatus,
            remoteUrl: remoteUrl,
            isRequired: isRequired,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FileSyncItemsTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $FileSyncItemsTable,
    FileSyncData,
    $$FileSyncItemsTableFilterComposer,
    $$FileSyncItemsTableOrderingComposer,
    $$FileSyncItemsTableAnnotationComposer,
    $$FileSyncItemsTableCreateCompanionBuilder,
    $$FileSyncItemsTableUpdateCompanionBuilder,
    (
      FileSyncData,
      BaseReferences<_$SyncDatabase, $FileSyncItemsTable, FileSyncData>
    ),
    FileSyncData,
    PrefetchHooks Function()>;
typedef $$SyncConfigsTableCreateCompanionBuilder = SyncConfigDataCompanion
    Function({
  required String entityType,
  Value<String?> endpoint,
  Value<bool> autoSync,
  Value<int> maxRetries,
  Value<int> retryDelaySeconds,
  Value<int> batchSize,
  required String syncFields,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SyncConfigsTableUpdateCompanionBuilder = SyncConfigDataCompanion
    Function({
  Value<String> entityType,
  Value<String?> endpoint,
  Value<bool> autoSync,
  Value<int> maxRetries,
  Value<int> retryDelaySeconds,
  Value<int> batchSize,
  Value<String> syncFields,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SyncConfigsTableFilterComposer
    extends Composer<_$SyncDatabase, $SyncConfigsTable> {
  $$SyncConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoSync => $composableBuilder(
      column: $table.autoSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryDelaySeconds => $composableBuilder(
      column: $table.retryDelaySeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batchSize => $composableBuilder(
      column: $table.batchSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncFields => $composableBuilder(
      column: $table.syncFields, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncConfigsTableOrderingComposer
    extends Composer<_$SyncDatabase, $SyncConfigsTable> {
  $$SyncConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoSync => $composableBuilder(
      column: $table.autoSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryDelaySeconds => $composableBuilder(
      column: $table.retryDelaySeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batchSize => $composableBuilder(
      column: $table.batchSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncFields => $composableBuilder(
      column: $table.syncFields, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncConfigsTableAnnotationComposer
    extends Composer<_$SyncDatabase, $SyncConfigsTable> {
  $$SyncConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<bool> get autoSync =>
      $composableBuilder(column: $table.autoSync, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<int> get retryDelaySeconds => $composableBuilder(
      column: $table.retryDelaySeconds, builder: (column) => column);

  GeneratedColumn<int> get batchSize =>
      $composableBuilder(column: $table.batchSize, builder: (column) => column);

  GeneratedColumn<String> get syncFields => $composableBuilder(
      column: $table.syncFields, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncConfigsTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $SyncConfigsTable,
    SyncConfigData,
    $$SyncConfigsTableFilterComposer,
    $$SyncConfigsTableOrderingComposer,
    $$SyncConfigsTableAnnotationComposer,
    $$SyncConfigsTableCreateCompanionBuilder,
    $$SyncConfigsTableUpdateCompanionBuilder,
    (
      SyncConfigData,
      BaseReferences<_$SyncDatabase, $SyncConfigsTable, SyncConfigData>
    ),
    SyncConfigData,
    PrefetchHooks Function()> {
  $$SyncConfigsTableTableManager(_$SyncDatabase db, $SyncConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<String?> endpoint = const Value.absent(),
            Value<bool> autoSync = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<int> retryDelaySeconds = const Value.absent(),
            Value<int> batchSize = const Value.absent(),
            Value<String> syncFields = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConfigDataCompanion(
            entityType: entityType,
            endpoint: endpoint,
            autoSync: autoSync,
            maxRetries: maxRetries,
            retryDelaySeconds: retryDelaySeconds,
            batchSize: batchSize,
            syncFields: syncFields,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            Value<String?> endpoint = const Value.absent(),
            Value<bool> autoSync = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<int> retryDelaySeconds = const Value.absent(),
            Value<int> batchSize = const Value.absent(),
            required String syncFields,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConfigDataCompanion.insert(
            entityType: entityType,
            endpoint: endpoint,
            autoSync: autoSync,
            maxRetries: maxRetries,
            retryDelaySeconds: retryDelaySeconds,
            batchSize: batchSize,
            syncFields: syncFields,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncConfigsTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $SyncConfigsTable,
    SyncConfigData,
    $$SyncConfigsTableFilterComposer,
    $$SyncConfigsTableOrderingComposer,
    $$SyncConfigsTableAnnotationComposer,
    $$SyncConfigsTableCreateCompanionBuilder,
    $$SyncConfigsTableUpdateCompanionBuilder,
    (
      SyncConfigData,
      BaseReferences<_$SyncDatabase, $SyncConfigsTable, SyncConfigData>
    ),
    SyncConfigData,
    PrefetchHooks Function()>;

class $SyncDatabaseManager {
  final _$SyncDatabase _db;
  $SyncDatabaseManager(this._db);
  $$SyncItemsTableTableManager get syncItems =>
      $$SyncItemsTableTableManager(_db, _db.syncItems);
  $$EntityMetadataTableTableTableManager get entityMetadataTable =>
      $$EntityMetadataTableTableTableManager(_db, _db.entityMetadataTable);
  $$FileSyncItemsTableTableManager get fileSyncItems =>
      $$FileSyncItemsTableTableManager(_db, _db.fileSyncItems);
  $$SyncConfigsTableTableManager get syncConfigs =>
      $$SyncConfigsTableTableManager(_db, _db.syncConfigs);
}
