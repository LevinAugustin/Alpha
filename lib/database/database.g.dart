// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  const Category({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Category copyWith({int? id, String? name}) =>
      Category(id: id ?? this.id, name: name ?? this.name);
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoriesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<String> days = GeneratedColumn<String>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [days, id, sequence, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final String days;
  final int id;
  final int? sequence;
  final String? title;
  const Plan({required this.days, required this.id, this.sequence, this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['days'] = Variable<String>(days);
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sequence != null) {
      map['sequence'] = Variable<int>(sequence);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      days: Value(days),
      id: Value(id),
      sequence: sequence == null && nullToAbsent
          ? const Value.absent()
          : Value(sequence),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      days: serializer.fromJson<String>(json['days']),
      id: serializer.fromJson<int>(json['id']),
      sequence: serializer.fromJson<int?>(json['sequence']),
      title: serializer.fromJson<String?>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'days': serializer.toJson<String>(days),
      'id': serializer.toJson<int>(id),
      'sequence': serializer.toJson<int?>(sequence),
      'title': serializer.toJson<String?>(title),
    };
  }

  Plan copyWith({
    String? days,
    int? id,
    Value<int?> sequence = const Value.absent(),
    Value<String?> title = const Value.absent(),
  }) => Plan(
    days: days ?? this.days,
    id: id ?? this.id,
    sequence: sequence.present ? sequence.value : this.sequence,
    title: title.present ? title.value : this.title,
  );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      days: data.days.present ? data.days.value : this.days,
      id: data.id.present ? data.id.value : this.id,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('days: $days, ')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(days, id, sequence, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.days == this.days &&
          other.id == this.id &&
          other.sequence == this.sequence &&
          other.title == this.title);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<String> days;
  final Value<int> id;
  final Value<int?> sequence;
  final Value<String?> title;
  const PlansCompanion({
    this.days = const Value.absent(),
    this.id = const Value.absent(),
    this.sequence = const Value.absent(),
    this.title = const Value.absent(),
  });
  PlansCompanion.insert({
    required String days,
    this.id = const Value.absent(),
    this.sequence = const Value.absent(),
    this.title = const Value.absent(),
  }) : days = Value(days);
  static Insertable<Plan> custom({
    Expression<String>? days,
    Expression<int>? id,
    Expression<int>? sequence,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (days != null) 'days': days,
      if (id != null) 'id': id,
      if (sequence != null) 'sequence': sequence,
      if (title != null) 'title': title,
    });
  }

  PlansCompanion copyWith({
    Value<String>? days,
    Value<int>? id,
    Value<int?>? sequence,
    Value<String?>? title,
  }) {
    return PlansCompanion(
      days: days ?? this.days,
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (days.present) {
      map['days'] = Variable<String>(days.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('days: $days, ')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayUnitMeta = const VerificationMeta(
    'displayUnit',
  );
  @override
  late final GeneratedColumn<String> displayUnit = GeneratedColumn<String>(
    'display_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultRestDurationMsMeta =
      const VerificationMeta('defaultRestDurationMs');
  @override
  late final GeneratedColumn<int> defaultRestDurationMs = GeneratedColumn<int>(
    'default_rest_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _graphMetricMeta = const VerificationMeta(
    'graphMetric',
  );
  @override
  late final GeneratedColumn<String> graphMetric = GeneratedColumn<String>(
    'graph_metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bestWeight'),
  );
  static const VerificationMeta _graphPeriodMeta = const VerificationMeta(
    'graphPeriod',
  );
  @override
  late final GeneratedColumn<String> graphPeriod = GeneratedColumn<String>(
    'graph_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('day'),
  );
  static const VerificationMeta _graphLimitMeta = const VerificationMeta(
    'graphLimit',
  );
  @override
  late final GeneratedColumn<int> graphLimit = GeneratedColumn<int>(
    'graph_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _graphTimeBasedXAxisMeta =
      const VerificationMeta('graphTimeBasedXAxis');
  @override
  late final GeneratedColumn<bool> graphTimeBasedXAxis = GeneratedColumn<bool>(
    'graph_time_based_x_axis',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("graph_time_based_x_axis" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _germanNameMeta = const VerificationMeta(
    'germanName',
  );
  @override
  late final GeneratedColumn<String> germanName = GeneratedColumn<String>(
    'german_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumn<String> muscle = GeneratedColumn<String>(
    'muscle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipsMeta = const VerificationMeta('tips');
  @override
  late final GeneratedColumn<String> tips = GeneratedColumn<String>(
    'tips',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogSourceMeta = const VerificationMeta(
    'catalogSource',
  );
  @override
  late final GeneratedColumn<String> catalogSource = GeneratedColumn<String>(
    'catalog_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogLicenseMeta = const VerificationMeta(
    'catalogLicense',
  );
  @override
  late final GeneratedColumn<String> catalogLicense = GeneratedColumn<String>(
    'catalog_license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageSourceMeta = const VerificationMeta(
    'imageSource',
  );
  @override
  late final GeneratedColumn<String> imageSource = GeneratedColumn<String>(
    'image_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLicenseMeta = const VerificationMeta(
    'imageLicense',
  );
  @override
  late final GeneratedColumn<String> imageLicense = GeneratedColumn<String>(
    'image_license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternativesMeta = const VerificationMeta(
    'alternatives',
  );
  @override
  late final GeneratedColumn<String> alternatives = GeneratedColumn<String>(
    'alternatives',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schulterRisikoMeta = const VerificationMeta(
    'schulterRisiko',
  );
  @override
  late final GeneratedColumn<String> schulterRisiko = GeneratedColumn<String>(
    'schulter_risiko',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familieMeta = const VerificationMeta(
    'familie',
  );
  @override
  late final GeneratedColumn<String> familie = GeneratedColumn<String>(
    'familie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _griffMeta = const VerificationMeta('griff');
  @override
  late final GeneratedColumn<String> griff = GeneratedColumn<String>(
    'griff',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _einseitigMeta = const VerificationMeta(
    'einseitig',
  );
  @override
  late final GeneratedColumn<bool> einseitig = GeneratedColumn<bool>(
    'einseitig',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("einseitig" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    displayUnit,
    categoryId,
    image,
    defaultRestDurationMs,
    notes,
    graphMetric,
    graphPeriod,
    graphLimit,
    graphTimeBasedXAxis,
    archived,
    germanName,
    aliases,
    muscle,
    catalogId,
    categoryName,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    mechanic,
    steps,
    tips,
    catalogSource,
    catalogLicense,
    imageSource,
    imageLicense,
    alternatives,
    schulterRisiko,
    familie,
    griff,
    position,
    einseitig,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('display_unit')) {
      context.handle(
        _displayUnitMeta,
        displayUnit.isAcceptableOrUnknown(
          data['display_unit']!,
          _displayUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayUnitMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('default_rest_duration_ms')) {
      context.handle(
        _defaultRestDurationMsMeta,
        defaultRestDurationMs.isAcceptableOrUnknown(
          data['default_rest_duration_ms']!,
          _defaultRestDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('graph_metric')) {
      context.handle(
        _graphMetricMeta,
        graphMetric.isAcceptableOrUnknown(
          data['graph_metric']!,
          _graphMetricMeta,
        ),
      );
    }
    if (data.containsKey('graph_period')) {
      context.handle(
        _graphPeriodMeta,
        graphPeriod.isAcceptableOrUnknown(
          data['graph_period']!,
          _graphPeriodMeta,
        ),
      );
    }
    if (data.containsKey('graph_limit')) {
      context.handle(
        _graphLimitMeta,
        graphLimit.isAcceptableOrUnknown(data['graph_limit']!, _graphLimitMeta),
      );
    }
    if (data.containsKey('graph_time_based_x_axis')) {
      context.handle(
        _graphTimeBasedXAxisMeta,
        graphTimeBasedXAxis.isAcceptableOrUnknown(
          data['graph_time_based_x_axis']!,
          _graphTimeBasedXAxisMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('german_name')) {
      context.handle(
        _germanNameMeta,
        germanName.isAcceptableOrUnknown(data['german_name']!, _germanNameMeta),
      );
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('muscle')) {
      context.handle(
        _muscleMeta,
        muscle.isAcceptableOrUnknown(data['muscle']!, _muscleMeta),
      );
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('tips')) {
      context.handle(
        _tipsMeta,
        tips.isAcceptableOrUnknown(data['tips']!, _tipsMeta),
      );
    }
    if (data.containsKey('catalog_source')) {
      context.handle(
        _catalogSourceMeta,
        catalogSource.isAcceptableOrUnknown(
          data['catalog_source']!,
          _catalogSourceMeta,
        ),
      );
    }
    if (data.containsKey('catalog_license')) {
      context.handle(
        _catalogLicenseMeta,
        catalogLicense.isAcceptableOrUnknown(
          data['catalog_license']!,
          _catalogLicenseMeta,
        ),
      );
    }
    if (data.containsKey('image_source')) {
      context.handle(
        _imageSourceMeta,
        imageSource.isAcceptableOrUnknown(
          data['image_source']!,
          _imageSourceMeta,
        ),
      );
    }
    if (data.containsKey('image_license')) {
      context.handle(
        _imageLicenseMeta,
        imageLicense.isAcceptableOrUnknown(
          data['image_license']!,
          _imageLicenseMeta,
        ),
      );
    }
    if (data.containsKey('alternatives')) {
      context.handle(
        _alternativesMeta,
        alternatives.isAcceptableOrUnknown(
          data['alternatives']!,
          _alternativesMeta,
        ),
      );
    }
    if (data.containsKey('schulter_risiko')) {
      context.handle(
        _schulterRisikoMeta,
        schulterRisiko.isAcceptableOrUnknown(
          data['schulter_risiko']!,
          _schulterRisikoMeta,
        ),
      );
    }
    if (data.containsKey('familie')) {
      context.handle(
        _familieMeta,
        familie.isAcceptableOrUnknown(data['familie']!, _familieMeta),
      );
    }
    if (data.containsKey('griff')) {
      context.handle(
        _griffMeta,
        griff.isAcceptableOrUnknown(data['griff']!, _griffMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('einseitig')) {
      context.handle(
        _einseitigMeta,
        einseitig.isAcceptableOrUnknown(data['einseitig']!, _einseitigMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      displayUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_unit'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
      defaultRestDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rest_duration_ms'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      graphMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graph_metric'],
      )!,
      graphPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graph_period'],
      )!,
      graphLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graph_limit'],
      )!,
      graphTimeBasedXAxis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}graph_time_based_x_axis'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      germanName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}german_name'],
      ),
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      ),
      muscle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle'],
      ),
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      ),
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      ),
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      ),
      tips: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tips'],
      ),
      catalogSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_source'],
      ),
      catalogLicense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_license'],
      ),
      imageSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_source'],
      ),
      imageLicense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_license'],
      ),
      alternatives: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternatives'],
      ),
      schulterRisiko: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schulter_risiko'],
      ),
      familie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}familie'],
      ),
      griff: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}griff'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      einseitig: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}einseitig'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String kind;
  final String displayUnit;
  final int? categoryId;
  final String? image;
  final int? defaultRestDurationMs;
  final String? notes;
  final String graphMetric;
  final String graphPeriod;
  final int graphLimit;
  final bool graphTimeBasedXAxis;
  final bool archived;
  final String? germanName;
  final String? aliases;
  final String? muscle;
  final String? catalogId;
  final String? categoryName;
  final String? equipment;
  final String? primaryMuscles;
  final String? secondaryMuscles;
  final String? mechanic;
  final String? steps;
  final String? tips;
  final String? catalogSource;
  final String? catalogLicense;
  final String? imageSource;
  final String? imageLicense;
  final String? alternatives;
  final String? schulterRisiko;
  final String? familie;
  final String? griff;
  final String? position;
  final bool einseitig;
  const Exercise({
    required this.id,
    required this.name,
    required this.kind,
    required this.displayUnit,
    this.categoryId,
    this.image,
    this.defaultRestDurationMs,
    this.notes,
    required this.graphMetric,
    required this.graphPeriod,
    required this.graphLimit,
    required this.graphTimeBasedXAxis,
    required this.archived,
    this.germanName,
    this.aliases,
    this.muscle,
    this.catalogId,
    this.categoryName,
    this.equipment,
    this.primaryMuscles,
    this.secondaryMuscles,
    this.mechanic,
    this.steps,
    this.tips,
    this.catalogSource,
    this.catalogLicense,
    this.imageSource,
    this.imageLicense,
    this.alternatives,
    this.schulterRisiko,
    this.familie,
    this.griff,
    this.position,
    required this.einseitig,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['display_unit'] = Variable<String>(displayUnit);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    if (!nullToAbsent || defaultRestDurationMs != null) {
      map['default_rest_duration_ms'] = Variable<int>(defaultRestDurationMs);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['graph_metric'] = Variable<String>(graphMetric);
    map['graph_period'] = Variable<String>(graphPeriod);
    map['graph_limit'] = Variable<int>(graphLimit);
    map['graph_time_based_x_axis'] = Variable<bool>(graphTimeBasedXAxis);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || germanName != null) {
      map['german_name'] = Variable<String>(germanName);
    }
    if (!nullToAbsent || aliases != null) {
      map['aliases'] = Variable<String>(aliases);
    }
    if (!nullToAbsent || muscle != null) {
      map['muscle'] = Variable<String>(muscle);
    }
    if (!nullToAbsent || catalogId != null) {
      map['catalog_id'] = Variable<String>(catalogId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || primaryMuscles != null) {
      map['primary_muscles'] = Variable<String>(primaryMuscles);
    }
    if (!nullToAbsent || secondaryMuscles != null) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<String>(steps);
    }
    if (!nullToAbsent || tips != null) {
      map['tips'] = Variable<String>(tips);
    }
    if (!nullToAbsent || catalogSource != null) {
      map['catalog_source'] = Variable<String>(catalogSource);
    }
    if (!nullToAbsent || catalogLicense != null) {
      map['catalog_license'] = Variable<String>(catalogLicense);
    }
    if (!nullToAbsent || imageSource != null) {
      map['image_source'] = Variable<String>(imageSource);
    }
    if (!nullToAbsent || imageLicense != null) {
      map['image_license'] = Variable<String>(imageLicense);
    }
    if (!nullToAbsent || alternatives != null) {
      map['alternatives'] = Variable<String>(alternatives);
    }
    if (!nullToAbsent || schulterRisiko != null) {
      map['schulter_risiko'] = Variable<String>(schulterRisiko);
    }
    if (!nullToAbsent || familie != null) {
      map['familie'] = Variable<String>(familie);
    }
    if (!nullToAbsent || griff != null) {
      map['griff'] = Variable<String>(griff);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    map['einseitig'] = Variable<bool>(einseitig);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      displayUnit: Value(displayUnit),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      defaultRestDurationMs: defaultRestDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultRestDurationMs),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      graphMetric: Value(graphMetric),
      graphPeriod: Value(graphPeriod),
      graphLimit: Value(graphLimit),
      graphTimeBasedXAxis: Value(graphTimeBasedXAxis),
      archived: Value(archived),
      germanName: germanName == null && nullToAbsent
          ? const Value.absent()
          : Value(germanName),
      aliases: aliases == null && nullToAbsent
          ? const Value.absent()
          : Value(aliases),
      muscle: muscle == null && nullToAbsent
          ? const Value.absent()
          : Value(muscle),
      catalogId: catalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      primaryMuscles: primaryMuscles == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryMuscles),
      secondaryMuscles: secondaryMuscles == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscles),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      tips: tips == null && nullToAbsent ? const Value.absent() : Value(tips),
      catalogSource: catalogSource == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogSource),
      catalogLicense: catalogLicense == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogLicense),
      imageSource: imageSource == null && nullToAbsent
          ? const Value.absent()
          : Value(imageSource),
      imageLicense: imageLicense == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLicense),
      alternatives: alternatives == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatives),
      schulterRisiko: schulterRisiko == null && nullToAbsent
          ? const Value.absent()
          : Value(schulterRisiko),
      familie: familie == null && nullToAbsent
          ? const Value.absent()
          : Value(familie),
      griff: griff == null && nullToAbsent
          ? const Value.absent()
          : Value(griff),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      einseitig: Value(einseitig),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      displayUnit: serializer.fromJson<String>(json['displayUnit']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      image: serializer.fromJson<String?>(json['image']),
      defaultRestDurationMs: serializer.fromJson<int?>(
        json['defaultRestDurationMs'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      graphMetric: serializer.fromJson<String>(json['graphMetric']),
      graphPeriod: serializer.fromJson<String>(json['graphPeriod']),
      graphLimit: serializer.fromJson<int>(json['graphLimit']),
      graphTimeBasedXAxis: serializer.fromJson<bool>(
        json['graphTimeBasedXAxis'],
      ),
      archived: serializer.fromJson<bool>(json['archived']),
      germanName: serializer.fromJson<String?>(json['germanName']),
      aliases: serializer.fromJson<String?>(json['aliases']),
      muscle: serializer.fromJson<String?>(json['muscle']),
      catalogId: serializer.fromJson<String?>(json['catalogId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      primaryMuscles: serializer.fromJson<String?>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String?>(json['secondaryMuscles']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      steps: serializer.fromJson<String?>(json['steps']),
      tips: serializer.fromJson<String?>(json['tips']),
      catalogSource: serializer.fromJson<String?>(json['catalogSource']),
      catalogLicense: serializer.fromJson<String?>(json['catalogLicense']),
      imageSource: serializer.fromJson<String?>(json['imageSource']),
      imageLicense: serializer.fromJson<String?>(json['imageLicense']),
      alternatives: serializer.fromJson<String?>(json['alternatives']),
      schulterRisiko: serializer.fromJson<String?>(json['schulterRisiko']),
      familie: serializer.fromJson<String?>(json['familie']),
      griff: serializer.fromJson<String?>(json['griff']),
      position: serializer.fromJson<String?>(json['position']),
      einseitig: serializer.fromJson<bool>(json['einseitig']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'displayUnit': serializer.toJson<String>(displayUnit),
      'categoryId': serializer.toJson<int?>(categoryId),
      'image': serializer.toJson<String?>(image),
      'defaultRestDurationMs': serializer.toJson<int?>(defaultRestDurationMs),
      'notes': serializer.toJson<String?>(notes),
      'graphMetric': serializer.toJson<String>(graphMetric),
      'graphPeriod': serializer.toJson<String>(graphPeriod),
      'graphLimit': serializer.toJson<int>(graphLimit),
      'graphTimeBasedXAxis': serializer.toJson<bool>(graphTimeBasedXAxis),
      'archived': serializer.toJson<bool>(archived),
      'germanName': serializer.toJson<String?>(germanName),
      'aliases': serializer.toJson<String?>(aliases),
      'muscle': serializer.toJson<String?>(muscle),
      'catalogId': serializer.toJson<String?>(catalogId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'equipment': serializer.toJson<String?>(equipment),
      'primaryMuscles': serializer.toJson<String?>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String?>(secondaryMuscles),
      'mechanic': serializer.toJson<String?>(mechanic),
      'steps': serializer.toJson<String?>(steps),
      'tips': serializer.toJson<String?>(tips),
      'catalogSource': serializer.toJson<String?>(catalogSource),
      'catalogLicense': serializer.toJson<String?>(catalogLicense),
      'imageSource': serializer.toJson<String?>(imageSource),
      'imageLicense': serializer.toJson<String?>(imageLicense),
      'alternatives': serializer.toJson<String?>(alternatives),
      'schulterRisiko': serializer.toJson<String?>(schulterRisiko),
      'familie': serializer.toJson<String?>(familie),
      'griff': serializer.toJson<String?>(griff),
      'position': serializer.toJson<String?>(position),
      'einseitig': serializer.toJson<bool>(einseitig),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? kind,
    String? displayUnit,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> image = const Value.absent(),
    Value<int?> defaultRestDurationMs = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? graphMetric,
    String? graphPeriod,
    int? graphLimit,
    bool? graphTimeBasedXAxis,
    bool? archived,
    Value<String?> germanName = const Value.absent(),
    Value<String?> aliases = const Value.absent(),
    Value<String?> muscle = const Value.absent(),
    Value<String?> catalogId = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    Value<String?> primaryMuscles = const Value.absent(),
    Value<String?> secondaryMuscles = const Value.absent(),
    Value<String?> mechanic = const Value.absent(),
    Value<String?> steps = const Value.absent(),
    Value<String?> tips = const Value.absent(),
    Value<String?> catalogSource = const Value.absent(),
    Value<String?> catalogLicense = const Value.absent(),
    Value<String?> imageSource = const Value.absent(),
    Value<String?> imageLicense = const Value.absent(),
    Value<String?> alternatives = const Value.absent(),
    Value<String?> schulterRisiko = const Value.absent(),
    Value<String?> familie = const Value.absent(),
    Value<String?> griff = const Value.absent(),
    Value<String?> position = const Value.absent(),
    bool? einseitig,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    displayUnit: displayUnit ?? this.displayUnit,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    image: image.present ? image.value : this.image,
    defaultRestDurationMs: defaultRestDurationMs.present
        ? defaultRestDurationMs.value
        : this.defaultRestDurationMs,
    notes: notes.present ? notes.value : this.notes,
    graphMetric: graphMetric ?? this.graphMetric,
    graphPeriod: graphPeriod ?? this.graphPeriod,
    graphLimit: graphLimit ?? this.graphLimit,
    graphTimeBasedXAxis: graphTimeBasedXAxis ?? this.graphTimeBasedXAxis,
    archived: archived ?? this.archived,
    germanName: germanName.present ? germanName.value : this.germanName,
    aliases: aliases.present ? aliases.value : this.aliases,
    muscle: muscle.present ? muscle.value : this.muscle,
    catalogId: catalogId.present ? catalogId.value : this.catalogId,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    equipment: equipment.present ? equipment.value : this.equipment,
    primaryMuscles: primaryMuscles.present
        ? primaryMuscles.value
        : this.primaryMuscles,
    secondaryMuscles: secondaryMuscles.present
        ? secondaryMuscles.value
        : this.secondaryMuscles,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    steps: steps.present ? steps.value : this.steps,
    tips: tips.present ? tips.value : this.tips,
    catalogSource: catalogSource.present
        ? catalogSource.value
        : this.catalogSource,
    catalogLicense: catalogLicense.present
        ? catalogLicense.value
        : this.catalogLicense,
    imageSource: imageSource.present ? imageSource.value : this.imageSource,
    imageLicense: imageLicense.present ? imageLicense.value : this.imageLicense,
    alternatives: alternatives.present ? alternatives.value : this.alternatives,
    schulterRisiko: schulterRisiko.present
        ? schulterRisiko.value
        : this.schulterRisiko,
    familie: familie.present ? familie.value : this.familie,
    griff: griff.present ? griff.value : this.griff,
    position: position.present ? position.value : this.position,
    einseitig: einseitig ?? this.einseitig,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      displayUnit: data.displayUnit.present
          ? data.displayUnit.value
          : this.displayUnit,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      image: data.image.present ? data.image.value : this.image,
      defaultRestDurationMs: data.defaultRestDurationMs.present
          ? data.defaultRestDurationMs.value
          : this.defaultRestDurationMs,
      notes: data.notes.present ? data.notes.value : this.notes,
      graphMetric: data.graphMetric.present
          ? data.graphMetric.value
          : this.graphMetric,
      graphPeriod: data.graphPeriod.present
          ? data.graphPeriod.value
          : this.graphPeriod,
      graphLimit: data.graphLimit.present
          ? data.graphLimit.value
          : this.graphLimit,
      graphTimeBasedXAxis: data.graphTimeBasedXAxis.present
          ? data.graphTimeBasedXAxis.value
          : this.graphTimeBasedXAxis,
      archived: data.archived.present ? data.archived.value : this.archived,
      germanName: data.germanName.present
          ? data.germanName.value
          : this.germanName,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      muscle: data.muscle.present ? data.muscle.value : this.muscle,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      steps: data.steps.present ? data.steps.value : this.steps,
      tips: data.tips.present ? data.tips.value : this.tips,
      catalogSource: data.catalogSource.present
          ? data.catalogSource.value
          : this.catalogSource,
      catalogLicense: data.catalogLicense.present
          ? data.catalogLicense.value
          : this.catalogLicense,
      imageSource: data.imageSource.present
          ? data.imageSource.value
          : this.imageSource,
      imageLicense: data.imageLicense.present
          ? data.imageLicense.value
          : this.imageLicense,
      alternatives: data.alternatives.present
          ? data.alternatives.value
          : this.alternatives,
      schulterRisiko: data.schulterRisiko.present
          ? data.schulterRisiko.value
          : this.schulterRisiko,
      familie: data.familie.present ? data.familie.value : this.familie,
      griff: data.griff.present ? data.griff.value : this.griff,
      position: data.position.present ? data.position.value : this.position,
      einseitig: data.einseitig.present ? data.einseitig.value : this.einseitig,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('displayUnit: $displayUnit, ')
          ..write('categoryId: $categoryId, ')
          ..write('image: $image, ')
          ..write('defaultRestDurationMs: $defaultRestDurationMs, ')
          ..write('notes: $notes, ')
          ..write('graphMetric: $graphMetric, ')
          ..write('graphPeriod: $graphPeriod, ')
          ..write('graphLimit: $graphLimit, ')
          ..write('graphTimeBasedXAxis: $graphTimeBasedXAxis, ')
          ..write('archived: $archived, ')
          ..write('germanName: $germanName, ')
          ..write('aliases: $aliases, ')
          ..write('muscle: $muscle, ')
          ..write('catalogId: $catalogId, ')
          ..write('categoryName: $categoryName, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('mechanic: $mechanic, ')
          ..write('steps: $steps, ')
          ..write('tips: $tips, ')
          ..write('catalogSource: $catalogSource, ')
          ..write('catalogLicense: $catalogLicense, ')
          ..write('imageSource: $imageSource, ')
          ..write('imageLicense: $imageLicense, ')
          ..write('alternatives: $alternatives, ')
          ..write('schulterRisiko: $schulterRisiko, ')
          ..write('familie: $familie, ')
          ..write('griff: $griff, ')
          ..write('position: $position, ')
          ..write('einseitig: $einseitig')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    kind,
    displayUnit,
    categoryId,
    image,
    defaultRestDurationMs,
    notes,
    graphMetric,
    graphPeriod,
    graphLimit,
    graphTimeBasedXAxis,
    archived,
    germanName,
    aliases,
    muscle,
    catalogId,
    categoryName,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    mechanic,
    steps,
    tips,
    catalogSource,
    catalogLicense,
    imageSource,
    imageLicense,
    alternatives,
    schulterRisiko,
    familie,
    griff,
    position,
    einseitig,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.displayUnit == this.displayUnit &&
          other.categoryId == this.categoryId &&
          other.image == this.image &&
          other.defaultRestDurationMs == this.defaultRestDurationMs &&
          other.notes == this.notes &&
          other.graphMetric == this.graphMetric &&
          other.graphPeriod == this.graphPeriod &&
          other.graphLimit == this.graphLimit &&
          other.graphTimeBasedXAxis == this.graphTimeBasedXAxis &&
          other.archived == this.archived &&
          other.germanName == this.germanName &&
          other.aliases == this.aliases &&
          other.muscle == this.muscle &&
          other.catalogId == this.catalogId &&
          other.categoryName == this.categoryName &&
          other.equipment == this.equipment &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.mechanic == this.mechanic &&
          other.steps == this.steps &&
          other.tips == this.tips &&
          other.catalogSource == this.catalogSource &&
          other.catalogLicense == this.catalogLicense &&
          other.imageSource == this.imageSource &&
          other.imageLicense == this.imageLicense &&
          other.alternatives == this.alternatives &&
          other.schulterRisiko == this.schulterRisiko &&
          other.familie == this.familie &&
          other.griff == this.griff &&
          other.position == this.position &&
          other.einseitig == this.einseitig);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> displayUnit;
  final Value<int?> categoryId;
  final Value<String?> image;
  final Value<int?> defaultRestDurationMs;
  final Value<String?> notes;
  final Value<String> graphMetric;
  final Value<String> graphPeriod;
  final Value<int> graphLimit;
  final Value<bool> graphTimeBasedXAxis;
  final Value<bool> archived;
  final Value<String?> germanName;
  final Value<String?> aliases;
  final Value<String?> muscle;
  final Value<String?> catalogId;
  final Value<String?> categoryName;
  final Value<String?> equipment;
  final Value<String?> primaryMuscles;
  final Value<String?> secondaryMuscles;
  final Value<String?> mechanic;
  final Value<String?> steps;
  final Value<String?> tips;
  final Value<String?> catalogSource;
  final Value<String?> catalogLicense;
  final Value<String?> imageSource;
  final Value<String?> imageLicense;
  final Value<String?> alternatives;
  final Value<String?> schulterRisiko;
  final Value<String?> familie;
  final Value<String?> griff;
  final Value<String?> position;
  final Value<bool> einseitig;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.displayUnit = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.image = const Value.absent(),
    this.defaultRestDurationMs = const Value.absent(),
    this.notes = const Value.absent(),
    this.graphMetric = const Value.absent(),
    this.graphPeriod = const Value.absent(),
    this.graphLimit = const Value.absent(),
    this.graphTimeBasedXAxis = const Value.absent(),
    this.archived = const Value.absent(),
    this.germanName = const Value.absent(),
    this.aliases = const Value.absent(),
    this.muscle = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.steps = const Value.absent(),
    this.tips = const Value.absent(),
    this.catalogSource = const Value.absent(),
    this.catalogLicense = const Value.absent(),
    this.imageSource = const Value.absent(),
    this.imageLicense = const Value.absent(),
    this.alternatives = const Value.absent(),
    this.schulterRisiko = const Value.absent(),
    this.familie = const Value.absent(),
    this.griff = const Value.absent(),
    this.position = const Value.absent(),
    this.einseitig = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String kind,
    required String displayUnit,
    this.categoryId = const Value.absent(),
    this.image = const Value.absent(),
    this.defaultRestDurationMs = const Value.absent(),
    this.notes = const Value.absent(),
    this.graphMetric = const Value.absent(),
    this.graphPeriod = const Value.absent(),
    this.graphLimit = const Value.absent(),
    this.graphTimeBasedXAxis = const Value.absent(),
    this.archived = const Value.absent(),
    this.germanName = const Value.absent(),
    this.aliases = const Value.absent(),
    this.muscle = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.steps = const Value.absent(),
    this.tips = const Value.absent(),
    this.catalogSource = const Value.absent(),
    this.catalogLicense = const Value.absent(),
    this.imageSource = const Value.absent(),
    this.imageLicense = const Value.absent(),
    this.alternatives = const Value.absent(),
    this.schulterRisiko = const Value.absent(),
    this.familie = const Value.absent(),
    this.griff = const Value.absent(),
    this.position = const Value.absent(),
    this.einseitig = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind),
       displayUnit = Value(displayUnit);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? displayUnit,
    Expression<int>? categoryId,
    Expression<String>? image,
    Expression<int>? defaultRestDurationMs,
    Expression<String>? notes,
    Expression<String>? graphMetric,
    Expression<String>? graphPeriod,
    Expression<int>? graphLimit,
    Expression<bool>? graphTimeBasedXAxis,
    Expression<bool>? archived,
    Expression<String>? germanName,
    Expression<String>? aliases,
    Expression<String>? muscle,
    Expression<String>? catalogId,
    Expression<String>? categoryName,
    Expression<String>? equipment,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? mechanic,
    Expression<String>? steps,
    Expression<String>? tips,
    Expression<String>? catalogSource,
    Expression<String>? catalogLicense,
    Expression<String>? imageSource,
    Expression<String>? imageLicense,
    Expression<String>? alternatives,
    Expression<String>? schulterRisiko,
    Expression<String>? familie,
    Expression<String>? griff,
    Expression<String>? position,
    Expression<bool>? einseitig,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (displayUnit != null) 'display_unit': displayUnit,
      if (categoryId != null) 'category_id': categoryId,
      if (image != null) 'image': image,
      if (defaultRestDurationMs != null)
        'default_rest_duration_ms': defaultRestDurationMs,
      if (notes != null) 'notes': notes,
      if (graphMetric != null) 'graph_metric': graphMetric,
      if (graphPeriod != null) 'graph_period': graphPeriod,
      if (graphLimit != null) 'graph_limit': graphLimit,
      if (graphTimeBasedXAxis != null)
        'graph_time_based_x_axis': graphTimeBasedXAxis,
      if (archived != null) 'archived': archived,
      if (germanName != null) 'german_name': germanName,
      if (aliases != null) 'aliases': aliases,
      if (muscle != null) 'muscle': muscle,
      if (catalogId != null) 'catalog_id': catalogId,
      if (categoryName != null) 'category_name': categoryName,
      if (equipment != null) 'equipment': equipment,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (mechanic != null) 'mechanic': mechanic,
      if (steps != null) 'steps': steps,
      if (tips != null) 'tips': tips,
      if (catalogSource != null) 'catalog_source': catalogSource,
      if (catalogLicense != null) 'catalog_license': catalogLicense,
      if (imageSource != null) 'image_source': imageSource,
      if (imageLicense != null) 'image_license': imageLicense,
      if (alternatives != null) 'alternatives': alternatives,
      if (schulterRisiko != null) 'schulter_risiko': schulterRisiko,
      if (familie != null) 'familie': familie,
      if (griff != null) 'griff': griff,
      if (position != null) 'position': position,
      if (einseitig != null) 'einseitig': einseitig,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? displayUnit,
    Value<int?>? categoryId,
    Value<String?>? image,
    Value<int?>? defaultRestDurationMs,
    Value<String?>? notes,
    Value<String>? graphMetric,
    Value<String>? graphPeriod,
    Value<int>? graphLimit,
    Value<bool>? graphTimeBasedXAxis,
    Value<bool>? archived,
    Value<String?>? germanName,
    Value<String?>? aliases,
    Value<String?>? muscle,
    Value<String?>? catalogId,
    Value<String?>? categoryName,
    Value<String?>? equipment,
    Value<String?>? primaryMuscles,
    Value<String?>? secondaryMuscles,
    Value<String?>? mechanic,
    Value<String?>? steps,
    Value<String?>? tips,
    Value<String?>? catalogSource,
    Value<String?>? catalogLicense,
    Value<String?>? imageSource,
    Value<String?>? imageLicense,
    Value<String?>? alternatives,
    Value<String?>? schulterRisiko,
    Value<String?>? familie,
    Value<String?>? griff,
    Value<String?>? position,
    Value<bool>? einseitig,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      displayUnit: displayUnit ?? this.displayUnit,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      defaultRestDurationMs:
          defaultRestDurationMs ?? this.defaultRestDurationMs,
      notes: notes ?? this.notes,
      graphMetric: graphMetric ?? this.graphMetric,
      graphPeriod: graphPeriod ?? this.graphPeriod,
      graphLimit: graphLimit ?? this.graphLimit,
      graphTimeBasedXAxis: graphTimeBasedXAxis ?? this.graphTimeBasedXAxis,
      archived: archived ?? this.archived,
      germanName: germanName ?? this.germanName,
      aliases: aliases ?? this.aliases,
      muscle: muscle ?? this.muscle,
      catalogId: catalogId ?? this.catalogId,
      categoryName: categoryName ?? this.categoryName,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      mechanic: mechanic ?? this.mechanic,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      catalogSource: catalogSource ?? this.catalogSource,
      catalogLicense: catalogLicense ?? this.catalogLicense,
      imageSource: imageSource ?? this.imageSource,
      imageLicense: imageLicense ?? this.imageLicense,
      alternatives: alternatives ?? this.alternatives,
      schulterRisiko: schulterRisiko ?? this.schulterRisiko,
      familie: familie ?? this.familie,
      griff: griff ?? this.griff,
      position: position ?? this.position,
      einseitig: einseitig ?? this.einseitig,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (displayUnit.present) {
      map['display_unit'] = Variable<String>(displayUnit.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (defaultRestDurationMs.present) {
      map['default_rest_duration_ms'] = Variable<int>(
        defaultRestDurationMs.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (graphMetric.present) {
      map['graph_metric'] = Variable<String>(graphMetric.value);
    }
    if (graphPeriod.present) {
      map['graph_period'] = Variable<String>(graphPeriod.value);
    }
    if (graphLimit.present) {
      map['graph_limit'] = Variable<int>(graphLimit.value);
    }
    if (graphTimeBasedXAxis.present) {
      map['graph_time_based_x_axis'] = Variable<bool>(
        graphTimeBasedXAxis.value,
      );
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (germanName.present) {
      map['german_name'] = Variable<String>(germanName.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (muscle.present) {
      map['muscle'] = Variable<String>(muscle.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (tips.present) {
      map['tips'] = Variable<String>(tips.value);
    }
    if (catalogSource.present) {
      map['catalog_source'] = Variable<String>(catalogSource.value);
    }
    if (catalogLicense.present) {
      map['catalog_license'] = Variable<String>(catalogLicense.value);
    }
    if (imageSource.present) {
      map['image_source'] = Variable<String>(imageSource.value);
    }
    if (imageLicense.present) {
      map['image_license'] = Variable<String>(imageLicense.value);
    }
    if (alternatives.present) {
      map['alternatives'] = Variable<String>(alternatives.value);
    }
    if (schulterRisiko.present) {
      map['schulter_risiko'] = Variable<String>(schulterRisiko.value);
    }
    if (familie.present) {
      map['familie'] = Variable<String>(familie.value);
    }
    if (griff.present) {
      map['griff'] = Variable<String>(griff.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (einseitig.present) {
      map['einseitig'] = Variable<bool>(einseitig.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('displayUnit: $displayUnit, ')
          ..write('categoryId: $categoryId, ')
          ..write('image: $image, ')
          ..write('defaultRestDurationMs: $defaultRestDurationMs, ')
          ..write('notes: $notes, ')
          ..write('graphMetric: $graphMetric, ')
          ..write('graphPeriod: $graphPeriod, ')
          ..write('graphLimit: $graphLimit, ')
          ..write('graphTimeBasedXAxis: $graphTimeBasedXAxis, ')
          ..write('archived: $archived, ')
          ..write('germanName: $germanName, ')
          ..write('aliases: $aliases, ')
          ..write('muscle: $muscle, ')
          ..write('catalogId: $catalogId, ')
          ..write('categoryName: $categoryName, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('mechanic: $mechanic, ')
          ..write('steps: $steps, ')
          ..write('tips: $tips, ')
          ..write('catalogSource: $catalogSource, ')
          ..write('catalogLicense: $catalogLicense, ')
          ..write('imageSource: $imageSource, ')
          ..write('imageLicense: $imageLicense, ')
          ..write('alternatives: $alternatives, ')
          ..write('schulterRisiko: $schulterRisiko, ')
          ..write('familie: $familie, ')
          ..write('griff: $griff, ')
          ..write('position: $position, ')
          ..write('einseitig: $einseitig')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseOrderMeta = const VerificationMeta(
    'exerciseOrder',
  );
  @override
  late final GeneratedColumn<String> exerciseOrder = GeneratedColumn<String>(
    'exercise_order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    startedAt,
    endedAt,
    exerciseOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('exercise_order')) {
      context.handle(
        _exerciseOrderMeta,
        exerciseOrder.isAcceptableOrUnknown(
          data['exercise_order']!,
          _exerciseOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      exerciseOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_order'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final int? planId;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Exercise ids for this session, in the order they were performed.
  /// Null until the session is opened. The plan template is never rewritten.
  final String? exerciseOrder;
  const Workout({
    required this.id,
    this.planId,
    required this.startedAt,
    this.endedAt,
    this.exerciseOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || exerciseOrder != null) {
      map['exercise_order'] = Variable<String>(exerciseOrder);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      exerciseOrder: exerciseOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseOrder),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int?>(json['planId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      exerciseOrder: serializer.fromJson<String?>(json['exerciseOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int?>(planId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'exerciseOrder': serializer.toJson<String?>(exerciseOrder),
    };
  }

  Workout copyWith({
    int? id,
    Value<int?> planId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> exerciseOrder = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    planId: planId.present ? planId.value : this.planId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    exerciseOrder: exerciseOrder.present
        ? exerciseOrder.value
        : this.exerciseOrder,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      exerciseOrder: data.exerciseOrder.present
          ? data.exerciseOrder.value
          : this.exerciseOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('exerciseOrder: $exerciseOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, startedAt, endedAt, exerciseOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.exerciseOrder == this.exerciseOrder);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<int?> planId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> exerciseOrder;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.exerciseOrder = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.exerciseOrder = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? exerciseOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (exerciseOrder != null) 'exercise_order': exerciseOrder,
    });
  }

  WorkoutsCompanion copyWith({
    Value<int>? id,
    Value<int?>? planId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? exerciseOrder,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (exerciseOrder.present) {
      map['exercise_order'] = Variable<String>(exerciseOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('exerciseOrder: $exerciseOrder')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets
    with TableInfo<$ExerciseSetsTable, ExerciseSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<double> reps = GeneratedColumn<double>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loadKgMeta = const VerificationMeta('loadKg');
  @override
  late final GeneratedColumn<double> loadKg = GeneratedColumn<double>(
    'load_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetresMeta = const VerificationMeta(
    'distanceMetres',
  );
  @override
  late final GeneratedColumn<double> distanceMetres = GeneratedColumn<double>(
    'distance_metres',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inclineMeta = const VerificationMeta(
    'incline',
  );
  @override
  late final GeneratedColumn<double> incline = GeneratedColumn<double>(
    'incline',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyWeightKgMeta = const VerificationMeta(
    'bodyWeightKg',
  );
  @override
  late final GeneratedColumn<double> bodyWeightKg = GeneratedColumn<double>(
    'body_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    workoutId,
    timestamp,
    reps,
    loadKg,
    durationMs,
    distanceMetres,
    incline,
    bodyWeightKg,
    notes,
    side,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('load_kg')) {
      context.handle(
        _loadKgMeta,
        loadKg.isAcceptableOrUnknown(data['load_kg']!, _loadKgMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('distance_metres')) {
      context.handle(
        _distanceMetresMeta,
        distanceMetres.isAcceptableOrUnknown(
          data['distance_metres']!,
          _distanceMetresMeta,
        ),
      );
    }
    if (data.containsKey('incline')) {
      context.handle(
        _inclineMeta,
        incline.isAcceptableOrUnknown(data['incline']!, _inclineMeta),
      );
    }
    if (data.containsKey('body_weight_kg')) {
      context.handle(
        _bodyWeightKgMeta,
        bodyWeightKg.isAcceptableOrUnknown(
          data['body_weight_kg']!,
          _bodyWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reps'],
      ),
      loadKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}load_kg'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      distanceMetres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_metres'],
      ),
      incline: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}incline'],
      ),
      bodyWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_weight_kg'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      ),
    );
  }

  @override
  $ExerciseSetsTable createAlias(String alias) {
    return $ExerciseSetsTable(attachedDatabase, alias);
  }
}

class ExerciseSet extends DataClass implements Insertable<ExerciseSet> {
  final int id;
  final int exerciseId;
  final int? workoutId;
  final DateTime timestamp;
  final double? reps;
  final double? loadKg;
  final int? durationMs;
  final double? distanceMetres;
  final double? incline;
  final double? bodyWeightKg;
  final String? notes;
  final String? side;
  const ExerciseSet({
    required this.id,
    required this.exerciseId,
    this.workoutId,
    required this.timestamp,
    this.reps,
    this.loadKg,
    this.durationMs,
    this.distanceMetres,
    this.incline,
    this.bodyWeightKg,
    this.notes,
    this.side,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<int>(workoutId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<double>(reps);
    }
    if (!nullToAbsent || loadKg != null) {
      map['load_kg'] = Variable<double>(loadKg);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || distanceMetres != null) {
      map['distance_metres'] = Variable<double>(distanceMetres);
    }
    if (!nullToAbsent || incline != null) {
      map['incline'] = Variable<double>(incline);
    }
    if (!nullToAbsent || bodyWeightKg != null) {
      map['body_weight_kg'] = Variable<double>(bodyWeightKg);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    return map;
  }

  ExerciseSetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSetsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      timestamp: Value(timestamp),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      loadKg: loadKg == null && nullToAbsent
          ? const Value.absent()
          : Value(loadKg),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      distanceMetres: distanceMetres == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMetres),
      incline: incline == null && nullToAbsent
          ? const Value.absent()
          : Value(incline),
      bodyWeightKg: bodyWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyWeightKg),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
    );
  }

  factory ExerciseSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSet(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      workoutId: serializer.fromJson<int?>(json['workoutId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      reps: serializer.fromJson<double?>(json['reps']),
      loadKg: serializer.fromJson<double?>(json['loadKg']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      distanceMetres: serializer.fromJson<double?>(json['distanceMetres']),
      incline: serializer.fromJson<double?>(json['incline']),
      bodyWeightKg: serializer.fromJson<double?>(json['bodyWeightKg']),
      notes: serializer.fromJson<String?>(json['notes']),
      side: serializer.fromJson<String?>(json['side']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'workoutId': serializer.toJson<int?>(workoutId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'reps': serializer.toJson<double?>(reps),
      'loadKg': serializer.toJson<double?>(loadKg),
      'durationMs': serializer.toJson<int?>(durationMs),
      'distanceMetres': serializer.toJson<double?>(distanceMetres),
      'incline': serializer.toJson<double?>(incline),
      'bodyWeightKg': serializer.toJson<double?>(bodyWeightKg),
      'notes': serializer.toJson<String?>(notes),
      'side': serializer.toJson<String?>(side),
    };
  }

  ExerciseSet copyWith({
    int? id,
    int? exerciseId,
    Value<int?> workoutId = const Value.absent(),
    DateTime? timestamp,
    Value<double?> reps = const Value.absent(),
    Value<double?> loadKg = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<double?> distanceMetres = const Value.absent(),
    Value<double?> incline = const Value.absent(),
    Value<double?> bodyWeightKg = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> side = const Value.absent(),
  }) => ExerciseSet(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    timestamp: timestamp ?? this.timestamp,
    reps: reps.present ? reps.value : this.reps,
    loadKg: loadKg.present ? loadKg.value : this.loadKg,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    distanceMetres: distanceMetres.present
        ? distanceMetres.value
        : this.distanceMetres,
    incline: incline.present ? incline.value : this.incline,
    bodyWeightKg: bodyWeightKg.present ? bodyWeightKg.value : this.bodyWeightKg,
    notes: notes.present ? notes.value : this.notes,
    side: side.present ? side.value : this.side,
  );
  ExerciseSet copyWithCompanion(ExerciseSetsCompanion data) {
    return ExerciseSet(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      reps: data.reps.present ? data.reps.value : this.reps,
      loadKg: data.loadKg.present ? data.loadKg.value : this.loadKg,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      distanceMetres: data.distanceMetres.present
          ? data.distanceMetres.value
          : this.distanceMetres,
      incline: data.incline.present ? data.incline.value : this.incline,
      bodyWeightKg: data.bodyWeightKg.present
          ? data.bodyWeightKg.value
          : this.bodyWeightKg,
      notes: data.notes.present ? data.notes.value : this.notes,
      side: data.side.present ? data.side.value : this.side,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSet(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('timestamp: $timestamp, ')
          ..write('reps: $reps, ')
          ..write('loadKg: $loadKg, ')
          ..write('durationMs: $durationMs, ')
          ..write('distanceMetres: $distanceMetres, ')
          ..write('incline: $incline, ')
          ..write('bodyWeightKg: $bodyWeightKg, ')
          ..write('notes: $notes, ')
          ..write('side: $side')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    workoutId,
    timestamp,
    reps,
    loadKg,
    durationMs,
    distanceMetres,
    incline,
    bodyWeightKg,
    notes,
    side,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSet &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.workoutId == this.workoutId &&
          other.timestamp == this.timestamp &&
          other.reps == this.reps &&
          other.loadKg == this.loadKg &&
          other.durationMs == this.durationMs &&
          other.distanceMetres == this.distanceMetres &&
          other.incline == this.incline &&
          other.bodyWeightKg == this.bodyWeightKg &&
          other.notes == this.notes &&
          other.side == this.side);
}

class ExerciseSetsCompanion extends UpdateCompanion<ExerciseSet> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<int?> workoutId;
  final Value<DateTime> timestamp;
  final Value<double?> reps;
  final Value<double?> loadKg;
  final Value<int?> durationMs;
  final Value<double?> distanceMetres;
  final Value<double?> incline;
  final Value<double?> bodyWeightKg;
  final Value<String?> notes;
  final Value<String?> side;
  const ExerciseSetsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.reps = const Value.absent(),
    this.loadKg = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.distanceMetres = const Value.absent(),
    this.incline = const Value.absent(),
    this.bodyWeightKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.side = const Value.absent(),
  });
  ExerciseSetsCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    this.workoutId = const Value.absent(),
    required DateTime timestamp,
    this.reps = const Value.absent(),
    this.loadKg = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.distanceMetres = const Value.absent(),
    this.incline = const Value.absent(),
    this.bodyWeightKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.side = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       timestamp = Value(timestamp);
  static Insertable<ExerciseSet> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? workoutId,
    Expression<DateTime>? timestamp,
    Expression<double>? reps,
    Expression<double>? loadKg,
    Expression<int>? durationMs,
    Expression<double>? distanceMetres,
    Expression<double>? incline,
    Expression<double>? bodyWeightKg,
    Expression<String>? notes,
    Expression<String>? side,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (workoutId != null) 'workout_id': workoutId,
      if (timestamp != null) 'timestamp': timestamp,
      if (reps != null) 'reps': reps,
      if (loadKg != null) 'load_kg': loadKg,
      if (durationMs != null) 'duration_ms': durationMs,
      if (distanceMetres != null) 'distance_metres': distanceMetres,
      if (incline != null) 'incline': incline,
      if (bodyWeightKg != null) 'body_weight_kg': bodyWeightKg,
      if (notes != null) 'notes': notes,
      if (side != null) 'side': side,
    });
  }

  ExerciseSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<int?>? workoutId,
    Value<DateTime>? timestamp,
    Value<double?>? reps,
    Value<double?>? loadKg,
    Value<int?>? durationMs,
    Value<double?>? distanceMetres,
    Value<double?>? incline,
    Value<double?>? bodyWeightKg,
    Value<String?>? notes,
    Value<String?>? side,
  }) {
    return ExerciseSetsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutId: workoutId ?? this.workoutId,
      timestamp: timestamp ?? this.timestamp,
      reps: reps ?? this.reps,
      loadKg: loadKg ?? this.loadKg,
      durationMs: durationMs ?? this.durationMs,
      distanceMetres: distanceMetres ?? this.distanceMetres,
      incline: incline ?? this.incline,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      notes: notes ?? this.notes,
      side: side ?? this.side,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (reps.present) {
      map['reps'] = Variable<double>(reps.value);
    }
    if (loadKg.present) {
      map['load_kg'] = Variable<double>(loadKg.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (distanceMetres.present) {
      map['distance_metres'] = Variable<double>(distanceMetres.value);
    }
    if (incline.present) {
      map['incline'] = Variable<double>(incline.value);
    }
    if (bodyWeightKg.present) {
      map['body_weight_kg'] = Variable<double>(bodyWeightKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('timestamp: $timestamp, ')
          ..write('reps: $reps, ')
          ..write('loadKg: $loadKg, ')
          ..write('durationMs: $durationMs, ')
          ..write('distanceMetres: $distanceMetres, ')
          ..write('incline: $incline, ')
          ..write('bodyWeightKg: $bodyWeightKg, ')
          ..write('notes: $notes, ')
          ..write('side: $side')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightsTable extends BodyWeights
    with TableInfo<$BodyWeightsTable, BodyWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timestamp, weightKg, photo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weights';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyWeight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      ),
    );
  }

  @override
  $BodyWeightsTable createAlias(String alias) {
    return $BodyWeightsTable(attachedDatabase, alias);
  }
}

class BodyWeight extends DataClass implements Insertable<BodyWeight> {
  final int id;
  final DateTime timestamp;
  final double weightKg;
  final String? photo;
  const BodyWeight({
    required this.id,
    required this.timestamp,
    required this.weightKg,
    this.photo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    return map;
  }

  BodyWeightsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      weightKg: Value(weightKg),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
    );
  }

  factory BodyWeight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeight(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      photo: serializer.fromJson<String?>(json['photo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'weightKg': serializer.toJson<double>(weightKg),
      'photo': serializer.toJson<String?>(photo),
    };
  }

  BodyWeight copyWith({
    int? id,
    DateTime? timestamp,
    double? weightKg,
    Value<String?> photo = const Value.absent(),
  }) => BodyWeight(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    weightKg: weightKg ?? this.weightKg,
    photo: photo.present ? photo.value : this.photo,
  );
  BodyWeight copyWithCompanion(BodyWeightsCompanion data) {
    return BodyWeight(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      photo: data.photo.present ? data.photo.value : this.photo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeight(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('photo: $photo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp, weightKg, photo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeight &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.weightKg == this.weightKg &&
          other.photo == this.photo);
}

class BodyWeightsCompanion extends UpdateCompanion<BodyWeight> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<double> weightKg;
  final Value<String?> photo;
  const BodyWeightsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.photo = const Value.absent(),
  });
  BodyWeightsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required double weightKg,
    this.photo = const Value.absent(),
  }) : timestamp = Value(timestamp),
       weightKg = Value(weightKg);
  static Insertable<BodyWeight> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<double>? weightKg,
    Expression<String>? photo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (weightKg != null) 'weight_kg': weightKg,
      if (photo != null) 'photo': photo,
    });
  }

  BodyWeightsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<double>? weightKg,
    Value<String?>? photo,
  }) {
    return BodyWeightsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      weightKg: weightKg ?? this.weightKg,
      photo: photo ?? this.photo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('photo: $photo')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alarmSoundMeta = const VerificationMeta(
    'alarmSound',
  );
  @override
  late final GeneratedColumn<String> alarmSound = GeneratedColumn<String>(
    'alarm_sound',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _automaticBackupsMeta = const VerificationMeta(
    'automaticBackups',
  );
  @override
  late final GeneratedColumn<bool> automaticBackups = GeneratedColumn<bool>(
    'automatic_backups',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic_backups" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buildNumberMeta = const VerificationMeta(
    'buildNumber',
  );
  @override
  late final GeneratedColumn<int> buildNumber = GeneratedColumn<int>(
    'build_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardioUnitMeta = const VerificationMeta(
    'cardioUnit',
  );
  @override
  late final GeneratedColumn<String> cardioUnit = GeneratedColumn<String>(
    'cardio_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _curveLinesMeta = const VerificationMeta(
    'curveLines',
  );
  @override
  late final GeneratedColumn<bool> curveLines = GeneratedColumn<bool>(
    'curve_lines',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("curve_lines" IN (0, 1))',
    ),
  );
  static const VerificationMeta _curveSmoothnessMeta = const VerificationMeta(
    'curveSmoothness',
  );
  @override
  late final GeneratedColumn<double> curveSmoothness = GeneratedColumn<double>(
    'curve_smoothness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationEstimationMeta =
      const VerificationMeta('durationEstimation');
  @override
  late final GeneratedColumn<bool> durationEstimation = GeneratedColumn<bool>(
    'duration_estimation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_estimation" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableSoundMeta = const VerificationMeta(
    'enableSound',
  );
  @override
  late final GeneratedColumn<bool> enableSound = GeneratedColumn<bool>(
    'enable_sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_sound" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _explainedPermissionsMeta =
      const VerificationMeta('explainedPermissions');
  @override
  late final GeneratedColumn<bool> explainedPermissions = GeneratedColumn<bool>(
    'explained_permissions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explained_permissions" IN (0, 1))',
    ),
  );
  static const VerificationMeta _groupHistoryMeta = const VerificationMeta(
    'groupHistory',
  );
  @override
  late final GeneratedColumn<bool> groupHistory = GeneratedColumn<bool>(
    'group_history',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("group_history" IN (0, 1))',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _longDateFormatMeta = const VerificationMeta(
    'longDateFormat',
  );
  @override
  late final GeneratedColumn<String> longDateFormat = GeneratedColumn<String>(
    'long_date_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeOverrideMeta = const VerificationMeta(
    'localeOverride',
  );
  @override
  late final GeneratedColumn<String> localeOverride = GeneratedColumn<String>(
    'locale_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxSetsMeta = const VerificationMeta(
    'maxSets',
  );
  @override
  late final GeneratedColumn<int> maxSets = GeneratedColumn<int>(
    'max_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsMeta = const VerificationMeta(
    'notifications',
  );
  @override
  late final GeneratedColumn<bool> notifications = GeneratedColumn<bool>(
    'notifications',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationPermissionRequestedMeta =
      const VerificationMeta('notificationPermissionRequested');
  @override
  late final GeneratedColumn<bool> notificationPermissionRequested =
      GeneratedColumn<bool>(
        'notification_permission_requested',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_permission_requested" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _peekGraphMeta = const VerificationMeta(
    'peekGraph',
  );
  @override
  late final GeneratedColumn<bool> peekGraph = GeneratedColumn<bool>(
    'peek_graph',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("peek_graph" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _planTrailingMeta = const VerificationMeta(
    'planTrailing',
  );
  @override
  late final GeneratedColumn<String> planTrailing = GeneratedColumn<String>(
    'plan_trailing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restTimersMeta = const VerificationMeta(
    'restTimers',
  );
  @override
  late final GeneratedColumn<bool> restTimers = GeneratedColumn<bool>(
    'rest_timers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rest_timers" IN (0, 1))',
    ),
  );
  static const VerificationMeta _shortDateFormatMeta = const VerificationMeta(
    'shortDateFormat',
  );
  @override
  late final GeneratedColumn<String> shortDateFormat = GeneratedColumn<String>(
    'short_date_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _showBodyWeightMeta = const VerificationMeta(
    'showBodyWeight',
  );
  @override
  late final GeneratedColumn<bool> showBodyWeight = GeneratedColumn<bool>(
    'show_body_weight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_body_weight" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showCategoriesMeta = const VerificationMeta(
    'showCategories',
  );
  @override
  late final GeneratedColumn<bool> showCategories = GeneratedColumn<bool>(
    'show_categories',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_categories" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showImagesMeta = const VerificationMeta(
    'showImages',
  );
  @override
  late final GeneratedColumn<bool> showImages = GeneratedColumn<bool>(
    'show_images',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_images" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showNotesMeta = const VerificationMeta(
    'showNotes',
  );
  @override
  late final GeneratedColumn<bool> showNotes = GeneratedColumn<bool>(
    'show_notes',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_notes" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showGlobalProgressMeta =
      const VerificationMeta('showGlobalProgress');
  @override
  late final GeneratedColumn<bool> showGlobalProgress = GeneratedColumn<bool>(
    'show_global_progress',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_global_progress" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showUnitsMeta = const VerificationMeta(
    'showUnits',
  );
  @override
  late final GeneratedColumn<bool> showUnits = GeneratedColumn<bool>(
    'show_units',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_units" IN (0, 1))',
    ),
  );
  static const VerificationMeta _strengthUnitMeta = const VerificationMeta(
    'strengthUnit',
  );
  @override
  late final GeneratedColumn<String> strengthUnit = GeneratedColumn<String>(
    'strength_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemColorsMeta = const VerificationMeta(
    'systemColors',
  );
  @override
  late final GeneratedColumn<bool> systemColors = GeneratedColumn<bool>(
    'system_colors',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("system_colors" IN (0, 1))',
    ),
  );
  static const VerificationMeta _tabsMeta = const VerificationMeta('tabs');
  @override
  late final GeneratedColumn<String> tabs = GeneratedColumn<String>(
    'tabs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("HistoryPage,PlansPage,GraphsPage,TimerPage"),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timerDurationMeta = const VerificationMeta(
    'timerDuration',
  );
  @override
  late final GeneratedColumn<int> timerDuration = GeneratedColumn<int>(
    'timer_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
  );
  static const VerificationMeta _warmupSetsMeta = const VerificationMeta(
    'warmupSets',
  );
  @override
  late final GeneratedColumn<int> warmupSets = GeneratedColumn<int>(
    'warmup_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scrollableTabsMeta = const VerificationMeta(
    'scrollableTabs',
  );
  @override
  late final GeneratedColumn<bool> scrollableTabs = GeneratedColumn<bool>(
    'scrollable_tabs',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scrollable_tabs" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showGraphXAxisMeta = const VerificationMeta(
    'showGraphXAxis',
  );
  @override
  late final GeneratedColumn<bool> showGraphXAxis = GeneratedColumn<bool>(
    'show_graph_x_axis',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_graph_x_axis" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showGraphLimitMeta = const VerificationMeta(
    'showGraphLimit',
  );
  @override
  late final GeneratedColumn<bool> showGraphLimit = GeneratedColumn<bool>(
    'show_graph_limit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_graph_limit" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _progressPositionMeta = const VerificationMeta(
    'progressPosition',
  );
  @override
  late final GeneratedColumn<String> progressPosition = GeneratedColumn<String>(
    'progress_position',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("bottom"),
  );
  static const VerificationMeta _defaultGraphMetricMeta =
      const VerificationMeta('defaultGraphMetric');
  @override
  late final GeneratedColumn<String> defaultGraphMetric =
      GeneratedColumn<String>(
        'default_graph_metric',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant("bestWeight"),
      );
  static const VerificationMeta _defaultGraphPeriodMeta =
      const VerificationMeta('defaultGraphPeriod');
  @override
  late final GeneratedColumn<String> defaultGraphPeriod =
      GeneratedColumn<String>(
        'default_graph_period',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant("day"),
      );
  static const VerificationMeta _defaultGraphLimitMeta = const VerificationMeta(
    'defaultGraphLimit',
  );
  @override
  late final GeneratedColumn<int> defaultGraphLimit = GeneratedColumn<int>(
    'default_graph_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _defaultGraphTimeBasedXAxisMeta =
      const VerificationMeta('defaultGraphTimeBasedXAxis');
  @override
  late final GeneratedColumn<bool> defaultGraphTimeBasedXAxis =
      GeneratedColumn<bool>(
        'default_graph_time_based_x_axis',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("default_graph_time_based_x_axis" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _keepRingingMeta = const VerificationMeta(
    'keepRinging',
  );
  @override
  late final GeneratedColumn<bool> keepRinging = GeneratedColumn<bool>(
    'keep_ringing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_ringing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keepScreenOnMeta = const VerificationMeta(
    'keepScreenOn',
  );
  @override
  late final GeneratedColumn<bool> keepScreenOn = GeneratedColumn<bool>(
    'keep_screen_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_screen_on" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inputStyleMeta = const VerificationMeta(
    'inputStyle',
  );
  @override
  late final GeneratedColumn<String> inputStyle = GeneratedColumn<String>(
    'input_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("underline"),
  );
  static const VerificationMeta _profileNameMeta = const VerificationMeta(
    'profileName',
  );
  @override
  late final GeneratedColumn<String> profileName = GeneratedColumn<String>(
    'profile_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalsMeta = const VerificationMeta('goals');
  @override
  late final GeneratedColumn<String> goals = GeneratedColumn<String>(
    'goals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeIdMeta = const VerificationMeta(
    'themeId',
  );
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
    'theme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tiefschwarz'),
  );
  static const VerificationMeta _restVolumeMeta = const VerificationMeta(
    'restVolume',
  );
  @override
  late final GeneratedColumn<double> restVolume = GeneratedColumn<double>(
    'rest_volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.35),
  );
  @override
  List<GeneratedColumn> get $columns => [
    alarmSound,
    automaticBackups,
    backupPath,
    buildNumber,
    cardioUnit,
    curveLines,
    curveSmoothness,
    durationEstimation,
    enableSound,
    explainedPermissions,
    groupHistory,
    id,
    longDateFormat,
    localeOverride,
    maxSets,
    notifications,
    notificationPermissionRequested,
    peekGraph,
    planTrailing,
    restTimers,
    shortDateFormat,
    showBodyWeight,
    showCategories,
    showImages,
    showNotes,
    showGlobalProgress,
    showUnits,
    strengthUnit,
    systemColors,
    tabs,
    themeMode,
    timerDuration,
    vibrate,
    warmupSets,
    scrollableTabs,
    showGraphXAxis,
    showGraphLimit,
    progressPosition,
    defaultGraphMetric,
    defaultGraphPeriod,
    defaultGraphLimit,
    defaultGraphTimeBasedXAxis,
    keepRinging,
    keepScreenOn,
    inputStyle,
    profileName,
    heightCm,
    ageYears,
    goals,
    apiKey,
    themeId,
    restVolume,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alarm_sound')) {
      context.handle(
        _alarmSoundMeta,
        alarmSound.isAcceptableOrUnknown(data['alarm_sound']!, _alarmSoundMeta),
      );
    } else if (isInserting) {
      context.missing(_alarmSoundMeta);
    }
    if (data.containsKey('automatic_backups')) {
      context.handle(
        _automaticBackupsMeta,
        automaticBackups.isAcceptableOrUnknown(
          data['automatic_backups']!,
          _automaticBackupsMeta,
        ),
      );
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    }
    if (data.containsKey('build_number')) {
      context.handle(
        _buildNumberMeta,
        buildNumber.isAcceptableOrUnknown(
          data['build_number']!,
          _buildNumberMeta,
        ),
      );
    }
    if (data.containsKey('cardio_unit')) {
      context.handle(
        _cardioUnitMeta,
        cardioUnit.isAcceptableOrUnknown(data['cardio_unit']!, _cardioUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_cardioUnitMeta);
    }
    if (data.containsKey('curve_lines')) {
      context.handle(
        _curveLinesMeta,
        curveLines.isAcceptableOrUnknown(data['curve_lines']!, _curveLinesMeta),
      );
    } else if (isInserting) {
      context.missing(_curveLinesMeta);
    }
    if (data.containsKey('curve_smoothness')) {
      context.handle(
        _curveSmoothnessMeta,
        curveSmoothness.isAcceptableOrUnknown(
          data['curve_smoothness']!,
          _curveSmoothnessMeta,
        ),
      );
    }
    if (data.containsKey('duration_estimation')) {
      context.handle(
        _durationEstimationMeta,
        durationEstimation.isAcceptableOrUnknown(
          data['duration_estimation']!,
          _durationEstimationMeta,
        ),
      );
    }
    if (data.containsKey('enable_sound')) {
      context.handle(
        _enableSoundMeta,
        enableSound.isAcceptableOrUnknown(
          data['enable_sound']!,
          _enableSoundMeta,
        ),
      );
    }
    if (data.containsKey('explained_permissions')) {
      context.handle(
        _explainedPermissionsMeta,
        explainedPermissions.isAcceptableOrUnknown(
          data['explained_permissions']!,
          _explainedPermissionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explainedPermissionsMeta);
    }
    if (data.containsKey('group_history')) {
      context.handle(
        _groupHistoryMeta,
        groupHistory.isAcceptableOrUnknown(
          data['group_history']!,
          _groupHistoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_groupHistoryMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('long_date_format')) {
      context.handle(
        _longDateFormatMeta,
        longDateFormat.isAcceptableOrUnknown(
          data['long_date_format']!,
          _longDateFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_longDateFormatMeta);
    }
    if (data.containsKey('locale_override')) {
      context.handle(
        _localeOverrideMeta,
        localeOverride.isAcceptableOrUnknown(
          data['locale_override']!,
          _localeOverrideMeta,
        ),
      );
    }
    if (data.containsKey('max_sets')) {
      context.handle(
        _maxSetsMeta,
        maxSets.isAcceptableOrUnknown(data['max_sets']!, _maxSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_maxSetsMeta);
    }
    if (data.containsKey('notifications')) {
      context.handle(
        _notificationsMeta,
        notifications.isAcceptableOrUnknown(
          data['notifications']!,
          _notificationsMeta,
        ),
      );
    }
    if (data.containsKey('notification_permission_requested')) {
      context.handle(
        _notificationPermissionRequestedMeta,
        notificationPermissionRequested.isAcceptableOrUnknown(
          data['notification_permission_requested']!,
          _notificationPermissionRequestedMeta,
        ),
      );
    }
    if (data.containsKey('peek_graph')) {
      context.handle(
        _peekGraphMeta,
        peekGraph.isAcceptableOrUnknown(data['peek_graph']!, _peekGraphMeta),
      );
    }
    if (data.containsKey('plan_trailing')) {
      context.handle(
        _planTrailingMeta,
        planTrailing.isAcceptableOrUnknown(
          data['plan_trailing']!,
          _planTrailingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planTrailingMeta);
    }
    if (data.containsKey('rest_timers')) {
      context.handle(
        _restTimersMeta,
        restTimers.isAcceptableOrUnknown(data['rest_timers']!, _restTimersMeta),
      );
    } else if (isInserting) {
      context.missing(_restTimersMeta);
    }
    if (data.containsKey('short_date_format')) {
      context.handle(
        _shortDateFormatMeta,
        shortDateFormat.isAcceptableOrUnknown(
          data['short_date_format']!,
          _shortDateFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shortDateFormatMeta);
    }
    if (data.containsKey('show_body_weight')) {
      context.handle(
        _showBodyWeightMeta,
        showBodyWeight.isAcceptableOrUnknown(
          data['show_body_weight']!,
          _showBodyWeightMeta,
        ),
      );
    }
    if (data.containsKey('show_categories')) {
      context.handle(
        _showCategoriesMeta,
        showCategories.isAcceptableOrUnknown(
          data['show_categories']!,
          _showCategoriesMeta,
        ),
      );
    }
    if (data.containsKey('show_images')) {
      context.handle(
        _showImagesMeta,
        showImages.isAcceptableOrUnknown(data['show_images']!, _showImagesMeta),
      );
    }
    if (data.containsKey('show_notes')) {
      context.handle(
        _showNotesMeta,
        showNotes.isAcceptableOrUnknown(data['show_notes']!, _showNotesMeta),
      );
    }
    if (data.containsKey('show_global_progress')) {
      context.handle(
        _showGlobalProgressMeta,
        showGlobalProgress.isAcceptableOrUnknown(
          data['show_global_progress']!,
          _showGlobalProgressMeta,
        ),
      );
    }
    if (data.containsKey('show_units')) {
      context.handle(
        _showUnitsMeta,
        showUnits.isAcceptableOrUnknown(data['show_units']!, _showUnitsMeta),
      );
    } else if (isInserting) {
      context.missing(_showUnitsMeta);
    }
    if (data.containsKey('strength_unit')) {
      context.handle(
        _strengthUnitMeta,
        strengthUnit.isAcceptableOrUnknown(
          data['strength_unit']!,
          _strengthUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strengthUnitMeta);
    }
    if (data.containsKey('system_colors')) {
      context.handle(
        _systemColorsMeta,
        systemColors.isAcceptableOrUnknown(
          data['system_colors']!,
          _systemColorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemColorsMeta);
    }
    if (data.containsKey('tabs')) {
      context.handle(
        _tabsMeta,
        tabs.isAcceptableOrUnknown(data['tabs']!, _tabsMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    } else if (isInserting) {
      context.missing(_themeModeMeta);
    }
    if (data.containsKey('timer_duration')) {
      context.handle(
        _timerDurationMeta,
        timerDuration.isAcceptableOrUnknown(
          data['timer_duration']!,
          _timerDurationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timerDurationMeta);
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    } else if (isInserting) {
      context.missing(_vibrateMeta);
    }
    if (data.containsKey('warmup_sets')) {
      context.handle(
        _warmupSetsMeta,
        warmupSets.isAcceptableOrUnknown(data['warmup_sets']!, _warmupSetsMeta),
      );
    }
    if (data.containsKey('scrollable_tabs')) {
      context.handle(
        _scrollableTabsMeta,
        scrollableTabs.isAcceptableOrUnknown(
          data['scrollable_tabs']!,
          _scrollableTabsMeta,
        ),
      );
    }
    if (data.containsKey('show_graph_x_axis')) {
      context.handle(
        _showGraphXAxisMeta,
        showGraphXAxis.isAcceptableOrUnknown(
          data['show_graph_x_axis']!,
          _showGraphXAxisMeta,
        ),
      );
    }
    if (data.containsKey('show_graph_limit')) {
      context.handle(
        _showGraphLimitMeta,
        showGraphLimit.isAcceptableOrUnknown(
          data['show_graph_limit']!,
          _showGraphLimitMeta,
        ),
      );
    }
    if (data.containsKey('progress_position')) {
      context.handle(
        _progressPositionMeta,
        progressPosition.isAcceptableOrUnknown(
          data['progress_position']!,
          _progressPositionMeta,
        ),
      );
    }
    if (data.containsKey('default_graph_metric')) {
      context.handle(
        _defaultGraphMetricMeta,
        defaultGraphMetric.isAcceptableOrUnknown(
          data['default_graph_metric']!,
          _defaultGraphMetricMeta,
        ),
      );
    }
    if (data.containsKey('default_graph_period')) {
      context.handle(
        _defaultGraphPeriodMeta,
        defaultGraphPeriod.isAcceptableOrUnknown(
          data['default_graph_period']!,
          _defaultGraphPeriodMeta,
        ),
      );
    }
    if (data.containsKey('default_graph_limit')) {
      context.handle(
        _defaultGraphLimitMeta,
        defaultGraphLimit.isAcceptableOrUnknown(
          data['default_graph_limit']!,
          _defaultGraphLimitMeta,
        ),
      );
    }
    if (data.containsKey('default_graph_time_based_x_axis')) {
      context.handle(
        _defaultGraphTimeBasedXAxisMeta,
        defaultGraphTimeBasedXAxis.isAcceptableOrUnknown(
          data['default_graph_time_based_x_axis']!,
          _defaultGraphTimeBasedXAxisMeta,
        ),
      );
    }
    if (data.containsKey('keep_ringing')) {
      context.handle(
        _keepRingingMeta,
        keepRinging.isAcceptableOrUnknown(
          data['keep_ringing']!,
          _keepRingingMeta,
        ),
      );
    }
    if (data.containsKey('keep_screen_on')) {
      context.handle(
        _keepScreenOnMeta,
        keepScreenOn.isAcceptableOrUnknown(
          data['keep_screen_on']!,
          _keepScreenOnMeta,
        ),
      );
    }
    if (data.containsKey('input_style')) {
      context.handle(
        _inputStyleMeta,
        inputStyle.isAcceptableOrUnknown(data['input_style']!, _inputStyleMeta),
      );
    }
    if (data.containsKey('profile_name')) {
      context.handle(
        _profileNameMeta,
        profileName.isAcceptableOrUnknown(
          data['profile_name']!,
          _profileNameMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    }
    if (data.containsKey('goals')) {
      context.handle(
        _goalsMeta,
        goals.isAcceptableOrUnknown(data['goals']!, _goalsMeta),
      );
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    }
    if (data.containsKey('theme_id')) {
      context.handle(
        _themeIdMeta,
        themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta),
      );
    }
    if (data.containsKey('rest_volume')) {
      context.handle(
        _restVolumeMeta,
        restVolume.isAcceptableOrUnknown(data['rest_volume']!, _restVolumeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      alarmSound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_sound'],
      )!,
      automaticBackups: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic_backups'],
      )!,
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      ),
      buildNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}build_number'],
      ),
      cardioUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cardio_unit'],
      )!,
      curveLines: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}curve_lines'],
      )!,
      curveSmoothness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}curve_smoothness'],
      ),
      durationEstimation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_estimation'],
      )!,
      enableSound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_sound'],
      )!,
      explainedPermissions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explained_permissions'],
      )!,
      groupHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}group_history'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      longDateFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_date_format'],
      )!,
      localeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_override'],
      ),
      maxSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_sets'],
      )!,
      notifications: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications'],
      )!,
      notificationPermissionRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_permission_requested'],
      )!,
      peekGraph: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}peek_graph'],
      )!,
      planTrailing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_trailing'],
      )!,
      restTimers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rest_timers'],
      )!,
      shortDateFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_date_format'],
      )!,
      showBodyWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_body_weight'],
      )!,
      showCategories: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_categories'],
      )!,
      showImages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_images'],
      )!,
      showNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_notes'],
      )!,
      showGlobalProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_global_progress'],
      )!,
      showUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_units'],
      )!,
      strengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength_unit'],
      )!,
      systemColors: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}system_colors'],
      )!,
      tabs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabs'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      timerDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_duration'],
      )!,
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      warmupSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warmup_sets'],
      ),
      scrollableTabs: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scrollable_tabs'],
      )!,
      showGraphXAxis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_graph_x_axis'],
      )!,
      showGraphLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_graph_limit'],
      )!,
      progressPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progress_position'],
      )!,
      defaultGraphMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_graph_metric'],
      )!,
      defaultGraphPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_graph_period'],
      )!,
      defaultGraphLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_graph_limit'],
      )!,
      defaultGraphTimeBasedXAxis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}default_graph_time_based_x_axis'],
      )!,
      keepRinging: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_ringing'],
      )!,
      keepScreenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_screen_on'],
      )!,
      inputStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_style'],
      )!,
      profileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_name'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      ),
      goals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goals'],
      ),
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      ),
      themeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_id'],
      )!,
      restVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rest_volume'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String alarmSound;
  final bool automaticBackups;
  final String? backupPath;
  final int? buildNumber;
  final String cardioUnit;
  final bool curveLines;
  final double? curveSmoothness;
  final bool durationEstimation;
  final bool enableSound;
  final bool explainedPermissions;
  final bool groupHistory;
  final int id;
  final String longDateFormat;
  final String? localeOverride;
  final int maxSets;
  final bool notifications;
  final bool notificationPermissionRequested;
  final bool peekGraph;
  final String planTrailing;
  final bool restTimers;
  final String shortDateFormat;
  final bool showBodyWeight;
  final bool showCategories;
  final bool showImages;
  final bool showNotes;
  final bool showGlobalProgress;
  final bool showUnits;
  final String strengthUnit;
  final bool systemColors;
  final String tabs;
  final String themeMode;
  final int timerDuration;
  final bool vibrate;
  final int? warmupSets;
  final bool scrollableTabs;
  final bool showGraphXAxis;
  final bool showGraphLimit;
  final String progressPosition;
  final String defaultGraphMetric;
  final String defaultGraphPeriod;
  final int defaultGraphLimit;
  final bool defaultGraphTimeBasedXAxis;
  final bool keepRinging;
  final bool keepScreenOn;
  final String inputStyle;
  final String? profileName;
  final double? heightCm;
  final int? ageYears;
  final String? goals;
  final String? apiKey;
  final String themeId;
  final double restVolume;
  const Setting({
    required this.alarmSound,
    required this.automaticBackups,
    this.backupPath,
    this.buildNumber,
    required this.cardioUnit,
    required this.curveLines,
    this.curveSmoothness,
    required this.durationEstimation,
    required this.enableSound,
    required this.explainedPermissions,
    required this.groupHistory,
    required this.id,
    required this.longDateFormat,
    this.localeOverride,
    required this.maxSets,
    required this.notifications,
    required this.notificationPermissionRequested,
    required this.peekGraph,
    required this.planTrailing,
    required this.restTimers,
    required this.shortDateFormat,
    required this.showBodyWeight,
    required this.showCategories,
    required this.showImages,
    required this.showNotes,
    required this.showGlobalProgress,
    required this.showUnits,
    required this.strengthUnit,
    required this.systemColors,
    required this.tabs,
    required this.themeMode,
    required this.timerDuration,
    required this.vibrate,
    this.warmupSets,
    required this.scrollableTabs,
    required this.showGraphXAxis,
    required this.showGraphLimit,
    required this.progressPosition,
    required this.defaultGraphMetric,
    required this.defaultGraphPeriod,
    required this.defaultGraphLimit,
    required this.defaultGraphTimeBasedXAxis,
    required this.keepRinging,
    required this.keepScreenOn,
    required this.inputStyle,
    this.profileName,
    this.heightCm,
    this.ageYears,
    this.goals,
    this.apiKey,
    required this.themeId,
    required this.restVolume,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alarm_sound'] = Variable<String>(alarmSound);
    map['automatic_backups'] = Variable<bool>(automaticBackups);
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    if (!nullToAbsent || buildNumber != null) {
      map['build_number'] = Variable<int>(buildNumber);
    }
    map['cardio_unit'] = Variable<String>(cardioUnit);
    map['curve_lines'] = Variable<bool>(curveLines);
    if (!nullToAbsent || curveSmoothness != null) {
      map['curve_smoothness'] = Variable<double>(curveSmoothness);
    }
    map['duration_estimation'] = Variable<bool>(durationEstimation);
    map['enable_sound'] = Variable<bool>(enableSound);
    map['explained_permissions'] = Variable<bool>(explainedPermissions);
    map['group_history'] = Variable<bool>(groupHistory);
    map['id'] = Variable<int>(id);
    map['long_date_format'] = Variable<String>(longDateFormat);
    if (!nullToAbsent || localeOverride != null) {
      map['locale_override'] = Variable<String>(localeOverride);
    }
    map['max_sets'] = Variable<int>(maxSets);
    map['notifications'] = Variable<bool>(notifications);
    map['notification_permission_requested'] = Variable<bool>(
      notificationPermissionRequested,
    );
    map['peek_graph'] = Variable<bool>(peekGraph);
    map['plan_trailing'] = Variable<String>(planTrailing);
    map['rest_timers'] = Variable<bool>(restTimers);
    map['short_date_format'] = Variable<String>(shortDateFormat);
    map['show_body_weight'] = Variable<bool>(showBodyWeight);
    map['show_categories'] = Variable<bool>(showCategories);
    map['show_images'] = Variable<bool>(showImages);
    map['show_notes'] = Variable<bool>(showNotes);
    map['show_global_progress'] = Variable<bool>(showGlobalProgress);
    map['show_units'] = Variable<bool>(showUnits);
    map['strength_unit'] = Variable<String>(strengthUnit);
    map['system_colors'] = Variable<bool>(systemColors);
    map['tabs'] = Variable<String>(tabs);
    map['theme_mode'] = Variable<String>(themeMode);
    map['timer_duration'] = Variable<int>(timerDuration);
    map['vibrate'] = Variable<bool>(vibrate);
    if (!nullToAbsent || warmupSets != null) {
      map['warmup_sets'] = Variable<int>(warmupSets);
    }
    map['scrollable_tabs'] = Variable<bool>(scrollableTabs);
    map['show_graph_x_axis'] = Variable<bool>(showGraphXAxis);
    map['show_graph_limit'] = Variable<bool>(showGraphLimit);
    map['progress_position'] = Variable<String>(progressPosition);
    map['default_graph_metric'] = Variable<String>(defaultGraphMetric);
    map['default_graph_period'] = Variable<String>(defaultGraphPeriod);
    map['default_graph_limit'] = Variable<int>(defaultGraphLimit);
    map['default_graph_time_based_x_axis'] = Variable<bool>(
      defaultGraphTimeBasedXAxis,
    );
    map['keep_ringing'] = Variable<bool>(keepRinging);
    map['keep_screen_on'] = Variable<bool>(keepScreenOn);
    map['input_style'] = Variable<String>(inputStyle);
    if (!nullToAbsent || profileName != null) {
      map['profile_name'] = Variable<String>(profileName);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || ageYears != null) {
      map['age_years'] = Variable<int>(ageYears);
    }
    if (!nullToAbsent || goals != null) {
      map['goals'] = Variable<String>(goals);
    }
    if (!nullToAbsent || apiKey != null) {
      map['api_key'] = Variable<String>(apiKey);
    }
    map['theme_id'] = Variable<String>(themeId);
    map['rest_volume'] = Variable<double>(restVolume);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      alarmSound: Value(alarmSound),
      automaticBackups: Value(automaticBackups),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      buildNumber: buildNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(buildNumber),
      cardioUnit: Value(cardioUnit),
      curveLines: Value(curveLines),
      curveSmoothness: curveSmoothness == null && nullToAbsent
          ? const Value.absent()
          : Value(curveSmoothness),
      durationEstimation: Value(durationEstimation),
      enableSound: Value(enableSound),
      explainedPermissions: Value(explainedPermissions),
      groupHistory: Value(groupHistory),
      id: Value(id),
      longDateFormat: Value(longDateFormat),
      localeOverride: localeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(localeOverride),
      maxSets: Value(maxSets),
      notifications: Value(notifications),
      notificationPermissionRequested: Value(notificationPermissionRequested),
      peekGraph: Value(peekGraph),
      planTrailing: Value(planTrailing),
      restTimers: Value(restTimers),
      shortDateFormat: Value(shortDateFormat),
      showBodyWeight: Value(showBodyWeight),
      showCategories: Value(showCategories),
      showImages: Value(showImages),
      showNotes: Value(showNotes),
      showGlobalProgress: Value(showGlobalProgress),
      showUnits: Value(showUnits),
      strengthUnit: Value(strengthUnit),
      systemColors: Value(systemColors),
      tabs: Value(tabs),
      themeMode: Value(themeMode),
      timerDuration: Value(timerDuration),
      vibrate: Value(vibrate),
      warmupSets: warmupSets == null && nullToAbsent
          ? const Value.absent()
          : Value(warmupSets),
      scrollableTabs: Value(scrollableTabs),
      showGraphXAxis: Value(showGraphXAxis),
      showGraphLimit: Value(showGraphLimit),
      progressPosition: Value(progressPosition),
      defaultGraphMetric: Value(defaultGraphMetric),
      defaultGraphPeriod: Value(defaultGraphPeriod),
      defaultGraphLimit: Value(defaultGraphLimit),
      defaultGraphTimeBasedXAxis: Value(defaultGraphTimeBasedXAxis),
      keepRinging: Value(keepRinging),
      keepScreenOn: Value(keepScreenOn),
      inputStyle: Value(inputStyle),
      profileName: profileName == null && nullToAbsent
          ? const Value.absent()
          : Value(profileName),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      ageYears: ageYears == null && nullToAbsent
          ? const Value.absent()
          : Value(ageYears),
      goals: goals == null && nullToAbsent
          ? const Value.absent()
          : Value(goals),
      apiKey: apiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(apiKey),
      themeId: Value(themeId),
      restVolume: Value(restVolume),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      alarmSound: serializer.fromJson<String>(json['alarmSound']),
      automaticBackups: serializer.fromJson<bool>(json['automaticBackups']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      buildNumber: serializer.fromJson<int?>(json['buildNumber']),
      cardioUnit: serializer.fromJson<String>(json['cardioUnit']),
      curveLines: serializer.fromJson<bool>(json['curveLines']),
      curveSmoothness: serializer.fromJson<double?>(json['curveSmoothness']),
      durationEstimation: serializer.fromJson<bool>(json['durationEstimation']),
      enableSound: serializer.fromJson<bool>(json['enableSound']),
      explainedPermissions: serializer.fromJson<bool>(
        json['explainedPermissions'],
      ),
      groupHistory: serializer.fromJson<bool>(json['groupHistory']),
      id: serializer.fromJson<int>(json['id']),
      longDateFormat: serializer.fromJson<String>(json['longDateFormat']),
      localeOverride: serializer.fromJson<String?>(json['localeOverride']),
      maxSets: serializer.fromJson<int>(json['maxSets']),
      notifications: serializer.fromJson<bool>(json['notifications']),
      notificationPermissionRequested: serializer.fromJson<bool>(
        json['notificationPermissionRequested'],
      ),
      peekGraph: serializer.fromJson<bool>(json['peekGraph']),
      planTrailing: serializer.fromJson<String>(json['planTrailing']),
      restTimers: serializer.fromJson<bool>(json['restTimers']),
      shortDateFormat: serializer.fromJson<String>(json['shortDateFormat']),
      showBodyWeight: serializer.fromJson<bool>(json['showBodyWeight']),
      showCategories: serializer.fromJson<bool>(json['showCategories']),
      showImages: serializer.fromJson<bool>(json['showImages']),
      showNotes: serializer.fromJson<bool>(json['showNotes']),
      showGlobalProgress: serializer.fromJson<bool>(json['showGlobalProgress']),
      showUnits: serializer.fromJson<bool>(json['showUnits']),
      strengthUnit: serializer.fromJson<String>(json['strengthUnit']),
      systemColors: serializer.fromJson<bool>(json['systemColors']),
      tabs: serializer.fromJson<String>(json['tabs']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      timerDuration: serializer.fromJson<int>(json['timerDuration']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      warmupSets: serializer.fromJson<int?>(json['warmupSets']),
      scrollableTabs: serializer.fromJson<bool>(json['scrollableTabs']),
      showGraphXAxis: serializer.fromJson<bool>(json['showGraphXAxis']),
      showGraphLimit: serializer.fromJson<bool>(json['showGraphLimit']),
      progressPosition: serializer.fromJson<String>(json['progressPosition']),
      defaultGraphMetric: serializer.fromJson<String>(
        json['defaultGraphMetric'],
      ),
      defaultGraphPeriod: serializer.fromJson<String>(
        json['defaultGraphPeriod'],
      ),
      defaultGraphLimit: serializer.fromJson<int>(json['defaultGraphLimit']),
      defaultGraphTimeBasedXAxis: serializer.fromJson<bool>(
        json['defaultGraphTimeBasedXAxis'],
      ),
      keepRinging: serializer.fromJson<bool>(json['keepRinging']),
      keepScreenOn: serializer.fromJson<bool>(json['keepScreenOn']),
      inputStyle: serializer.fromJson<String>(json['inputStyle']),
      profileName: serializer.fromJson<String?>(json['profileName']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      ageYears: serializer.fromJson<int?>(json['ageYears']),
      goals: serializer.fromJson<String?>(json['goals']),
      apiKey: serializer.fromJson<String?>(json['apiKey']),
      themeId: serializer.fromJson<String>(json['themeId']),
      restVolume: serializer.fromJson<double>(json['restVolume']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alarmSound': serializer.toJson<String>(alarmSound),
      'automaticBackups': serializer.toJson<bool>(automaticBackups),
      'backupPath': serializer.toJson<String?>(backupPath),
      'buildNumber': serializer.toJson<int?>(buildNumber),
      'cardioUnit': serializer.toJson<String>(cardioUnit),
      'curveLines': serializer.toJson<bool>(curveLines),
      'curveSmoothness': serializer.toJson<double?>(curveSmoothness),
      'durationEstimation': serializer.toJson<bool>(durationEstimation),
      'enableSound': serializer.toJson<bool>(enableSound),
      'explainedPermissions': serializer.toJson<bool>(explainedPermissions),
      'groupHistory': serializer.toJson<bool>(groupHistory),
      'id': serializer.toJson<int>(id),
      'longDateFormat': serializer.toJson<String>(longDateFormat),
      'localeOverride': serializer.toJson<String?>(localeOverride),
      'maxSets': serializer.toJson<int>(maxSets),
      'notifications': serializer.toJson<bool>(notifications),
      'notificationPermissionRequested': serializer.toJson<bool>(
        notificationPermissionRequested,
      ),
      'peekGraph': serializer.toJson<bool>(peekGraph),
      'planTrailing': serializer.toJson<String>(planTrailing),
      'restTimers': serializer.toJson<bool>(restTimers),
      'shortDateFormat': serializer.toJson<String>(shortDateFormat),
      'showBodyWeight': serializer.toJson<bool>(showBodyWeight),
      'showCategories': serializer.toJson<bool>(showCategories),
      'showImages': serializer.toJson<bool>(showImages),
      'showNotes': serializer.toJson<bool>(showNotes),
      'showGlobalProgress': serializer.toJson<bool>(showGlobalProgress),
      'showUnits': serializer.toJson<bool>(showUnits),
      'strengthUnit': serializer.toJson<String>(strengthUnit),
      'systemColors': serializer.toJson<bool>(systemColors),
      'tabs': serializer.toJson<String>(tabs),
      'themeMode': serializer.toJson<String>(themeMode),
      'timerDuration': serializer.toJson<int>(timerDuration),
      'vibrate': serializer.toJson<bool>(vibrate),
      'warmupSets': serializer.toJson<int?>(warmupSets),
      'scrollableTabs': serializer.toJson<bool>(scrollableTabs),
      'showGraphXAxis': serializer.toJson<bool>(showGraphXAxis),
      'showGraphLimit': serializer.toJson<bool>(showGraphLimit),
      'progressPosition': serializer.toJson<String>(progressPosition),
      'defaultGraphMetric': serializer.toJson<String>(defaultGraphMetric),
      'defaultGraphPeriod': serializer.toJson<String>(defaultGraphPeriod),
      'defaultGraphLimit': serializer.toJson<int>(defaultGraphLimit),
      'defaultGraphTimeBasedXAxis': serializer.toJson<bool>(
        defaultGraphTimeBasedXAxis,
      ),
      'keepRinging': serializer.toJson<bool>(keepRinging),
      'keepScreenOn': serializer.toJson<bool>(keepScreenOn),
      'inputStyle': serializer.toJson<String>(inputStyle),
      'profileName': serializer.toJson<String?>(profileName),
      'heightCm': serializer.toJson<double?>(heightCm),
      'ageYears': serializer.toJson<int?>(ageYears),
      'goals': serializer.toJson<String?>(goals),
      'apiKey': serializer.toJson<String?>(apiKey),
      'themeId': serializer.toJson<String>(themeId),
      'restVolume': serializer.toJson<double>(restVolume),
    };
  }

  Setting copyWith({
    String? alarmSound,
    bool? automaticBackups,
    Value<String?> backupPath = const Value.absent(),
    Value<int?> buildNumber = const Value.absent(),
    String? cardioUnit,
    bool? curveLines,
    Value<double?> curveSmoothness = const Value.absent(),
    bool? durationEstimation,
    bool? enableSound,
    bool? explainedPermissions,
    bool? groupHistory,
    int? id,
    String? longDateFormat,
    Value<String?> localeOverride = const Value.absent(),
    int? maxSets,
    bool? notifications,
    bool? notificationPermissionRequested,
    bool? peekGraph,
    String? planTrailing,
    bool? restTimers,
    String? shortDateFormat,
    bool? showBodyWeight,
    bool? showCategories,
    bool? showImages,
    bool? showNotes,
    bool? showGlobalProgress,
    bool? showUnits,
    String? strengthUnit,
    bool? systemColors,
    String? tabs,
    String? themeMode,
    int? timerDuration,
    bool? vibrate,
    Value<int?> warmupSets = const Value.absent(),
    bool? scrollableTabs,
    bool? showGraphXAxis,
    bool? showGraphLimit,
    String? progressPosition,
    String? defaultGraphMetric,
    String? defaultGraphPeriod,
    int? defaultGraphLimit,
    bool? defaultGraphTimeBasedXAxis,
    bool? keepRinging,
    bool? keepScreenOn,
    String? inputStyle,
    Value<String?> profileName = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<int?> ageYears = const Value.absent(),
    Value<String?> goals = const Value.absent(),
    Value<String?> apiKey = const Value.absent(),
    String? themeId,
    double? restVolume,
  }) => Setting(
    alarmSound: alarmSound ?? this.alarmSound,
    automaticBackups: automaticBackups ?? this.automaticBackups,
    backupPath: backupPath.present ? backupPath.value : this.backupPath,
    buildNumber: buildNumber.present ? buildNumber.value : this.buildNumber,
    cardioUnit: cardioUnit ?? this.cardioUnit,
    curveLines: curveLines ?? this.curveLines,
    curveSmoothness: curveSmoothness.present
        ? curveSmoothness.value
        : this.curveSmoothness,
    durationEstimation: durationEstimation ?? this.durationEstimation,
    enableSound: enableSound ?? this.enableSound,
    explainedPermissions: explainedPermissions ?? this.explainedPermissions,
    groupHistory: groupHistory ?? this.groupHistory,
    id: id ?? this.id,
    longDateFormat: longDateFormat ?? this.longDateFormat,
    localeOverride: localeOverride.present
        ? localeOverride.value
        : this.localeOverride,
    maxSets: maxSets ?? this.maxSets,
    notifications: notifications ?? this.notifications,
    notificationPermissionRequested:
        notificationPermissionRequested ?? this.notificationPermissionRequested,
    peekGraph: peekGraph ?? this.peekGraph,
    planTrailing: planTrailing ?? this.planTrailing,
    restTimers: restTimers ?? this.restTimers,
    shortDateFormat: shortDateFormat ?? this.shortDateFormat,
    showBodyWeight: showBodyWeight ?? this.showBodyWeight,
    showCategories: showCategories ?? this.showCategories,
    showImages: showImages ?? this.showImages,
    showNotes: showNotes ?? this.showNotes,
    showGlobalProgress: showGlobalProgress ?? this.showGlobalProgress,
    showUnits: showUnits ?? this.showUnits,
    strengthUnit: strengthUnit ?? this.strengthUnit,
    systemColors: systemColors ?? this.systemColors,
    tabs: tabs ?? this.tabs,
    themeMode: themeMode ?? this.themeMode,
    timerDuration: timerDuration ?? this.timerDuration,
    vibrate: vibrate ?? this.vibrate,
    warmupSets: warmupSets.present ? warmupSets.value : this.warmupSets,
    scrollableTabs: scrollableTabs ?? this.scrollableTabs,
    showGraphXAxis: showGraphXAxis ?? this.showGraphXAxis,
    showGraphLimit: showGraphLimit ?? this.showGraphLimit,
    progressPosition: progressPosition ?? this.progressPosition,
    defaultGraphMetric: defaultGraphMetric ?? this.defaultGraphMetric,
    defaultGraphPeriod: defaultGraphPeriod ?? this.defaultGraphPeriod,
    defaultGraphLimit: defaultGraphLimit ?? this.defaultGraphLimit,
    defaultGraphTimeBasedXAxis:
        defaultGraphTimeBasedXAxis ?? this.defaultGraphTimeBasedXAxis,
    keepRinging: keepRinging ?? this.keepRinging,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    inputStyle: inputStyle ?? this.inputStyle,
    profileName: profileName.present ? profileName.value : this.profileName,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    ageYears: ageYears.present ? ageYears.value : this.ageYears,
    goals: goals.present ? goals.value : this.goals,
    apiKey: apiKey.present ? apiKey.value : this.apiKey,
    themeId: themeId ?? this.themeId,
    restVolume: restVolume ?? this.restVolume,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      alarmSound: data.alarmSound.present
          ? data.alarmSound.value
          : this.alarmSound,
      automaticBackups: data.automaticBackups.present
          ? data.automaticBackups.value
          : this.automaticBackups,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      buildNumber: data.buildNumber.present
          ? data.buildNumber.value
          : this.buildNumber,
      cardioUnit: data.cardioUnit.present
          ? data.cardioUnit.value
          : this.cardioUnit,
      curveLines: data.curveLines.present
          ? data.curveLines.value
          : this.curveLines,
      curveSmoothness: data.curveSmoothness.present
          ? data.curveSmoothness.value
          : this.curveSmoothness,
      durationEstimation: data.durationEstimation.present
          ? data.durationEstimation.value
          : this.durationEstimation,
      enableSound: data.enableSound.present
          ? data.enableSound.value
          : this.enableSound,
      explainedPermissions: data.explainedPermissions.present
          ? data.explainedPermissions.value
          : this.explainedPermissions,
      groupHistory: data.groupHistory.present
          ? data.groupHistory.value
          : this.groupHistory,
      id: data.id.present ? data.id.value : this.id,
      longDateFormat: data.longDateFormat.present
          ? data.longDateFormat.value
          : this.longDateFormat,
      localeOverride: data.localeOverride.present
          ? data.localeOverride.value
          : this.localeOverride,
      maxSets: data.maxSets.present ? data.maxSets.value : this.maxSets,
      notifications: data.notifications.present
          ? data.notifications.value
          : this.notifications,
      notificationPermissionRequested:
          data.notificationPermissionRequested.present
          ? data.notificationPermissionRequested.value
          : this.notificationPermissionRequested,
      peekGraph: data.peekGraph.present ? data.peekGraph.value : this.peekGraph,
      planTrailing: data.planTrailing.present
          ? data.planTrailing.value
          : this.planTrailing,
      restTimers: data.restTimers.present
          ? data.restTimers.value
          : this.restTimers,
      shortDateFormat: data.shortDateFormat.present
          ? data.shortDateFormat.value
          : this.shortDateFormat,
      showBodyWeight: data.showBodyWeight.present
          ? data.showBodyWeight.value
          : this.showBodyWeight,
      showCategories: data.showCategories.present
          ? data.showCategories.value
          : this.showCategories,
      showImages: data.showImages.present
          ? data.showImages.value
          : this.showImages,
      showNotes: data.showNotes.present ? data.showNotes.value : this.showNotes,
      showGlobalProgress: data.showGlobalProgress.present
          ? data.showGlobalProgress.value
          : this.showGlobalProgress,
      showUnits: data.showUnits.present ? data.showUnits.value : this.showUnits,
      strengthUnit: data.strengthUnit.present
          ? data.strengthUnit.value
          : this.strengthUnit,
      systemColors: data.systemColors.present
          ? data.systemColors.value
          : this.systemColors,
      tabs: data.tabs.present ? data.tabs.value : this.tabs,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      timerDuration: data.timerDuration.present
          ? data.timerDuration.value
          : this.timerDuration,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      warmupSets: data.warmupSets.present
          ? data.warmupSets.value
          : this.warmupSets,
      scrollableTabs: data.scrollableTabs.present
          ? data.scrollableTabs.value
          : this.scrollableTabs,
      showGraphXAxis: data.showGraphXAxis.present
          ? data.showGraphXAxis.value
          : this.showGraphXAxis,
      showGraphLimit: data.showGraphLimit.present
          ? data.showGraphLimit.value
          : this.showGraphLimit,
      progressPosition: data.progressPosition.present
          ? data.progressPosition.value
          : this.progressPosition,
      defaultGraphMetric: data.defaultGraphMetric.present
          ? data.defaultGraphMetric.value
          : this.defaultGraphMetric,
      defaultGraphPeriod: data.defaultGraphPeriod.present
          ? data.defaultGraphPeriod.value
          : this.defaultGraphPeriod,
      defaultGraphLimit: data.defaultGraphLimit.present
          ? data.defaultGraphLimit.value
          : this.defaultGraphLimit,
      defaultGraphTimeBasedXAxis: data.defaultGraphTimeBasedXAxis.present
          ? data.defaultGraphTimeBasedXAxis.value
          : this.defaultGraphTimeBasedXAxis,
      keepRinging: data.keepRinging.present
          ? data.keepRinging.value
          : this.keepRinging,
      keepScreenOn: data.keepScreenOn.present
          ? data.keepScreenOn.value
          : this.keepScreenOn,
      inputStyle: data.inputStyle.present
          ? data.inputStyle.value
          : this.inputStyle,
      profileName: data.profileName.present
          ? data.profileName.value
          : this.profileName,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      goals: data.goals.present ? data.goals.value : this.goals,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      restVolume: data.restVolume.present
          ? data.restVolume.value
          : this.restVolume,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('alarmSound: $alarmSound, ')
          ..write('automaticBackups: $automaticBackups, ')
          ..write('backupPath: $backupPath, ')
          ..write('buildNumber: $buildNumber, ')
          ..write('cardioUnit: $cardioUnit, ')
          ..write('curveLines: $curveLines, ')
          ..write('curveSmoothness: $curveSmoothness, ')
          ..write('durationEstimation: $durationEstimation, ')
          ..write('enableSound: $enableSound, ')
          ..write('explainedPermissions: $explainedPermissions, ')
          ..write('groupHistory: $groupHistory, ')
          ..write('id: $id, ')
          ..write('longDateFormat: $longDateFormat, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('maxSets: $maxSets, ')
          ..write('notifications: $notifications, ')
          ..write(
            'notificationPermissionRequested: $notificationPermissionRequested, ',
          )
          ..write('peekGraph: $peekGraph, ')
          ..write('planTrailing: $planTrailing, ')
          ..write('restTimers: $restTimers, ')
          ..write('shortDateFormat: $shortDateFormat, ')
          ..write('showBodyWeight: $showBodyWeight, ')
          ..write('showCategories: $showCategories, ')
          ..write('showImages: $showImages, ')
          ..write('showNotes: $showNotes, ')
          ..write('showGlobalProgress: $showGlobalProgress, ')
          ..write('showUnits: $showUnits, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('systemColors: $systemColors, ')
          ..write('tabs: $tabs, ')
          ..write('themeMode: $themeMode, ')
          ..write('timerDuration: $timerDuration, ')
          ..write('vibrate: $vibrate, ')
          ..write('warmupSets: $warmupSets, ')
          ..write('scrollableTabs: $scrollableTabs, ')
          ..write('showGraphXAxis: $showGraphXAxis, ')
          ..write('showGraphLimit: $showGraphLimit, ')
          ..write('progressPosition: $progressPosition, ')
          ..write('defaultGraphMetric: $defaultGraphMetric, ')
          ..write('defaultGraphPeriod: $defaultGraphPeriod, ')
          ..write('defaultGraphLimit: $defaultGraphLimit, ')
          ..write('defaultGraphTimeBasedXAxis: $defaultGraphTimeBasedXAxis, ')
          ..write('keepRinging: $keepRinging, ')
          ..write('keepScreenOn: $keepScreenOn, ')
          ..write('inputStyle: $inputStyle, ')
          ..write('profileName: $profileName, ')
          ..write('heightCm: $heightCm, ')
          ..write('ageYears: $ageYears, ')
          ..write('goals: $goals, ')
          ..write('apiKey: $apiKey, ')
          ..write('themeId: $themeId, ')
          ..write('restVolume: $restVolume')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    alarmSound,
    automaticBackups,
    backupPath,
    buildNumber,
    cardioUnit,
    curveLines,
    curveSmoothness,
    durationEstimation,
    enableSound,
    explainedPermissions,
    groupHistory,
    id,
    longDateFormat,
    localeOverride,
    maxSets,
    notifications,
    notificationPermissionRequested,
    peekGraph,
    planTrailing,
    restTimers,
    shortDateFormat,
    showBodyWeight,
    showCategories,
    showImages,
    showNotes,
    showGlobalProgress,
    showUnits,
    strengthUnit,
    systemColors,
    tabs,
    themeMode,
    timerDuration,
    vibrate,
    warmupSets,
    scrollableTabs,
    showGraphXAxis,
    showGraphLimit,
    progressPosition,
    defaultGraphMetric,
    defaultGraphPeriod,
    defaultGraphLimit,
    defaultGraphTimeBasedXAxis,
    keepRinging,
    keepScreenOn,
    inputStyle,
    profileName,
    heightCm,
    ageYears,
    goals,
    apiKey,
    themeId,
    restVolume,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.alarmSound == this.alarmSound &&
          other.automaticBackups == this.automaticBackups &&
          other.backupPath == this.backupPath &&
          other.buildNumber == this.buildNumber &&
          other.cardioUnit == this.cardioUnit &&
          other.curveLines == this.curveLines &&
          other.curveSmoothness == this.curveSmoothness &&
          other.durationEstimation == this.durationEstimation &&
          other.enableSound == this.enableSound &&
          other.explainedPermissions == this.explainedPermissions &&
          other.groupHistory == this.groupHistory &&
          other.id == this.id &&
          other.longDateFormat == this.longDateFormat &&
          other.localeOverride == this.localeOverride &&
          other.maxSets == this.maxSets &&
          other.notifications == this.notifications &&
          other.notificationPermissionRequested ==
              this.notificationPermissionRequested &&
          other.peekGraph == this.peekGraph &&
          other.planTrailing == this.planTrailing &&
          other.restTimers == this.restTimers &&
          other.shortDateFormat == this.shortDateFormat &&
          other.showBodyWeight == this.showBodyWeight &&
          other.showCategories == this.showCategories &&
          other.showImages == this.showImages &&
          other.showNotes == this.showNotes &&
          other.showGlobalProgress == this.showGlobalProgress &&
          other.showUnits == this.showUnits &&
          other.strengthUnit == this.strengthUnit &&
          other.systemColors == this.systemColors &&
          other.tabs == this.tabs &&
          other.themeMode == this.themeMode &&
          other.timerDuration == this.timerDuration &&
          other.vibrate == this.vibrate &&
          other.warmupSets == this.warmupSets &&
          other.scrollableTabs == this.scrollableTabs &&
          other.showGraphXAxis == this.showGraphXAxis &&
          other.showGraphLimit == this.showGraphLimit &&
          other.progressPosition == this.progressPosition &&
          other.defaultGraphMetric == this.defaultGraphMetric &&
          other.defaultGraphPeriod == this.defaultGraphPeriod &&
          other.defaultGraphLimit == this.defaultGraphLimit &&
          other.defaultGraphTimeBasedXAxis == this.defaultGraphTimeBasedXAxis &&
          other.keepRinging == this.keepRinging &&
          other.keepScreenOn == this.keepScreenOn &&
          other.inputStyle == this.inputStyle &&
          other.profileName == this.profileName &&
          other.heightCm == this.heightCm &&
          other.ageYears == this.ageYears &&
          other.goals == this.goals &&
          other.apiKey == this.apiKey &&
          other.themeId == this.themeId &&
          other.restVolume == this.restVolume);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> alarmSound;
  final Value<bool> automaticBackups;
  final Value<String?> backupPath;
  final Value<int?> buildNumber;
  final Value<String> cardioUnit;
  final Value<bool> curveLines;
  final Value<double?> curveSmoothness;
  final Value<bool> durationEstimation;
  final Value<bool> enableSound;
  final Value<bool> explainedPermissions;
  final Value<bool> groupHistory;
  final Value<int> id;
  final Value<String> longDateFormat;
  final Value<String?> localeOverride;
  final Value<int> maxSets;
  final Value<bool> notifications;
  final Value<bool> notificationPermissionRequested;
  final Value<bool> peekGraph;
  final Value<String> planTrailing;
  final Value<bool> restTimers;
  final Value<String> shortDateFormat;
  final Value<bool> showBodyWeight;
  final Value<bool> showCategories;
  final Value<bool> showImages;
  final Value<bool> showNotes;
  final Value<bool> showGlobalProgress;
  final Value<bool> showUnits;
  final Value<String> strengthUnit;
  final Value<bool> systemColors;
  final Value<String> tabs;
  final Value<String> themeMode;
  final Value<int> timerDuration;
  final Value<bool> vibrate;
  final Value<int?> warmupSets;
  final Value<bool> scrollableTabs;
  final Value<bool> showGraphXAxis;
  final Value<bool> showGraphLimit;
  final Value<String> progressPosition;
  final Value<String> defaultGraphMetric;
  final Value<String> defaultGraphPeriod;
  final Value<int> defaultGraphLimit;
  final Value<bool> defaultGraphTimeBasedXAxis;
  final Value<bool> keepRinging;
  final Value<bool> keepScreenOn;
  final Value<String> inputStyle;
  final Value<String?> profileName;
  final Value<double?> heightCm;
  final Value<int?> ageYears;
  final Value<String?> goals;
  final Value<String?> apiKey;
  final Value<String> themeId;
  final Value<double> restVolume;
  const SettingsCompanion({
    this.alarmSound = const Value.absent(),
    this.automaticBackups = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.buildNumber = const Value.absent(),
    this.cardioUnit = const Value.absent(),
    this.curveLines = const Value.absent(),
    this.curveSmoothness = const Value.absent(),
    this.durationEstimation = const Value.absent(),
    this.enableSound = const Value.absent(),
    this.explainedPermissions = const Value.absent(),
    this.groupHistory = const Value.absent(),
    this.id = const Value.absent(),
    this.longDateFormat = const Value.absent(),
    this.localeOverride = const Value.absent(),
    this.maxSets = const Value.absent(),
    this.notifications = const Value.absent(),
    this.notificationPermissionRequested = const Value.absent(),
    this.peekGraph = const Value.absent(),
    this.planTrailing = const Value.absent(),
    this.restTimers = const Value.absent(),
    this.shortDateFormat = const Value.absent(),
    this.showBodyWeight = const Value.absent(),
    this.showCategories = const Value.absent(),
    this.showImages = const Value.absent(),
    this.showNotes = const Value.absent(),
    this.showGlobalProgress = const Value.absent(),
    this.showUnits = const Value.absent(),
    this.strengthUnit = const Value.absent(),
    this.systemColors = const Value.absent(),
    this.tabs = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.timerDuration = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.warmupSets = const Value.absent(),
    this.scrollableTabs = const Value.absent(),
    this.showGraphXAxis = const Value.absent(),
    this.showGraphLimit = const Value.absent(),
    this.progressPosition = const Value.absent(),
    this.defaultGraphMetric = const Value.absent(),
    this.defaultGraphPeriod = const Value.absent(),
    this.defaultGraphLimit = const Value.absent(),
    this.defaultGraphTimeBasedXAxis = const Value.absent(),
    this.keepRinging = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
    this.inputStyle = const Value.absent(),
    this.profileName = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.goals = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.themeId = const Value.absent(),
    this.restVolume = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String alarmSound,
    this.automaticBackups = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.buildNumber = const Value.absent(),
    required String cardioUnit,
    required bool curveLines,
    this.curveSmoothness = const Value.absent(),
    this.durationEstimation = const Value.absent(),
    this.enableSound = const Value.absent(),
    required bool explainedPermissions,
    required bool groupHistory,
    this.id = const Value.absent(),
    required String longDateFormat,
    this.localeOverride = const Value.absent(),
    required int maxSets,
    this.notifications = const Value.absent(),
    this.notificationPermissionRequested = const Value.absent(),
    this.peekGraph = const Value.absent(),
    required String planTrailing,
    required bool restTimers,
    required String shortDateFormat,
    this.showBodyWeight = const Value.absent(),
    this.showCategories = const Value.absent(),
    this.showImages = const Value.absent(),
    this.showNotes = const Value.absent(),
    this.showGlobalProgress = const Value.absent(),
    required bool showUnits,
    required String strengthUnit,
    required bool systemColors,
    this.tabs = const Value.absent(),
    required String themeMode,
    required int timerDuration,
    required bool vibrate,
    this.warmupSets = const Value.absent(),
    this.scrollableTabs = const Value.absent(),
    this.showGraphXAxis = const Value.absent(),
    this.showGraphLimit = const Value.absent(),
    this.progressPosition = const Value.absent(),
    this.defaultGraphMetric = const Value.absent(),
    this.defaultGraphPeriod = const Value.absent(),
    this.defaultGraphLimit = const Value.absent(),
    this.defaultGraphTimeBasedXAxis = const Value.absent(),
    this.keepRinging = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
    this.inputStyle = const Value.absent(),
    this.profileName = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.goals = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.themeId = const Value.absent(),
    this.restVolume = const Value.absent(),
  }) : alarmSound = Value(alarmSound),
       cardioUnit = Value(cardioUnit),
       curveLines = Value(curveLines),
       explainedPermissions = Value(explainedPermissions),
       groupHistory = Value(groupHistory),
       longDateFormat = Value(longDateFormat),
       maxSets = Value(maxSets),
       planTrailing = Value(planTrailing),
       restTimers = Value(restTimers),
       shortDateFormat = Value(shortDateFormat),
       showUnits = Value(showUnits),
       strengthUnit = Value(strengthUnit),
       systemColors = Value(systemColors),
       themeMode = Value(themeMode),
       timerDuration = Value(timerDuration),
       vibrate = Value(vibrate);
  static Insertable<Setting> custom({
    Expression<String>? alarmSound,
    Expression<bool>? automaticBackups,
    Expression<String>? backupPath,
    Expression<int>? buildNumber,
    Expression<String>? cardioUnit,
    Expression<bool>? curveLines,
    Expression<double>? curveSmoothness,
    Expression<bool>? durationEstimation,
    Expression<bool>? enableSound,
    Expression<bool>? explainedPermissions,
    Expression<bool>? groupHistory,
    Expression<int>? id,
    Expression<String>? longDateFormat,
    Expression<String>? localeOverride,
    Expression<int>? maxSets,
    Expression<bool>? notifications,
    Expression<bool>? notificationPermissionRequested,
    Expression<bool>? peekGraph,
    Expression<String>? planTrailing,
    Expression<bool>? restTimers,
    Expression<String>? shortDateFormat,
    Expression<bool>? showBodyWeight,
    Expression<bool>? showCategories,
    Expression<bool>? showImages,
    Expression<bool>? showNotes,
    Expression<bool>? showGlobalProgress,
    Expression<bool>? showUnits,
    Expression<String>? strengthUnit,
    Expression<bool>? systemColors,
    Expression<String>? tabs,
    Expression<String>? themeMode,
    Expression<int>? timerDuration,
    Expression<bool>? vibrate,
    Expression<int>? warmupSets,
    Expression<bool>? scrollableTabs,
    Expression<bool>? showGraphXAxis,
    Expression<bool>? showGraphLimit,
    Expression<String>? progressPosition,
    Expression<String>? defaultGraphMetric,
    Expression<String>? defaultGraphPeriod,
    Expression<int>? defaultGraphLimit,
    Expression<bool>? defaultGraphTimeBasedXAxis,
    Expression<bool>? keepRinging,
    Expression<bool>? keepScreenOn,
    Expression<String>? inputStyle,
    Expression<String>? profileName,
    Expression<double>? heightCm,
    Expression<int>? ageYears,
    Expression<String>? goals,
    Expression<String>? apiKey,
    Expression<String>? themeId,
    Expression<double>? restVolume,
  }) {
    return RawValuesInsertable({
      if (alarmSound != null) 'alarm_sound': alarmSound,
      if (automaticBackups != null) 'automatic_backups': automaticBackups,
      if (backupPath != null) 'backup_path': backupPath,
      if (buildNumber != null) 'build_number': buildNumber,
      if (cardioUnit != null) 'cardio_unit': cardioUnit,
      if (curveLines != null) 'curve_lines': curveLines,
      if (curveSmoothness != null) 'curve_smoothness': curveSmoothness,
      if (durationEstimation != null) 'duration_estimation': durationEstimation,
      if (enableSound != null) 'enable_sound': enableSound,
      if (explainedPermissions != null)
        'explained_permissions': explainedPermissions,
      if (groupHistory != null) 'group_history': groupHistory,
      if (id != null) 'id': id,
      if (longDateFormat != null) 'long_date_format': longDateFormat,
      if (localeOverride != null) 'locale_override': localeOverride,
      if (maxSets != null) 'max_sets': maxSets,
      if (notifications != null) 'notifications': notifications,
      if (notificationPermissionRequested != null)
        'notification_permission_requested': notificationPermissionRequested,
      if (peekGraph != null) 'peek_graph': peekGraph,
      if (planTrailing != null) 'plan_trailing': planTrailing,
      if (restTimers != null) 'rest_timers': restTimers,
      if (shortDateFormat != null) 'short_date_format': shortDateFormat,
      if (showBodyWeight != null) 'show_body_weight': showBodyWeight,
      if (showCategories != null) 'show_categories': showCategories,
      if (showImages != null) 'show_images': showImages,
      if (showNotes != null) 'show_notes': showNotes,
      if (showGlobalProgress != null)
        'show_global_progress': showGlobalProgress,
      if (showUnits != null) 'show_units': showUnits,
      if (strengthUnit != null) 'strength_unit': strengthUnit,
      if (systemColors != null) 'system_colors': systemColors,
      if (tabs != null) 'tabs': tabs,
      if (themeMode != null) 'theme_mode': themeMode,
      if (timerDuration != null) 'timer_duration': timerDuration,
      if (vibrate != null) 'vibrate': vibrate,
      if (warmupSets != null) 'warmup_sets': warmupSets,
      if (scrollableTabs != null) 'scrollable_tabs': scrollableTabs,
      if (showGraphXAxis != null) 'show_graph_x_axis': showGraphXAxis,
      if (showGraphLimit != null) 'show_graph_limit': showGraphLimit,
      if (progressPosition != null) 'progress_position': progressPosition,
      if (defaultGraphMetric != null)
        'default_graph_metric': defaultGraphMetric,
      if (defaultGraphPeriod != null)
        'default_graph_period': defaultGraphPeriod,
      if (defaultGraphLimit != null) 'default_graph_limit': defaultGraphLimit,
      if (defaultGraphTimeBasedXAxis != null)
        'default_graph_time_based_x_axis': defaultGraphTimeBasedXAxis,
      if (keepRinging != null) 'keep_ringing': keepRinging,
      if (keepScreenOn != null) 'keep_screen_on': keepScreenOn,
      if (inputStyle != null) 'input_style': inputStyle,
      if (profileName != null) 'profile_name': profileName,
      if (heightCm != null) 'height_cm': heightCm,
      if (ageYears != null) 'age_years': ageYears,
      if (goals != null) 'goals': goals,
      if (apiKey != null) 'api_key': apiKey,
      if (themeId != null) 'theme_id': themeId,
      if (restVolume != null) 'rest_volume': restVolume,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? alarmSound,
    Value<bool>? automaticBackups,
    Value<String?>? backupPath,
    Value<int?>? buildNumber,
    Value<String>? cardioUnit,
    Value<bool>? curveLines,
    Value<double?>? curveSmoothness,
    Value<bool>? durationEstimation,
    Value<bool>? enableSound,
    Value<bool>? explainedPermissions,
    Value<bool>? groupHistory,
    Value<int>? id,
    Value<String>? longDateFormat,
    Value<String?>? localeOverride,
    Value<int>? maxSets,
    Value<bool>? notifications,
    Value<bool>? notificationPermissionRequested,
    Value<bool>? peekGraph,
    Value<String>? planTrailing,
    Value<bool>? restTimers,
    Value<String>? shortDateFormat,
    Value<bool>? showBodyWeight,
    Value<bool>? showCategories,
    Value<bool>? showImages,
    Value<bool>? showNotes,
    Value<bool>? showGlobalProgress,
    Value<bool>? showUnits,
    Value<String>? strengthUnit,
    Value<bool>? systemColors,
    Value<String>? tabs,
    Value<String>? themeMode,
    Value<int>? timerDuration,
    Value<bool>? vibrate,
    Value<int?>? warmupSets,
    Value<bool>? scrollableTabs,
    Value<bool>? showGraphXAxis,
    Value<bool>? showGraphLimit,
    Value<String>? progressPosition,
    Value<String>? defaultGraphMetric,
    Value<String>? defaultGraphPeriod,
    Value<int>? defaultGraphLimit,
    Value<bool>? defaultGraphTimeBasedXAxis,
    Value<bool>? keepRinging,
    Value<bool>? keepScreenOn,
    Value<String>? inputStyle,
    Value<String?>? profileName,
    Value<double?>? heightCm,
    Value<int?>? ageYears,
    Value<String?>? goals,
    Value<String?>? apiKey,
    Value<String>? themeId,
    Value<double>? restVolume,
  }) {
    return SettingsCompanion(
      alarmSound: alarmSound ?? this.alarmSound,
      automaticBackups: automaticBackups ?? this.automaticBackups,
      backupPath: backupPath ?? this.backupPath,
      buildNumber: buildNumber ?? this.buildNumber,
      cardioUnit: cardioUnit ?? this.cardioUnit,
      curveLines: curveLines ?? this.curveLines,
      curveSmoothness: curveSmoothness ?? this.curveSmoothness,
      durationEstimation: durationEstimation ?? this.durationEstimation,
      enableSound: enableSound ?? this.enableSound,
      explainedPermissions: explainedPermissions ?? this.explainedPermissions,
      groupHistory: groupHistory ?? this.groupHistory,
      id: id ?? this.id,
      longDateFormat: longDateFormat ?? this.longDateFormat,
      localeOverride: localeOverride ?? this.localeOverride,
      maxSets: maxSets ?? this.maxSets,
      notifications: notifications ?? this.notifications,
      notificationPermissionRequested:
          notificationPermissionRequested ??
          this.notificationPermissionRequested,
      peekGraph: peekGraph ?? this.peekGraph,
      planTrailing: planTrailing ?? this.planTrailing,
      restTimers: restTimers ?? this.restTimers,
      shortDateFormat: shortDateFormat ?? this.shortDateFormat,
      showBodyWeight: showBodyWeight ?? this.showBodyWeight,
      showCategories: showCategories ?? this.showCategories,
      showImages: showImages ?? this.showImages,
      showNotes: showNotes ?? this.showNotes,
      showGlobalProgress: showGlobalProgress ?? this.showGlobalProgress,
      showUnits: showUnits ?? this.showUnits,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      systemColors: systemColors ?? this.systemColors,
      tabs: tabs ?? this.tabs,
      themeMode: themeMode ?? this.themeMode,
      timerDuration: timerDuration ?? this.timerDuration,
      vibrate: vibrate ?? this.vibrate,
      warmupSets: warmupSets ?? this.warmupSets,
      scrollableTabs: scrollableTabs ?? this.scrollableTabs,
      showGraphXAxis: showGraphXAxis ?? this.showGraphXAxis,
      showGraphLimit: showGraphLimit ?? this.showGraphLimit,
      progressPosition: progressPosition ?? this.progressPosition,
      defaultGraphMetric: defaultGraphMetric ?? this.defaultGraphMetric,
      defaultGraphPeriod: defaultGraphPeriod ?? this.defaultGraphPeriod,
      defaultGraphLimit: defaultGraphLimit ?? this.defaultGraphLimit,
      defaultGraphTimeBasedXAxis:
          defaultGraphTimeBasedXAxis ?? this.defaultGraphTimeBasedXAxis,
      keepRinging: keepRinging ?? this.keepRinging,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      inputStyle: inputStyle ?? this.inputStyle,
      profileName: profileName ?? this.profileName,
      heightCm: heightCm ?? this.heightCm,
      ageYears: ageYears ?? this.ageYears,
      goals: goals ?? this.goals,
      apiKey: apiKey ?? this.apiKey,
      themeId: themeId ?? this.themeId,
      restVolume: restVolume ?? this.restVolume,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alarmSound.present) {
      map['alarm_sound'] = Variable<String>(alarmSound.value);
    }
    if (automaticBackups.present) {
      map['automatic_backups'] = Variable<bool>(automaticBackups.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (buildNumber.present) {
      map['build_number'] = Variable<int>(buildNumber.value);
    }
    if (cardioUnit.present) {
      map['cardio_unit'] = Variable<String>(cardioUnit.value);
    }
    if (curveLines.present) {
      map['curve_lines'] = Variable<bool>(curveLines.value);
    }
    if (curveSmoothness.present) {
      map['curve_smoothness'] = Variable<double>(curveSmoothness.value);
    }
    if (durationEstimation.present) {
      map['duration_estimation'] = Variable<bool>(durationEstimation.value);
    }
    if (enableSound.present) {
      map['enable_sound'] = Variable<bool>(enableSound.value);
    }
    if (explainedPermissions.present) {
      map['explained_permissions'] = Variable<bool>(explainedPermissions.value);
    }
    if (groupHistory.present) {
      map['group_history'] = Variable<bool>(groupHistory.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (longDateFormat.present) {
      map['long_date_format'] = Variable<String>(longDateFormat.value);
    }
    if (localeOverride.present) {
      map['locale_override'] = Variable<String>(localeOverride.value);
    }
    if (maxSets.present) {
      map['max_sets'] = Variable<int>(maxSets.value);
    }
    if (notifications.present) {
      map['notifications'] = Variable<bool>(notifications.value);
    }
    if (notificationPermissionRequested.present) {
      map['notification_permission_requested'] = Variable<bool>(
        notificationPermissionRequested.value,
      );
    }
    if (peekGraph.present) {
      map['peek_graph'] = Variable<bool>(peekGraph.value);
    }
    if (planTrailing.present) {
      map['plan_trailing'] = Variable<String>(planTrailing.value);
    }
    if (restTimers.present) {
      map['rest_timers'] = Variable<bool>(restTimers.value);
    }
    if (shortDateFormat.present) {
      map['short_date_format'] = Variable<String>(shortDateFormat.value);
    }
    if (showBodyWeight.present) {
      map['show_body_weight'] = Variable<bool>(showBodyWeight.value);
    }
    if (showCategories.present) {
      map['show_categories'] = Variable<bool>(showCategories.value);
    }
    if (showImages.present) {
      map['show_images'] = Variable<bool>(showImages.value);
    }
    if (showNotes.present) {
      map['show_notes'] = Variable<bool>(showNotes.value);
    }
    if (showGlobalProgress.present) {
      map['show_global_progress'] = Variable<bool>(showGlobalProgress.value);
    }
    if (showUnits.present) {
      map['show_units'] = Variable<bool>(showUnits.value);
    }
    if (strengthUnit.present) {
      map['strength_unit'] = Variable<String>(strengthUnit.value);
    }
    if (systemColors.present) {
      map['system_colors'] = Variable<bool>(systemColors.value);
    }
    if (tabs.present) {
      map['tabs'] = Variable<String>(tabs.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (timerDuration.present) {
      map['timer_duration'] = Variable<int>(timerDuration.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (warmupSets.present) {
      map['warmup_sets'] = Variable<int>(warmupSets.value);
    }
    if (scrollableTabs.present) {
      map['scrollable_tabs'] = Variable<bool>(scrollableTabs.value);
    }
    if (showGraphXAxis.present) {
      map['show_graph_x_axis'] = Variable<bool>(showGraphXAxis.value);
    }
    if (showGraphLimit.present) {
      map['show_graph_limit'] = Variable<bool>(showGraphLimit.value);
    }
    if (progressPosition.present) {
      map['progress_position'] = Variable<String>(progressPosition.value);
    }
    if (defaultGraphMetric.present) {
      map['default_graph_metric'] = Variable<String>(defaultGraphMetric.value);
    }
    if (defaultGraphPeriod.present) {
      map['default_graph_period'] = Variable<String>(defaultGraphPeriod.value);
    }
    if (defaultGraphLimit.present) {
      map['default_graph_limit'] = Variable<int>(defaultGraphLimit.value);
    }
    if (defaultGraphTimeBasedXAxis.present) {
      map['default_graph_time_based_x_axis'] = Variable<bool>(
        defaultGraphTimeBasedXAxis.value,
      );
    }
    if (keepRinging.present) {
      map['keep_ringing'] = Variable<bool>(keepRinging.value);
    }
    if (keepScreenOn.present) {
      map['keep_screen_on'] = Variable<bool>(keepScreenOn.value);
    }
    if (inputStyle.present) {
      map['input_style'] = Variable<String>(inputStyle.value);
    }
    if (profileName.present) {
      map['profile_name'] = Variable<String>(profileName.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (goals.present) {
      map['goals'] = Variable<String>(goals.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (restVolume.present) {
      map['rest_volume'] = Variable<double>(restVolume.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('alarmSound: $alarmSound, ')
          ..write('automaticBackups: $automaticBackups, ')
          ..write('backupPath: $backupPath, ')
          ..write('buildNumber: $buildNumber, ')
          ..write('cardioUnit: $cardioUnit, ')
          ..write('curveLines: $curveLines, ')
          ..write('curveSmoothness: $curveSmoothness, ')
          ..write('durationEstimation: $durationEstimation, ')
          ..write('enableSound: $enableSound, ')
          ..write('explainedPermissions: $explainedPermissions, ')
          ..write('groupHistory: $groupHistory, ')
          ..write('id: $id, ')
          ..write('longDateFormat: $longDateFormat, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('maxSets: $maxSets, ')
          ..write('notifications: $notifications, ')
          ..write(
            'notificationPermissionRequested: $notificationPermissionRequested, ',
          )
          ..write('peekGraph: $peekGraph, ')
          ..write('planTrailing: $planTrailing, ')
          ..write('restTimers: $restTimers, ')
          ..write('shortDateFormat: $shortDateFormat, ')
          ..write('showBodyWeight: $showBodyWeight, ')
          ..write('showCategories: $showCategories, ')
          ..write('showImages: $showImages, ')
          ..write('showNotes: $showNotes, ')
          ..write('showGlobalProgress: $showGlobalProgress, ')
          ..write('showUnits: $showUnits, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('systemColors: $systemColors, ')
          ..write('tabs: $tabs, ')
          ..write('themeMode: $themeMode, ')
          ..write('timerDuration: $timerDuration, ')
          ..write('vibrate: $vibrate, ')
          ..write('warmupSets: $warmupSets, ')
          ..write('scrollableTabs: $scrollableTabs, ')
          ..write('showGraphXAxis: $showGraphXAxis, ')
          ..write('showGraphLimit: $showGraphLimit, ')
          ..write('progressPosition: $progressPosition, ')
          ..write('defaultGraphMetric: $defaultGraphMetric, ')
          ..write('defaultGraphPeriod: $defaultGraphPeriod, ')
          ..write('defaultGraphLimit: $defaultGraphLimit, ')
          ..write('defaultGraphTimeBasedXAxis: $defaultGraphTimeBasedXAxis, ')
          ..write('keepRinging: $keepRinging, ')
          ..write('keepScreenOn: $keepScreenOn, ')
          ..write('inputStyle: $inputStyle, ')
          ..write('profileName: $profileName, ')
          ..write('heightCm: $heightCm, ')
          ..write('ageYears: $ageYears, ')
          ..write('goals: $goals, ')
          ..write('apiKey: $apiKey, ')
          ..write('themeId: $themeId, ')
          ..write('restVolume: $restVolume')
          ..write(')'))
        .toString();
  }
}

class $PlanExercisesTable extends PlanExercises
    with TableInfo<$PlanExercisesTable, PlanExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timersMeta = const VerificationMeta('timers');
  @override
  late final GeneratedColumn<bool> timers = GeneratedColumn<bool>(
    'timers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("timers" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _maxSetsMeta = const VerificationMeta(
    'maxSets',
  );
  @override
  late final GeneratedColumn<int> maxSets = GeneratedColumn<int>(
    'max_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id)',
    ),
  );
  static const VerificationMeta _warmupSetsMeta = const VerificationMeta(
    'warmupSets',
  );
  @override
  late final GeneratedColumn<int> warmupSets = GeneratedColumn<int>(
    'warmup_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>(
    'rep_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>(
    'rep_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    enabled,
    timers,
    exerciseId,
    id,
    maxSets,
    planId,
    warmupSets,
    sequence,
    repMin,
    repMax,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('timers')) {
      context.handle(
        _timersMeta,
        timers.isAcceptableOrUnknown(data['timers']!, _timersMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('max_sets')) {
      context.handle(
        _maxSetsMeta,
        maxSets.isAcceptableOrUnknown(data['max_sets']!, _maxSetsMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('warmup_sets')) {
      context.handle(
        _warmupSetsMeta,
        warmupSets.isAcceptableOrUnknown(data['warmup_sets']!, _warmupSetsMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('rep_min')) {
      context.handle(
        _repMinMeta,
        repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta),
      );
    }
    if (data.containsKey('rep_max')) {
      context.handle(
        _repMaxMeta,
        repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanExercise(
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      timers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}timers'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      maxSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_sets'],
      ),
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      warmupSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warmup_sets'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      repMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_min'],
      ),
      repMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_max'],
      ),
    );
  }

  @override
  $PlanExercisesTable createAlias(String alias) {
    return $PlanExercisesTable(attachedDatabase, alias);
  }
}

class PlanExercise extends DataClass implements Insertable<PlanExercise> {
  final bool enabled;
  final bool timers;
  final int exerciseId;
  final int id;
  final int? maxSets;
  final int planId;
  final int? warmupSets;
  final int sequence;
  final int? repMin;
  final int? repMax;
  const PlanExercise({
    required this.enabled,
    required this.timers,
    required this.exerciseId,
    required this.id,
    this.maxSets,
    required this.planId,
    this.warmupSets,
    required this.sequence,
    this.repMin,
    this.repMax,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['enabled'] = Variable<bool>(enabled);
    map['timers'] = Variable<bool>(timers);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || maxSets != null) {
      map['max_sets'] = Variable<int>(maxSets);
    }
    map['plan_id'] = Variable<int>(planId);
    if (!nullToAbsent || warmupSets != null) {
      map['warmup_sets'] = Variable<int>(warmupSets);
    }
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || repMin != null) {
      map['rep_min'] = Variable<int>(repMin);
    }
    if (!nullToAbsent || repMax != null) {
      map['rep_max'] = Variable<int>(repMax);
    }
    return map;
  }

  PlanExercisesCompanion toCompanion(bool nullToAbsent) {
    return PlanExercisesCompanion(
      enabled: Value(enabled),
      timers: Value(timers),
      exerciseId: Value(exerciseId),
      id: Value(id),
      maxSets: maxSets == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSets),
      planId: Value(planId),
      warmupSets: warmupSets == null && nullToAbsent
          ? const Value.absent()
          : Value(warmupSets),
      sequence: Value(sequence),
      repMin: repMin == null && nullToAbsent
          ? const Value.absent()
          : Value(repMin),
      repMax: repMax == null && nullToAbsent
          ? const Value.absent()
          : Value(repMax),
    );
  }

  factory PlanExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanExercise(
      enabled: serializer.fromJson<bool>(json['enabled']),
      timers: serializer.fromJson<bool>(json['timers']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      id: serializer.fromJson<int>(json['id']),
      maxSets: serializer.fromJson<int?>(json['maxSets']),
      planId: serializer.fromJson<int>(json['planId']),
      warmupSets: serializer.fromJson<int?>(json['warmupSets']),
      sequence: serializer.fromJson<int>(json['sequence']),
      repMin: serializer.fromJson<int?>(json['repMin']),
      repMax: serializer.fromJson<int?>(json['repMax']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'enabled': serializer.toJson<bool>(enabled),
      'timers': serializer.toJson<bool>(timers),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'id': serializer.toJson<int>(id),
      'maxSets': serializer.toJson<int?>(maxSets),
      'planId': serializer.toJson<int>(planId),
      'warmupSets': serializer.toJson<int?>(warmupSets),
      'sequence': serializer.toJson<int>(sequence),
      'repMin': serializer.toJson<int?>(repMin),
      'repMax': serializer.toJson<int?>(repMax),
    };
  }

  PlanExercise copyWith({
    bool? enabled,
    bool? timers,
    int? exerciseId,
    int? id,
    Value<int?> maxSets = const Value.absent(),
    int? planId,
    Value<int?> warmupSets = const Value.absent(),
    int? sequence,
    Value<int?> repMin = const Value.absent(),
    Value<int?> repMax = const Value.absent(),
  }) => PlanExercise(
    enabled: enabled ?? this.enabled,
    timers: timers ?? this.timers,
    exerciseId: exerciseId ?? this.exerciseId,
    id: id ?? this.id,
    maxSets: maxSets.present ? maxSets.value : this.maxSets,
    planId: planId ?? this.planId,
    warmupSets: warmupSets.present ? warmupSets.value : this.warmupSets,
    sequence: sequence ?? this.sequence,
    repMin: repMin.present ? repMin.value : this.repMin,
    repMax: repMax.present ? repMax.value : this.repMax,
  );
  PlanExercise copyWithCompanion(PlanExercisesCompanion data) {
    return PlanExercise(
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      timers: data.timers.present ? data.timers.value : this.timers,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      id: data.id.present ? data.id.value : this.id,
      maxSets: data.maxSets.present ? data.maxSets.value : this.maxSets,
      planId: data.planId.present ? data.planId.value : this.planId,
      warmupSets: data.warmupSets.present
          ? data.warmupSets.value
          : this.warmupSets,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanExercise(')
          ..write('enabled: $enabled, ')
          ..write('timers: $timers, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('id: $id, ')
          ..write('maxSets: $maxSets, ')
          ..write('planId: $planId, ')
          ..write('warmupSets: $warmupSets, ')
          ..write('sequence: $sequence, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    timers,
    exerciseId,
    id,
    maxSets,
    planId,
    warmupSets,
    sequence,
    repMin,
    repMax,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanExercise &&
          other.enabled == this.enabled &&
          other.timers == this.timers &&
          other.exerciseId == this.exerciseId &&
          other.id == this.id &&
          other.maxSets == this.maxSets &&
          other.planId == this.planId &&
          other.warmupSets == this.warmupSets &&
          other.sequence == this.sequence &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax);
}

class PlanExercisesCompanion extends UpdateCompanion<PlanExercise> {
  final Value<bool> enabled;
  final Value<bool> timers;
  final Value<int> exerciseId;
  final Value<int> id;
  final Value<int?> maxSets;
  final Value<int> planId;
  final Value<int?> warmupSets;
  final Value<int> sequence;
  final Value<int?> repMin;
  final Value<int?> repMax;
  const PlanExercisesCompanion({
    this.enabled = const Value.absent(),
    this.timers = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.id = const Value.absent(),
    this.maxSets = const Value.absent(),
    this.planId = const Value.absent(),
    this.warmupSets = const Value.absent(),
    this.sequence = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
  });
  PlanExercisesCompanion.insert({
    required bool enabled,
    this.timers = const Value.absent(),
    required int exerciseId,
    this.id = const Value.absent(),
    this.maxSets = const Value.absent(),
    required int planId,
    this.warmupSets = const Value.absent(),
    this.sequence = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
  }) : enabled = Value(enabled),
       exerciseId = Value(exerciseId),
       planId = Value(planId);
  static Insertable<PlanExercise> custom({
    Expression<bool>? enabled,
    Expression<bool>? timers,
    Expression<int>? exerciseId,
    Expression<int>? id,
    Expression<int>? maxSets,
    Expression<int>? planId,
    Expression<int>? warmupSets,
    Expression<int>? sequence,
    Expression<int>? repMin,
    Expression<int>? repMax,
  }) {
    return RawValuesInsertable({
      if (enabled != null) 'enabled': enabled,
      if (timers != null) 'timers': timers,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (id != null) 'id': id,
      if (maxSets != null) 'max_sets': maxSets,
      if (planId != null) 'plan_id': planId,
      if (warmupSets != null) 'warmup_sets': warmupSets,
      if (sequence != null) 'sequence': sequence,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
    });
  }

  PlanExercisesCompanion copyWith({
    Value<bool>? enabled,
    Value<bool>? timers,
    Value<int>? exerciseId,
    Value<int>? id,
    Value<int?>? maxSets,
    Value<int>? planId,
    Value<int?>? warmupSets,
    Value<int>? sequence,
    Value<int?>? repMin,
    Value<int?>? repMax,
  }) {
    return PlanExercisesCompanion(
      enabled: enabled ?? this.enabled,
      timers: timers ?? this.timers,
      exerciseId: exerciseId ?? this.exerciseId,
      id: id ?? this.id,
      maxSets: maxSets ?? this.maxSets,
      planId: planId ?? this.planId,
      warmupSets: warmupSets ?? this.warmupSets,
      sequence: sequence ?? this.sequence,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (timers.present) {
      map['timers'] = Variable<bool>(timers.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (maxSets.present) {
      map['max_sets'] = Variable<int>(maxSets.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (warmupSets.present) {
      map['warmup_sets'] = Variable<int>(warmupSets.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanExercisesCompanion(')
          ..write('enabled: $enabled, ')
          ..write('timers: $timers, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('id: $id, ')
          ..write('maxSets: $maxSets, ')
          ..write('planId: $planId, ')
          ..write('warmupSets: $warmupSets, ')
          ..write('sequence: $sequence, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $BodyWeightsTable bodyWeights = $BodyWeightsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PlanExercisesTable planExercises = $PlanExercisesTable(this);
  late final Index exercisesCategoryId = Index(
    'exercises_category_id',
    'CREATE INDEX exercises_category_id ON exercises (category_id)',
  );
  late final Index workoutsPlanEndedStarted = Index(
    'workouts_plan_ended_started',
    'CREATE INDEX workouts_plan_ended_started ON workouts (plan_id, ended_at, started_at DESC, id DESC)',
  );
  late final Index workoutsActivePlan = Index(
    'workouts_active_plan',
    'CREATE UNIQUE INDEX workouts_active_plan ON workouts (plan_id) WHERE ended_at IS NULL AND plan_id IS NOT NULL',
  );
  late final Index exerciseSetsTimestamp = Index(
    'exercise_sets_timestamp',
    'CREATE INDEX exercise_sets_timestamp ON exercise_sets (timestamp, id)',
  );
  late final Index exerciseSetsExerciseTimestamp = Index(
    'exercise_sets_exercise_timestamp',
    'CREATE INDEX exercise_sets_exercise_timestamp ON exercise_sets (exercise_id, timestamp DESC, id DESC)',
  );
  late final Index exerciseSetsWorkoutExercise = Index(
    'exercise_sets_workout_exercise',
    'CREATE INDEX exercise_sets_workout_exercise ON exercise_sets (workout_id, exercise_id, timestamp, id)',
  );
  late final Index bodyWeightsTimestamp = Index(
    'body_weights_timestamp',
    'CREATE INDEX body_weights_timestamp ON body_weights (timestamp DESC, id DESC)',
  );
  late final Index planExercisesPlanExercise = Index(
    'plan_exercises_plan_exercise',
    'CREATE UNIQUE INDEX plan_exercises_plan_exercise ON plan_exercises (plan_id, exercise_id)',
  );
  late final Index planExercisesExerciseId = Index(
    'plan_exercises_exercise_id',
    'CREATE INDEX plan_exercises_exercise_id ON plan_exercises (exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    plans,
    exercises,
    workouts,
    exerciseSets,
    bodyWeights,
    settings,
    planExercises,
    exercisesCategoryId,
    workoutsPlanEndedStarted,
    workoutsActivePlan,
    exerciseSetsTimestamp,
    exerciseSetsExerciseTimestamp,
    exerciseSetsWorkoutExercise,
    bodyWeightsTimestamp,
    planExercisesPlanExercise,
    planExercisesExerciseId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercises', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workouts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_sets', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_exercises', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({Value<int> id, required String name});
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({Value<int> id, Value<String> name});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: 'categories__id__exercises__category_id',
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool exercisesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CategoriesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CategoriesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exercisesRefs) db.exercises],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exercisesRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Exercise
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._exercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).exercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool exercisesRefs})
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      required String days,
      Value<int> id,
      Value<int?> sequence,
      Value<String?> title,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<String> days,
      Value<int> id,
      Value<int?> sequence,
      Value<String?> title,
    });

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workouts,
    aliasName: 'plans__id__workouts__plan_id',
  );

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanExercisesTable, List<PlanExercise>>
  _planExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planExercises,
    aliasName: 'plans__id__plan_exercises__plan_id',
  );

  $$PlanExercisesTableProcessedTableManager get planExercisesRefs {
    final manager = $$PlanExercisesTableTableManager(
      $_db,
      $_db.planExercises,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planExercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutsRefs(
    Expression<bool> Function($$WorkoutsTableFilterComposer f) f,
  ) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planExercisesRefs(
    Expression<bool> Function($$PlanExercisesTableFilterComposer f) f,
  ) {
    final $$PlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planExercises,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.planExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  Expression<T> workoutsRefs<T extends Object>(
    Expression<T> Function($$WorkoutsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planExercisesRefs<T extends Object>(
    Expression<T> Function($$PlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$PlanExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planExercises,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.planExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          Plan,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (Plan, $$PlansTableReferences),
          Plan,
          PrefetchHooks Function({bool workoutsRefs, bool planExercisesRefs})
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> days = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int?> sequence = const Value.absent(),
                Value<String?> title = const Value.absent(),
              }) => PlansCompanion(
                days: days,
                id: id,
                sequence: sequence,
                title: title,
              ),
          createCompanionCallback:
              ({
                required String days,
                Value<int> id = const Value.absent(),
                Value<int?> sequence = const Value.absent(),
                Value<String?> title = const Value.absent(),
              }) => PlansCompanion.insert(
                days: days,
                id: id,
                sequence: sequence,
                title: title,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlansTable, Plan>(table),
                  $$PlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutsRefs = false, planExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutsRefs) db.workouts,
                    if (planExercisesRefs) db.planExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutsRefs)
                        await $_getPrefetchedData<Plan, $PlansTable, Workout>(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._workoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planExercisesRefs)
                        await $_getPrefetchedData<
                          Plan,
                          $PlansTable,
                          PlanExercise
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._planExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).planExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      Plan,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (Plan, $$PlansTableReferences),
      Plan,
      PrefetchHooks Function({bool workoutsRefs, bool planExercisesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      required String kind,
      required String displayUnit,
      Value<int?> categoryId,
      Value<String?> image,
      Value<int?> defaultRestDurationMs,
      Value<String?> notes,
      Value<String> graphMetric,
      Value<String> graphPeriod,
      Value<int> graphLimit,
      Value<bool> graphTimeBasedXAxis,
      Value<bool> archived,
      Value<String?> germanName,
      Value<String?> aliases,
      Value<String?> muscle,
      Value<String?> catalogId,
      Value<String?> categoryName,
      Value<String?> equipment,
      Value<String?> primaryMuscles,
      Value<String?> secondaryMuscles,
      Value<String?> mechanic,
      Value<String?> steps,
      Value<String?> tips,
      Value<String?> catalogSource,
      Value<String?> catalogLicense,
      Value<String?> imageSource,
      Value<String?> imageLicense,
      Value<String?> alternatives,
      Value<String?> schulterRisiko,
      Value<String?> familie,
      Value<String?> griff,
      Value<String?> position,
      Value<bool> einseitig,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> kind,
      Value<String> displayUnit,
      Value<int?> categoryId,
      Value<String?> image,
      Value<int?> defaultRestDurationMs,
      Value<String?> notes,
      Value<String> graphMetric,
      Value<String> graphPeriod,
      Value<int> graphLimit,
      Value<bool> graphTimeBasedXAxis,
      Value<bool> archived,
      Value<String?> germanName,
      Value<String?> aliases,
      Value<String?> muscle,
      Value<String?> catalogId,
      Value<String?> categoryName,
      Value<String?> equipment,
      Value<String?> primaryMuscles,
      Value<String?> secondaryMuscles,
      Value<String?> mechanic,
      Value<String?> steps,
      Value<String?> tips,
      Value<String?> catalogSource,
      Value<String?> catalogLicense,
      Value<String?> imageSource,
      Value<String?> imageLicense,
      Value<String?> alternatives,
      Value<String?> schulterRisiko,
      Value<String?> familie,
      Value<String?> griff,
      Value<String?> position,
      Value<bool> einseitig,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('exercises__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>>
  _exerciseSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: 'exercises__id__exercise_sets__exercise_id',
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanExercisesTable, List<PlanExercise>>
  _planExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planExercises,
    aliasName: 'exercises__id__plan_exercises__exercise_id',
  );

  $$PlanExercisesTableProcessedTableManager get planExercisesRefs {
    final manager = $$PlanExercisesTableTableManager(
      $_db,
      $_db.planExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planExercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayUnit => $composableBuilder(
    column: $table.displayUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRestDurationMs => $composableBuilder(
    column: $table.defaultRestDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graphMetric => $composableBuilder(
    column: $table.graphMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graphPeriod => $composableBuilder(
    column: $table.graphPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get graphLimit => $composableBuilder(
    column: $table.graphLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get graphTimeBasedXAxis => $composableBuilder(
    column: $table.graphTimeBasedXAxis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get germanName => $composableBuilder(
    column: $table.germanName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogSource => $composableBuilder(
    column: $table.catalogSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogLicense => $composableBuilder(
    column: $table.catalogLicense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageSource => $composableBuilder(
    column: $table.imageSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLicense => $composableBuilder(
    column: $table.imageLicense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternatives => $composableBuilder(
    column: $table.alternatives,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schulterRisiko => $composableBuilder(
    column: $table.schulterRisiko,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familie => $composableBuilder(
    column: $table.familie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get griff => $composableBuilder(
    column: $table.griff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get einseitig => $composableBuilder(
    column: $table.einseitig,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planExercisesRefs(
    Expression<bool> Function($$PlanExercisesTableFilterComposer f) f,
  ) {
    final $$PlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.planExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayUnit => $composableBuilder(
    column: $table.displayUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRestDurationMs => $composableBuilder(
    column: $table.defaultRestDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graphMetric => $composableBuilder(
    column: $table.graphMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graphPeriod => $composableBuilder(
    column: $table.graphPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get graphLimit => $composableBuilder(
    column: $table.graphLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get graphTimeBasedXAxis => $composableBuilder(
    column: $table.graphTimeBasedXAxis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get germanName => $composableBuilder(
    column: $table.germanName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogSource => $composableBuilder(
    column: $table.catalogSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogLicense => $composableBuilder(
    column: $table.catalogLicense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageSource => $composableBuilder(
    column: $table.imageSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLicense => $composableBuilder(
    column: $table.imageLicense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternatives => $composableBuilder(
    column: $table.alternatives,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schulterRisiko => $composableBuilder(
    column: $table.schulterRisiko,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familie => $composableBuilder(
    column: $table.familie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get griff => $composableBuilder(
    column: $table.griff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get einseitig => $composableBuilder(
    column: $table.einseitig,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get displayUnit => $composableBuilder(
    column: $table.displayUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<int> get defaultRestDurationMs => $composableBuilder(
    column: $table.defaultRestDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get graphMetric => $composableBuilder(
    column: $table.graphMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get graphPeriod => $composableBuilder(
    column: $table.graphPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get graphLimit => $composableBuilder(
    column: $table.graphLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get graphTimeBasedXAxis => $composableBuilder(
    column: $table.graphTimeBasedXAxis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get germanName => $composableBuilder(
    column: $table.germanName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get muscle =>
      $composableBuilder(column: $table.muscle, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get tips =>
      $composableBuilder(column: $table.tips, builder: (column) => column);

  GeneratedColumn<String> get catalogSource => $composableBuilder(
    column: $table.catalogSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogLicense => $composableBuilder(
    column: $table.catalogLicense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageSource => $composableBuilder(
    column: $table.imageSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageLicense => $composableBuilder(
    column: $table.imageLicense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alternatives => $composableBuilder(
    column: $table.alternatives,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schulterRisiko => $composableBuilder(
    column: $table.schulterRisiko,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familie =>
      $composableBuilder(column: $table.familie, builder: (column) => column);

  GeneratedColumn<String> get griff =>
      $composableBuilder(column: $table.griff, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get einseitig =>
      $composableBuilder(column: $table.einseitig, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planExercisesRefs<T extends Object>(
    Expression<T> Function($$PlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$PlanExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.planExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool categoryId,
            bool exerciseSetsRefs,
            bool planExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> displayUnit = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int?> defaultRestDurationMs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> graphMetric = const Value.absent(),
                Value<String> graphPeriod = const Value.absent(),
                Value<int> graphLimit = const Value.absent(),
                Value<bool> graphTimeBasedXAxis = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> germanName = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<String?> muscle = const Value.absent(),
                Value<String?> catalogId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> secondaryMuscles = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> steps = const Value.absent(),
                Value<String?> tips = const Value.absent(),
                Value<String?> catalogSource = const Value.absent(),
                Value<String?> catalogLicense = const Value.absent(),
                Value<String?> imageSource = const Value.absent(),
                Value<String?> imageLicense = const Value.absent(),
                Value<String?> alternatives = const Value.absent(),
                Value<String?> schulterRisiko = const Value.absent(),
                Value<String?> familie = const Value.absent(),
                Value<String?> griff = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<bool> einseitig = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                kind: kind,
                displayUnit: displayUnit,
                categoryId: categoryId,
                image: image,
                defaultRestDurationMs: defaultRestDurationMs,
                notes: notes,
                graphMetric: graphMetric,
                graphPeriod: graphPeriod,
                graphLimit: graphLimit,
                graphTimeBasedXAxis: graphTimeBasedXAxis,
                archived: archived,
                germanName: germanName,
                aliases: aliases,
                muscle: muscle,
                catalogId: catalogId,
                categoryName: categoryName,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                mechanic: mechanic,
                steps: steps,
                tips: tips,
                catalogSource: catalogSource,
                catalogLicense: catalogLicense,
                imageSource: imageSource,
                imageLicense: imageLicense,
                alternatives: alternatives,
                schulterRisiko: schulterRisiko,
                familie: familie,
                griff: griff,
                position: position,
                einseitig: einseitig,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String kind,
                required String displayUnit,
                Value<int?> categoryId = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int?> defaultRestDurationMs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> graphMetric = const Value.absent(),
                Value<String> graphPeriod = const Value.absent(),
                Value<int> graphLimit = const Value.absent(),
                Value<bool> graphTimeBasedXAxis = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> germanName = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<String?> muscle = const Value.absent(),
                Value<String?> catalogId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> secondaryMuscles = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> steps = const Value.absent(),
                Value<String?> tips = const Value.absent(),
                Value<String?> catalogSource = const Value.absent(),
                Value<String?> catalogLicense = const Value.absent(),
                Value<String?> imageSource = const Value.absent(),
                Value<String?> imageLicense = const Value.absent(),
                Value<String?> alternatives = const Value.absent(),
                Value<String?> schulterRisiko = const Value.absent(),
                Value<String?> familie = const Value.absent(),
                Value<String?> griff = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<bool> einseitig = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                displayUnit: displayUnit,
                categoryId: categoryId,
                image: image,
                defaultRestDurationMs: defaultRestDurationMs,
                notes: notes,
                graphMetric: graphMetric,
                graphPeriod: graphPeriod,
                graphLimit: graphLimit,
                graphTimeBasedXAxis: graphTimeBasedXAxis,
                archived: archived,
                germanName: germanName,
                aliases: aliases,
                muscle: muscle,
                catalogId: catalogId,
                categoryName: categoryName,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                mechanic: mechanic,
                steps: steps,
                tips: tips,
                catalogSource: catalogSource,
                catalogLicense: catalogLicense,
                imageSource: imageSource,
                imageLicense: imageLicense,
                alternatives: alternatives,
                schulterRisiko: schulterRisiko,
                familie: familie,
                griff: griff,
                position: position,
                einseitig: einseitig,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                exerciseSetsRefs = false,
                planExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseSetsRefs) db.exerciseSets,
                    if (planExercisesRefs) db.planExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseSetsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseSet
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          PlanExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._planExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).planExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool categoryId,
        bool exerciseSetsRefs,
        bool planExercisesRefs,
      })
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> exerciseOrder,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> exerciseOrder,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('workouts__plan_id__plans__id');

  $$PlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>>
  _exerciseSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: 'workouts__id__exercise_sets__workout_id',
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager(
      $_db,
      $_db.exerciseSets,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => column,
  );

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({bool planId, bool exerciseSetsRefs})
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> exerciseOrder = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                planId: planId,
                startedAt: startedAt,
                endedAt: endedAt,
                exerciseOrder: exerciseOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> exerciseOrder = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                planId: planId,
                startedAt: startedAt,
                endedAt: endedAt,
                exerciseOrder: exerciseOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutsTable, Workout>(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false, exerciseSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exerciseSetsRefs) db.exerciseSets],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$WorkoutsTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$WorkoutsTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseSetsRefs)
                    await $_getPrefetchedData<
                      Workout,
                      $WorkoutsTable,
                      ExerciseSet
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutsTableReferences
                          ._exerciseSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutsTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({bool planId, bool exerciseSetsRefs})
    >;
typedef $$ExerciseSetsTableCreateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      required int exerciseId,
      Value<int?> workoutId,
      required DateTime timestamp,
      Value<double?> reps,
      Value<double?> loadKg,
      Value<int?> durationMs,
      Value<double?> distanceMetres,
      Value<double?> incline,
      Value<double?> bodyWeightKg,
      Value<String?> notes,
      Value<String?> side,
    });
typedef $$ExerciseSetsTableUpdateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<int?> workoutId,
      Value<DateTime> timestamp,
      Value<double?> reps,
      Value<double?> loadKg,
      Value<int?> durationMs,
      Value<double?> distanceMetres,
      Value<double?> incline,
      Value<double?> bodyWeightKg,
      Value<String?> notes,
      Value<String?> side,
    });

final class $$ExerciseSetsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseSetsTable, ExerciseSet> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_sets__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('exercise_sets__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager? get workoutId {
    final $_column = $_itemColumn<int>('workout_id');
    if ($_column == null) return null;
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseSetsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loadKg => $composableBuilder(
    column: $table.loadKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get incline => $composableBuilder(
    column: $table.incline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loadKg => $composableBuilder(
    column: $table.loadKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get incline => $composableBuilder(
    column: $table.incline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get loadKg =>
      $composableBuilder(column: $table.loadKg, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => column,
  );

  GeneratedColumn<double> get incline =>
      $composableBuilder(column: $table.incline, builder: (column) => column);

  GeneratedColumn<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseSetsTable,
          ExerciseSet,
          $$ExerciseSetsTableFilterComposer,
          $$ExerciseSetsTableOrderingComposer,
          $$ExerciseSetsTableAnnotationComposer,
          $$ExerciseSetsTableCreateCompanionBuilder,
          $$ExerciseSetsTableUpdateCompanionBuilder,
          (ExerciseSet, $$ExerciseSetsTableReferences),
          ExerciseSet,
          PrefetchHooks Function({bool exerciseId, bool workoutId})
        > {
  $$ExerciseSetsTableTableManager(_$AppDatabase db, $ExerciseSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> reps = const Value.absent(),
                Value<double?> loadKg = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<double?> distanceMetres = const Value.absent(),
                Value<double?> incline = const Value.absent(),
                Value<double?> bodyWeightKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> side = const Value.absent(),
              }) => ExerciseSetsCompanion(
                id: id,
                exerciseId: exerciseId,
                workoutId: workoutId,
                timestamp: timestamp,
                reps: reps,
                loadKg: loadKg,
                durationMs: durationMs,
                distanceMetres: distanceMetres,
                incline: incline,
                bodyWeightKg: bodyWeightKg,
                notes: notes,
                side: side,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                Value<int?> workoutId = const Value.absent(),
                required DateTime timestamp,
                Value<double?> reps = const Value.absent(),
                Value<double?> loadKg = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<double?> distanceMetres = const Value.absent(),
                Value<double?> incline = const Value.absent(),
                Value<double?> bodyWeightKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> side = const Value.absent(),
              }) => ExerciseSetsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                workoutId: workoutId,
                timestamp: timestamp,
                reps: reps,
                loadKg: loadKg,
                durationMs: durationMs,
                distanceMetres: distanceMetres,
                incline: incline,
                bodyWeightKg: bodyWeightKg,
                notes: notes,
                side: side,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseSetsTable, ExerciseSet>(table),
                  $$ExerciseSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseSetsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseSetsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable: $$ExerciseSetsTableReferences
                                    ._workoutIdTable(db),
                                referencedColumn: $$ExerciseSetsTableReferences
                                    ._workoutIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseSetsTable,
      ExerciseSet,
      $$ExerciseSetsTableFilterComposer,
      $$ExerciseSetsTableOrderingComposer,
      $$ExerciseSetsTableAnnotationComposer,
      $$ExerciseSetsTableCreateCompanionBuilder,
      $$ExerciseSetsTableUpdateCompanionBuilder,
      (ExerciseSet, $$ExerciseSetsTableReferences),
      ExerciseSet,
      PrefetchHooks Function({bool exerciseId, bool workoutId})
    >;
typedef $$BodyWeightsTableCreateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required double weightKg,
      Value<String?> photo,
    });
typedef $$BodyWeightsTableUpdateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<double> weightKg,
      Value<String?> photo,
    });

class $$BodyWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);
}

class $$BodyWeightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyWeightsTable,
          BodyWeight,
          $$BodyWeightsTableFilterComposer,
          $$BodyWeightsTableOrderingComposer,
          $$BodyWeightsTableAnnotationComposer,
          $$BodyWeightsTableCreateCompanionBuilder,
          $$BodyWeightsTableUpdateCompanionBuilder,
          (
            BodyWeight,
            BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>,
          ),
          BodyWeight,
          PrefetchHooks Function()
        > {
  $$BodyWeightsTableTableManager(_$AppDatabase db, $BodyWeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String?> photo = const Value.absent(),
              }) => BodyWeightsCompanion(
                id: id,
                timestamp: timestamp,
                weightKg: weightKg,
                photo: photo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required double weightKg,
                Value<String?> photo = const Value.absent(),
              }) => BodyWeightsCompanion.insert(
                id: id,
                timestamp: timestamp,
                weightKg: weightKg,
                photo: photo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyWeightsTable, BodyWeight>(table),
                  BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyWeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyWeightsTable,
      BodyWeight,
      $$BodyWeightsTableFilterComposer,
      $$BodyWeightsTableOrderingComposer,
      $$BodyWeightsTableAnnotationComposer,
      $$BodyWeightsTableCreateCompanionBuilder,
      $$BodyWeightsTableUpdateCompanionBuilder,
      (
        BodyWeight,
        BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>,
      ),
      BodyWeight,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String alarmSound,
      Value<bool> automaticBackups,
      Value<String?> backupPath,
      Value<int?> buildNumber,
      required String cardioUnit,
      required bool curveLines,
      Value<double?> curveSmoothness,
      Value<bool> durationEstimation,
      Value<bool> enableSound,
      required bool explainedPermissions,
      required bool groupHistory,
      Value<int> id,
      required String longDateFormat,
      Value<String?> localeOverride,
      required int maxSets,
      Value<bool> notifications,
      Value<bool> notificationPermissionRequested,
      Value<bool> peekGraph,
      required String planTrailing,
      required bool restTimers,
      required String shortDateFormat,
      Value<bool> showBodyWeight,
      Value<bool> showCategories,
      Value<bool> showImages,
      Value<bool> showNotes,
      Value<bool> showGlobalProgress,
      required bool showUnits,
      required String strengthUnit,
      required bool systemColors,
      Value<String> tabs,
      required String themeMode,
      required int timerDuration,
      required bool vibrate,
      Value<int?> warmupSets,
      Value<bool> scrollableTabs,
      Value<bool> showGraphXAxis,
      Value<bool> showGraphLimit,
      Value<String> progressPosition,
      Value<String> defaultGraphMetric,
      Value<String> defaultGraphPeriod,
      Value<int> defaultGraphLimit,
      Value<bool> defaultGraphTimeBasedXAxis,
      Value<bool> keepRinging,
      Value<bool> keepScreenOn,
      Value<String> inputStyle,
      Value<String?> profileName,
      Value<double?> heightCm,
      Value<int?> ageYears,
      Value<String?> goals,
      Value<String?> apiKey,
      Value<String> themeId,
      Value<double> restVolume,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> alarmSound,
      Value<bool> automaticBackups,
      Value<String?> backupPath,
      Value<int?> buildNumber,
      Value<String> cardioUnit,
      Value<bool> curveLines,
      Value<double?> curveSmoothness,
      Value<bool> durationEstimation,
      Value<bool> enableSound,
      Value<bool> explainedPermissions,
      Value<bool> groupHistory,
      Value<int> id,
      Value<String> longDateFormat,
      Value<String?> localeOverride,
      Value<int> maxSets,
      Value<bool> notifications,
      Value<bool> notificationPermissionRequested,
      Value<bool> peekGraph,
      Value<String> planTrailing,
      Value<bool> restTimers,
      Value<String> shortDateFormat,
      Value<bool> showBodyWeight,
      Value<bool> showCategories,
      Value<bool> showImages,
      Value<bool> showNotes,
      Value<bool> showGlobalProgress,
      Value<bool> showUnits,
      Value<String> strengthUnit,
      Value<bool> systemColors,
      Value<String> tabs,
      Value<String> themeMode,
      Value<int> timerDuration,
      Value<bool> vibrate,
      Value<int?> warmupSets,
      Value<bool> scrollableTabs,
      Value<bool> showGraphXAxis,
      Value<bool> showGraphLimit,
      Value<String> progressPosition,
      Value<String> defaultGraphMetric,
      Value<String> defaultGraphPeriod,
      Value<int> defaultGraphLimit,
      Value<bool> defaultGraphTimeBasedXAxis,
      Value<bool> keepRinging,
      Value<bool> keepScreenOn,
      Value<String> inputStyle,
      Value<String?> profileName,
      Value<double?> heightCm,
      Value<int?> ageYears,
      Value<String?> goals,
      Value<String?> apiKey,
      Value<String> themeId,
      Value<double> restVolume,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alarmSound => $composableBuilder(
    column: $table.alarmSound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get automaticBackups => $composableBuilder(
    column: $table.automaticBackups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardioUnit => $composableBuilder(
    column: $table.cardioUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get curveLines => $composableBuilder(
    column: $table.curveLines,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get curveSmoothness => $composableBuilder(
    column: $table.curveSmoothness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationEstimation => $composableBuilder(
    column: $table.durationEstimation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableSound => $composableBuilder(
    column: $table.enableSound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explainedPermissions => $composableBuilder(
    column: $table.explainedPermissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get groupHistory => $composableBuilder(
    column: $table.groupHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longDateFormat => $composableBuilder(
    column: $table.longDateFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSets => $composableBuilder(
    column: $table.maxSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationPermissionRequested => $composableBuilder(
    column: $table.notificationPermissionRequested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get peekGraph => $composableBuilder(
    column: $table.peekGraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planTrailing => $composableBuilder(
    column: $table.planTrailing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restTimers => $composableBuilder(
    column: $table.restTimers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortDateFormat => $composableBuilder(
    column: $table.shortDateFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showBodyWeight => $composableBuilder(
    column: $table.showBodyWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showCategories => $composableBuilder(
    column: $table.showCategories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showImages => $composableBuilder(
    column: $table.showImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showNotes => $composableBuilder(
    column: $table.showNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showGlobalProgress => $composableBuilder(
    column: $table.showGlobalProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showUnits => $composableBuilder(
    column: $table.showUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get systemColors => $composableBuilder(
    column: $table.systemColors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tabs => $composableBuilder(
    column: $table.tabs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timerDuration => $composableBuilder(
    column: $table.timerDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scrollableTabs => $composableBuilder(
    column: $table.scrollableTabs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showGraphXAxis => $composableBuilder(
    column: $table.showGraphXAxis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showGraphLimit => $composableBuilder(
    column: $table.showGraphLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressPosition => $composableBuilder(
    column: $table.progressPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultGraphMetric => $composableBuilder(
    column: $table.defaultGraphMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultGraphPeriod => $composableBuilder(
    column: $table.defaultGraphPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultGraphLimit => $composableBuilder(
    column: $table.defaultGraphLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get defaultGraphTimeBasedXAxis => $composableBuilder(
    column: $table.defaultGraphTimeBasedXAxis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepRinging => $composableBuilder(
    column: $table.keepRinging,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputStyle => $composableBuilder(
    column: $table.inputStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restVolume => $composableBuilder(
    column: $table.restVolume,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alarmSound => $composableBuilder(
    column: $table.alarmSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get automaticBackups => $composableBuilder(
    column: $table.automaticBackups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardioUnit => $composableBuilder(
    column: $table.cardioUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get curveLines => $composableBuilder(
    column: $table.curveLines,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get curveSmoothness => $composableBuilder(
    column: $table.curveSmoothness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationEstimation => $composableBuilder(
    column: $table.durationEstimation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableSound => $composableBuilder(
    column: $table.enableSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explainedPermissions => $composableBuilder(
    column: $table.explainedPermissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get groupHistory => $composableBuilder(
    column: $table.groupHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longDateFormat => $composableBuilder(
    column: $table.longDateFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSets => $composableBuilder(
    column: $table.maxSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationPermissionRequested =>
      $composableBuilder(
        column: $table.notificationPermissionRequested,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get peekGraph => $composableBuilder(
    column: $table.peekGraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planTrailing => $composableBuilder(
    column: $table.planTrailing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restTimers => $composableBuilder(
    column: $table.restTimers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortDateFormat => $composableBuilder(
    column: $table.shortDateFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showBodyWeight => $composableBuilder(
    column: $table.showBodyWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showCategories => $composableBuilder(
    column: $table.showCategories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showImages => $composableBuilder(
    column: $table.showImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showNotes => $composableBuilder(
    column: $table.showNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showGlobalProgress => $composableBuilder(
    column: $table.showGlobalProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showUnits => $composableBuilder(
    column: $table.showUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get systemColors => $composableBuilder(
    column: $table.systemColors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tabs => $composableBuilder(
    column: $table.tabs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timerDuration => $composableBuilder(
    column: $table.timerDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scrollableTabs => $composableBuilder(
    column: $table.scrollableTabs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showGraphXAxis => $composableBuilder(
    column: $table.showGraphXAxis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showGraphLimit => $composableBuilder(
    column: $table.showGraphLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressPosition => $composableBuilder(
    column: $table.progressPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultGraphMetric => $composableBuilder(
    column: $table.defaultGraphMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultGraphPeriod => $composableBuilder(
    column: $table.defaultGraphPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultGraphLimit => $composableBuilder(
    column: $table.defaultGraphLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get defaultGraphTimeBasedXAxis => $composableBuilder(
    column: $table.defaultGraphTimeBasedXAxis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepRinging => $composableBuilder(
    column: $table.keepRinging,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputStyle => $composableBuilder(
    column: $table.inputStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restVolume => $composableBuilder(
    column: $table.restVolume,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alarmSound => $composableBuilder(
    column: $table.alarmSound,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get automaticBackups => $composableBuilder(
    column: $table.automaticBackups,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardioUnit => $composableBuilder(
    column: $table.cardioUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get curveLines => $composableBuilder(
    column: $table.curveLines,
    builder: (column) => column,
  );

  GeneratedColumn<double> get curveSmoothness => $composableBuilder(
    column: $table.curveSmoothness,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get durationEstimation => $composableBuilder(
    column: $table.durationEstimation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableSound => $composableBuilder(
    column: $table.enableSound,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explainedPermissions => $composableBuilder(
    column: $table.explainedPermissions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get groupHistory => $composableBuilder(
    column: $table.groupHistory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get longDateFormat => $composableBuilder(
    column: $table.longDateFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxSets =>
      $composableBuilder(column: $table.maxSets, builder: (column) => column);

  GeneratedColumn<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationPermissionRequested =>
      $composableBuilder(
        column: $table.notificationPermissionRequested,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get peekGraph =>
      $composableBuilder(column: $table.peekGraph, builder: (column) => column);

  GeneratedColumn<String> get planTrailing => $composableBuilder(
    column: $table.planTrailing,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restTimers => $composableBuilder(
    column: $table.restTimers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortDateFormat => $composableBuilder(
    column: $table.shortDateFormat,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showBodyWeight => $composableBuilder(
    column: $table.showBodyWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showCategories => $composableBuilder(
    column: $table.showCategories,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showImages => $composableBuilder(
    column: $table.showImages,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showNotes =>
      $composableBuilder(column: $table.showNotes, builder: (column) => column);

  GeneratedColumn<bool> get showGlobalProgress => $composableBuilder(
    column: $table.showGlobalProgress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showUnits =>
      $composableBuilder(column: $table.showUnits, builder: (column) => column);

  GeneratedColumn<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get systemColors => $composableBuilder(
    column: $table.systemColors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tabs =>
      $composableBuilder(column: $table.tabs, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<int> get timerDuration => $composableBuilder(
    column: $table.timerDuration,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get scrollableTabs => $composableBuilder(
    column: $table.scrollableTabs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showGraphXAxis => $composableBuilder(
    column: $table.showGraphXAxis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showGraphLimit => $composableBuilder(
    column: $table.showGraphLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressPosition => $composableBuilder(
    column: $table.progressPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultGraphMetric => $composableBuilder(
    column: $table.defaultGraphMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultGraphPeriod => $composableBuilder(
    column: $table.defaultGraphPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultGraphLimit => $composableBuilder(
    column: $table.defaultGraphLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get defaultGraphTimeBasedXAxis => $composableBuilder(
    column: $table.defaultGraphTimeBasedXAxis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepRinging => $composableBuilder(
    column: $table.keepRinging,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputStyle => $composableBuilder(
    column: $table.inputStyle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<String> get goals =>
      $composableBuilder(column: $table.goals, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<double> get restVolume => $composableBuilder(
    column: $table.restVolume,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> alarmSound = const Value.absent(),
                Value<bool> automaticBackups = const Value.absent(),
                Value<String?> backupPath = const Value.absent(),
                Value<int?> buildNumber = const Value.absent(),
                Value<String> cardioUnit = const Value.absent(),
                Value<bool> curveLines = const Value.absent(),
                Value<double?> curveSmoothness = const Value.absent(),
                Value<bool> durationEstimation = const Value.absent(),
                Value<bool> enableSound = const Value.absent(),
                Value<bool> explainedPermissions = const Value.absent(),
                Value<bool> groupHistory = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> longDateFormat = const Value.absent(),
                Value<String?> localeOverride = const Value.absent(),
                Value<int> maxSets = const Value.absent(),
                Value<bool> notifications = const Value.absent(),
                Value<bool> notificationPermissionRequested =
                    const Value.absent(),
                Value<bool> peekGraph = const Value.absent(),
                Value<String> planTrailing = const Value.absent(),
                Value<bool> restTimers = const Value.absent(),
                Value<String> shortDateFormat = const Value.absent(),
                Value<bool> showBodyWeight = const Value.absent(),
                Value<bool> showCategories = const Value.absent(),
                Value<bool> showImages = const Value.absent(),
                Value<bool> showNotes = const Value.absent(),
                Value<bool> showGlobalProgress = const Value.absent(),
                Value<bool> showUnits = const Value.absent(),
                Value<String> strengthUnit = const Value.absent(),
                Value<bool> systemColors = const Value.absent(),
                Value<String> tabs = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int> timerDuration = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<int?> warmupSets = const Value.absent(),
                Value<bool> scrollableTabs = const Value.absent(),
                Value<bool> showGraphXAxis = const Value.absent(),
                Value<bool> showGraphLimit = const Value.absent(),
                Value<String> progressPosition = const Value.absent(),
                Value<String> defaultGraphMetric = const Value.absent(),
                Value<String> defaultGraphPeriod = const Value.absent(),
                Value<int> defaultGraphLimit = const Value.absent(),
                Value<bool> defaultGraphTimeBasedXAxis = const Value.absent(),
                Value<bool> keepRinging = const Value.absent(),
                Value<bool> keepScreenOn = const Value.absent(),
                Value<String> inputStyle = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<int?> ageYears = const Value.absent(),
                Value<String?> goals = const Value.absent(),
                Value<String?> apiKey = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<double> restVolume = const Value.absent(),
              }) => SettingsCompanion(
                alarmSound: alarmSound,
                automaticBackups: automaticBackups,
                backupPath: backupPath,
                buildNumber: buildNumber,
                cardioUnit: cardioUnit,
                curveLines: curveLines,
                curveSmoothness: curveSmoothness,
                durationEstimation: durationEstimation,
                enableSound: enableSound,
                explainedPermissions: explainedPermissions,
                groupHistory: groupHistory,
                id: id,
                longDateFormat: longDateFormat,
                localeOverride: localeOverride,
                maxSets: maxSets,
                notifications: notifications,
                notificationPermissionRequested:
                    notificationPermissionRequested,
                peekGraph: peekGraph,
                planTrailing: planTrailing,
                restTimers: restTimers,
                shortDateFormat: shortDateFormat,
                showBodyWeight: showBodyWeight,
                showCategories: showCategories,
                showImages: showImages,
                showNotes: showNotes,
                showGlobalProgress: showGlobalProgress,
                showUnits: showUnits,
                strengthUnit: strengthUnit,
                systemColors: systemColors,
                tabs: tabs,
                themeMode: themeMode,
                timerDuration: timerDuration,
                vibrate: vibrate,
                warmupSets: warmupSets,
                scrollableTabs: scrollableTabs,
                showGraphXAxis: showGraphXAxis,
                showGraphLimit: showGraphLimit,
                progressPosition: progressPosition,
                defaultGraphMetric: defaultGraphMetric,
                defaultGraphPeriod: defaultGraphPeriod,
                defaultGraphLimit: defaultGraphLimit,
                defaultGraphTimeBasedXAxis: defaultGraphTimeBasedXAxis,
                keepRinging: keepRinging,
                keepScreenOn: keepScreenOn,
                inputStyle: inputStyle,
                profileName: profileName,
                heightCm: heightCm,
                ageYears: ageYears,
                goals: goals,
                apiKey: apiKey,
                themeId: themeId,
                restVolume: restVolume,
              ),
          createCompanionCallback:
              ({
                required String alarmSound,
                Value<bool> automaticBackups = const Value.absent(),
                Value<String?> backupPath = const Value.absent(),
                Value<int?> buildNumber = const Value.absent(),
                required String cardioUnit,
                required bool curveLines,
                Value<double?> curveSmoothness = const Value.absent(),
                Value<bool> durationEstimation = const Value.absent(),
                Value<bool> enableSound = const Value.absent(),
                required bool explainedPermissions,
                required bool groupHistory,
                Value<int> id = const Value.absent(),
                required String longDateFormat,
                Value<String?> localeOverride = const Value.absent(),
                required int maxSets,
                Value<bool> notifications = const Value.absent(),
                Value<bool> notificationPermissionRequested =
                    const Value.absent(),
                Value<bool> peekGraph = const Value.absent(),
                required String planTrailing,
                required bool restTimers,
                required String shortDateFormat,
                Value<bool> showBodyWeight = const Value.absent(),
                Value<bool> showCategories = const Value.absent(),
                Value<bool> showImages = const Value.absent(),
                Value<bool> showNotes = const Value.absent(),
                Value<bool> showGlobalProgress = const Value.absent(),
                required bool showUnits,
                required String strengthUnit,
                required bool systemColors,
                Value<String> tabs = const Value.absent(),
                required String themeMode,
                required int timerDuration,
                required bool vibrate,
                Value<int?> warmupSets = const Value.absent(),
                Value<bool> scrollableTabs = const Value.absent(),
                Value<bool> showGraphXAxis = const Value.absent(),
                Value<bool> showGraphLimit = const Value.absent(),
                Value<String> progressPosition = const Value.absent(),
                Value<String> defaultGraphMetric = const Value.absent(),
                Value<String> defaultGraphPeriod = const Value.absent(),
                Value<int> defaultGraphLimit = const Value.absent(),
                Value<bool> defaultGraphTimeBasedXAxis = const Value.absent(),
                Value<bool> keepRinging = const Value.absent(),
                Value<bool> keepScreenOn = const Value.absent(),
                Value<String> inputStyle = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<int?> ageYears = const Value.absent(),
                Value<String?> goals = const Value.absent(),
                Value<String?> apiKey = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<double> restVolume = const Value.absent(),
              }) => SettingsCompanion.insert(
                alarmSound: alarmSound,
                automaticBackups: automaticBackups,
                backupPath: backupPath,
                buildNumber: buildNumber,
                cardioUnit: cardioUnit,
                curveLines: curveLines,
                curveSmoothness: curveSmoothness,
                durationEstimation: durationEstimation,
                enableSound: enableSound,
                explainedPermissions: explainedPermissions,
                groupHistory: groupHistory,
                id: id,
                longDateFormat: longDateFormat,
                localeOverride: localeOverride,
                maxSets: maxSets,
                notifications: notifications,
                notificationPermissionRequested:
                    notificationPermissionRequested,
                peekGraph: peekGraph,
                planTrailing: planTrailing,
                restTimers: restTimers,
                shortDateFormat: shortDateFormat,
                showBodyWeight: showBodyWeight,
                showCategories: showCategories,
                showImages: showImages,
                showNotes: showNotes,
                showGlobalProgress: showGlobalProgress,
                showUnits: showUnits,
                strengthUnit: strengthUnit,
                systemColors: systemColors,
                tabs: tabs,
                themeMode: themeMode,
                timerDuration: timerDuration,
                vibrate: vibrate,
                warmupSets: warmupSets,
                scrollableTabs: scrollableTabs,
                showGraphXAxis: showGraphXAxis,
                showGraphLimit: showGraphLimit,
                progressPosition: progressPosition,
                defaultGraphMetric: defaultGraphMetric,
                defaultGraphPeriod: defaultGraphPeriod,
                defaultGraphLimit: defaultGraphLimit,
                defaultGraphTimeBasedXAxis: defaultGraphTimeBasedXAxis,
                keepRinging: keepRinging,
                keepScreenOn: keepScreenOn,
                inputStyle: inputStyle,
                profileName: profileName,
                heightCm: heightCm,
                ageYears: ageYears,
                goals: goals,
                apiKey: apiKey,
                themeId: themeId,
                restVolume: restVolume,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$PlanExercisesTableCreateCompanionBuilder =
    PlanExercisesCompanion Function({
      required bool enabled,
      Value<bool> timers,
      required int exerciseId,
      Value<int> id,
      Value<int?> maxSets,
      required int planId,
      Value<int?> warmupSets,
      Value<int> sequence,
      Value<int?> repMin,
      Value<int?> repMax,
    });
typedef $$PlanExercisesTableUpdateCompanionBuilder =
    PlanExercisesCompanion Function({
      Value<bool> enabled,
      Value<bool> timers,
      Value<int> exerciseId,
      Value<int> id,
      Value<int?> maxSets,
      Value<int> planId,
      Value<int?> warmupSets,
      Value<int> sequence,
      Value<int?> repMin,
      Value<int?> repMax,
    });

final class $$PlanExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanExercisesTable, PlanExercise> {
  $$PlanExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('plan_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('plan_exercises__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanExercisesTable> {
  $$PlanExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timers => $composableBuilder(
    column: $table.timers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSets => $composableBuilder(
    column: $table.maxSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanExercisesTable> {
  $$PlanExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timers => $composableBuilder(
    column: $table.timers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSets => $composableBuilder(
    column: $table.maxSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanExercisesTable> {
  $$PlanExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get timers =>
      $composableBuilder(column: $table.timers, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get maxSets =>
      $composableBuilder(column: $table.maxSets, builder: (column) => column);

  GeneratedColumn<int> get warmupSets => $composableBuilder(
    column: $table.warmupSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get repMin =>
      $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax =>
      $composableBuilder(column: $table.repMax, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanExercisesTable,
          PlanExercise,
          $$PlanExercisesTableFilterComposer,
          $$PlanExercisesTableOrderingComposer,
          $$PlanExercisesTableAnnotationComposer,
          $$PlanExercisesTableCreateCompanionBuilder,
          $$PlanExercisesTableUpdateCompanionBuilder,
          (PlanExercise, $$PlanExercisesTableReferences),
          PlanExercise,
          PrefetchHooks Function({bool exerciseId, bool planId})
        > {
  $$PlanExercisesTableTableManager(_$AppDatabase db, $PlanExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> enabled = const Value.absent(),
                Value<bool> timers = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int?> maxSets = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int?> warmupSets = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
              }) => PlanExercisesCompanion(
                enabled: enabled,
                timers: timers,
                exerciseId: exerciseId,
                id: id,
                maxSets: maxSets,
                planId: planId,
                warmupSets: warmupSets,
                sequence: sequence,
                repMin: repMin,
                repMax: repMax,
              ),
          createCompanionCallback:
              ({
                required bool enabled,
                Value<bool> timers = const Value.absent(),
                required int exerciseId,
                Value<int> id = const Value.absent(),
                Value<int?> maxSets = const Value.absent(),
                required int planId,
                Value<int?> warmupSets = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
              }) => PlanExercisesCompanion.insert(
                enabled: enabled,
                timers: timers,
                exerciseId: exerciseId,
                id: id,
                maxSets: maxSets,
                planId: planId,
                warmupSets: warmupSets,
                sequence: sequence,
                repMin: repMin,
                repMax: repMax,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanExercisesTable, PlanExercise>(table),
                  $$PlanExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$PlanExercisesTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$PlanExercisesTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$PlanExercisesTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$PlanExercisesTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanExercisesTable,
      PlanExercise,
      $$PlanExercisesTableFilterComposer,
      $$PlanExercisesTableOrderingComposer,
      $$PlanExercisesTableAnnotationComposer,
      $$PlanExercisesTableCreateCompanionBuilder,
      $$PlanExercisesTableUpdateCompanionBuilder,
      (PlanExercise, $$PlanExercisesTableReferences),
      PlanExercise,
      PrefetchHooks Function({bool exerciseId, bool planId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExerciseSetsTableTableManager get exerciseSets =>
      $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$BodyWeightsTableTableManager get bodyWeights =>
      $$BodyWeightsTableTableManager(_db, _db.bodyWeights);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PlanExercisesTableTableManager get planExercises =>
      $$PlanExercisesTableTableManager(_db, _db.planExercises);
}
