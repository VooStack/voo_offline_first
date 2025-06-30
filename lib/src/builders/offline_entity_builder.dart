import 'dart:async';
import 'package:analyzer/dart/element/element.dart' hide Element;
import 'package:analyzer/dart/element/element.dart' as analyzer show Element;
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations/offline_entity.dart';

/// Code generator for offline entities
class OfflineEntityBuilder extends GeneratorForAnnotation<OfflineEntity> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    analyzer.Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'OfflineEntity annotation can only be applied to classes',
        element: element,
      );
    }

    final classElement = element;
    final className = classElement.name;
    final tableName = annotation.read('tableName').stringValue;
    final endpoint = annotation.read('endpoint').stringValue;

    // Use the annotation values in the generated code
    final annotationValues = OfflineEntityAnnotationValues(
      autoSync: annotation.read('autoSync').boolValue,
      maxRetries: annotation.read('maxRetries').intValue,
      syncPriority: annotation.read('syncPriority').objectValue,
    );

    // Get sync fields
    final syncFields = _getSyncFields(classElement);

    // Generate the repository class
    final repositoryCode = _generateRepository(
      className,
      tableName,
      endpoint,
      syncFields,
      classElement,
      annotationValues,
    );

    // Generate the Drift table
    final tableCode = _generateDriftTable(className, tableName, classElement);

    // Generate BLoC
    final blocCode = _generateBloc(className, classElement);

    return '''
// Generated code for $className
// Do not modify this file manually

$tableCode

$repositoryCode

$blocCode
''';
  }

  List<SyncFieldInfo> _getSyncFields(ClassElement classElement) {
    final syncFields = <SyncFieldInfo>[];

    for (final field in classElement.fields) {
      final syncFieldAnnotation = _getSyncFieldAnnotation(field);
      if (syncFieldAnnotation != null) {
        syncFields.add(
          SyncFieldInfo(
            name: field.name,
            type: syncFieldAnnotation.read('type').objectValue,
            compress: syncFieldAnnotation.read('compress').boolValue,
            encrypt: syncFieldAnnotation.read('encrypt').boolValue,
            priority: syncFieldAnnotation.read('priority').objectValue,
          ),
        );
      }
    }

    return syncFields;
  }

  ConstantReader? _getSyncFieldAnnotation(FieldElement field) {
    for (final metadata in field.metadata) {
      if (metadata.element?.enclosingElement3?.name == 'SyncField') {
        return ConstantReader(metadata.computeConstantValue());
      }
    }
    return null;
  }

  String _generateDriftTable(String className, String tableName, ClassElement classElement) {
    final buffer = StringBuffer();
    final tableClassName = '${className}Table';

    buffer.writeln('@DataClassName(\'${className}Data\')');
    buffer.writeln('class $tableClassName extends Table {');
    buffer.writeln('  @override');
    buffer.writeln('  String get tableName => \'$tableName\';');
    buffer.writeln();

    // Generate columns based on class fields
    for (final field in classElement.fields) {
      final fieldName = field.name;
      final fieldType = field.type;

      if (fieldName == 'id') {
        buffer.writeln('  TextColumn get $fieldName => text()();');
      } else if (_isStringType(fieldType)) {
        buffer.writeln('  TextColumn get $fieldName => text()();');
      } else if (_isIntType(fieldType)) {
        buffer.writeln('  IntColumn get $fieldName => integer()();');
      } else if (_isDoubleType(fieldType)) {
        buffer.writeln('  RealColumn get $fieldName => real()();');
      } else if (_isBoolType(fieldType)) {
        buffer.writeln('  BoolColumn get $fieldName => boolean()();');
      } else if (_isDateTimeType(fieldType)) {
        buffer.writeln('  DateTimeColumn get $fieldName => dateTime()();');
      } else {
        // Complex types stored as JSON
        buffer.writeln('  TextColumn get $fieldName => text()(); // JSON');
      }
    }

    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Set<Column> get primaryKey => {id};');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateRepository(
    String className,
    String tableName,
    String endpoint,
    List<SyncFieldInfo> syncFields,
    ClassElement classElement,
    OfflineEntityAnnotationValues annotationValues,
  ) {
    final repositoryName = '${className}Repository';
    final buffer = StringBuffer();

    buffer.writeln('class $repositoryName extends BaseOfflineRepository<$className> {');
    buffer.writeln('  $repositoryName({');
    buffer.writeln('    required super.database,');
    buffer.writeln('    required super.syncManager,');
    buffer.writeln('  }) : super(');
    buffer.writeln('    entityType: \'$className\',');
    buffer.writeln('    offlineEntity: const OfflineEntity(');
    buffer.writeln('      tableName: \'$tableName\',');
    if (endpoint.isNotEmpty) {
      buffer.writeln('      endpoint: \'$endpoint\',');
    }
    buffer.writeln('      autoSync: ${annotationValues.autoSync},');
    buffer.writeln('      maxRetries: ${annotationValues.maxRetries},');
    buffer.writeln('    ),');
    buffer.writeln('  );');
    buffer.writeln();

    // Override abstract methods
    buffer.writeln('  @override');
    buffer.writeln('  TableInfo get table => database.${_camelCase(tableName)};');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  Map<String, dynamic> toJson($className entity) => entity.toJson();');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  $className fromJson(Map<String, dynamic> json) => $className.fromJson(json);');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  String getId($className entity) => entity.id;');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  $className setId($className entity, String id) => entity.copyWith(id: id);');
    buffer.writeln();

    // Generate CRUD methods
    buffer.writeln(_generateInsertMethod(className, classElement));
    buffer.writeln(_generateUpdateMethod(className, classElement));
    buffer.writeln(_generateDeleteMethod(className));
    buffer.writeln(_generateGetByIdMethod(className));
    buffer.writeln(_generateGetAllMethod(className));
    buffer.writeln(_generateGetWhereMethod(className));
    buffer.writeln(_generateWatchMethods(className));
    buffer.writeln(_generateCountMethods(className));

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateBloc(String className, ClassElement classElement) {
    final blocName = '${className}Bloc';
    final eventName = '${className}Event';
    final stateName = '${className}State';

    return '''
// BLoC for $className
abstract class $eventName extends Equatable {
  const $eventName();
  @override
  List<Object?> get props => [];
}

class Load${className}s extends $eventName {}
class Add$className extends $eventName {
  const Add$className(this.entity);
  final $className entity;
  @override
  List<Object?> get props => [entity];
}

class Update$className extends $eventName {
  const Update$className(this.entity);
  final $className entity;
  @override
  List<Object?> get props => [entity];
}

class Delete$className extends $eventName {
  const Delete$className(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

abstract class $stateName extends Equatable {
  const $stateName();
  @override
  List<Object?> get props => [];
}

class ${className}Initial extends $stateName {}
class ${className}Loading extends $stateName {}
class ${className}Loaded extends $stateName {
  const ${className}Loaded(this.entities);
  final List<$className> entities;
  @override
  List<Object?> get props => [entities];
}

class ${className}Error extends $stateName {
  const ${className}Error(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class $blocName extends Bloc<$eventName, $stateName> {
  $blocName(this.repository) : super(${className}Initial()) {
    on<Load${className}s>(_onLoad);
    on<Add$className>(_onAdd);
    on<Update$className>(_onUpdate);
    on<Delete$className>(_onDelete);
  }

  final ${className}Repository repository;

  Future<void> _onLoad(Load${className}s event, Emitter<$stateName> emit) async {
    emit(${className}Loading());
    try {
      final entities = await repository.getAll();
      emit(${className}Loaded(entities));
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }

  Future<void> _onAdd(Add$className event, Emitter<$stateName> emit) async {
    try {
      await repository.save(event.entity);
      add(Load${className}s());
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }

  Future<void> _onUpdate(Update$className event, Emitter<$stateName> emit) async {
    try {
      await repository.save(event.entity);
      add(Load${className}s());
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }

  Future<void> _onDelete(Delete$className event, Emitter<$stateName> emit) async {
    try {
      await repository.delete(event.id);
      add(Load${className}s());
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }
}
''';
  }

  String _generateInsertMethod(String className, ClassElement classElement) {
    return '''
  @override
  Future<void> insertEntity($className entity) async {
    final companion = ${className}TableCompanion.insert(
      id: Value(entity.id),
      // Add other fields based on your entity properties
      // This should be customized for each entity
    );
    await database.into(table).insert(companion);
  }''';
  }

  String _generateUpdateMethod(String className, ClassElement classElement) {
    return '''
  @override
  Future<void> updateEntity($className entity) async {
    await (database.update(table)..where((tbl) => tbl.id.equals(entity.id)))
        .write(${className}TableCompanion(
      // Add fields to update based on your entity properties
      // This should be customized for each entity
    ));
  }''';
  }

  String _generateDeleteMethod(String className) {
    return '''
  @override
  Future<void> deleteEntityById(String id) async {
    await (database.delete(table)..where((tbl) => tbl.id.equals(id))).go();
  }''';
  }

  String _generateGetByIdMethod(String className) {
    return '''
  @override
  Future<$className?> getEntityById(String id) async {
    final query = database.select(table)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _convertToEntity(result) : null;
  }

  $className _convertToEntity(dynamic row) {
    // Convert database row to entity
    // This should be customized for each entity
    throw UnimplementedError('Customize _convertToEntity for $className');
  }''';
  }

  String _generateGetAllMethod(String className) {
    return '''
  @override
  Future<List<$className>> getAllEntities() async {
    final query = database.select(table);
    final results = await query.get();
    return results.map(_convertToEntity).toList();
  }''';
  }

  String _generateGetWhereMethod(String className) {
    return '''
  @override
  Future<List<$className>> getEntitiesWhere(Map<String, dynamic> criteria) async {
    // Build query based on criteria
    // This should be customized for each entity
    final query = database.select(table);
    final results = await query.get();
    return results.map(_convertToEntity).toList();
  }''';
  }

  String _generateWatchMethods(String className) {
    return '''
  @override
  Stream<List<$className>> watchAllEntities() {
    return database.select(table).watch().map(
      (rows) => rows.map(_convertToEntity).toList(),
    );
  }

  @override
  Stream<List<$className>> watchEntitiesWhere(Map<String, dynamic> criteria) {
    // Build query based on criteria
    // This should be customized for each entity
    return database.select(table).watch().map(
      (rows) => rows.map(_convertToEntity).toList(),
    );
  }''';
  }

  String _generateCountMethods(String className) {
    return '''
  @override
  Future<int> count() async {
    final query = database.selectOnly(table)..addColumns([table.id.count()]);
    final result = await query.getSingle();
    return result.read(table.id.count()) ?? 0;
  }

  @override
  Future<void> clear() async {
    await database.delete(table).go();
  }''';
  }

  // Helper methods
  bool _isStringType(DartType type) => type.isDartCoreString;
  bool _isIntType(DartType type) => type.isDartCoreInt;
  bool _isDoubleType(DartType type) => type.isDartCoreDouble;
  bool _isBoolType(DartType type) => type.isDartCoreBool;
  bool _isDateTimeType(DartType type) => type.toString() == 'DateTime';

  String _camelCase(String input) {
    if (input.isEmpty) return input;
    final parts = input.split('_');
    return parts.first + parts.skip(1).map(_capitalize).join();
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}

class SyncFieldInfo {
  const SyncFieldInfo({
    required this.name,
    required this.type,
    required this.compress,
    required this.encrypt,
    required this.priority,
  });

  final String name;
  final Object type;
  final bool compress;
  final bool encrypt;
  final Object priority;
}

class OfflineEntityAnnotationValues {
  const OfflineEntityAnnotationValues({
    required this.autoSync,
    required this.maxRetries,
    required this.syncPriority,
  });

  final bool autoSync;
  final int maxRetries;
  final Object syncPriority;
}

/// Builder factory
Builder offlineEntityBuilder(BuilderOptions options) => SharedPartBuilder([OfflineEntityBuilder()], 'offline_entity');
