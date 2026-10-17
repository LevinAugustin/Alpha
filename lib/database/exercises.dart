import 'package:drift/drift.dart';
import 'package:flexify/database/categories.dart';

/// Stable exercise identity and configuration shared across plans and history.
@TableIndex(name: 'exercises_category_id', columns: {#categoryId})
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get kind => text()();
  TextColumn get displayUnit => text()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get image => text().nullable()();
  IntColumn get defaultRestDurationMs => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get graphMetric =>
      text().withDefault(const Constant('bestWeight'))();
  TextColumn get graphPeriod => text().withDefault(const Constant('day'))();
  IntColumn get graphLimit => integer().withDefault(const Constant(20))();
  BoolColumn get graphTimeBasedXAxis =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get germanName => text().nullable()();
  TextColumn get aliases => text().nullable()();
  TextColumn get muscle => text().nullable()();
  TextColumn get catalogId => text().nullable().unique()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get equipment => text().nullable()();
  TextColumn get primaryMuscles => text().nullable()();
  TextColumn get secondaryMuscles => text().nullable()();
  TextColumn get split => text().nullable()();
  TextColumn get mechanic => text().nullable()();
  TextColumn get steps => text().nullable()();
  TextColumn get tips => text().nullable()();
  TextColumn get catalogSource => text().nullable()();
  TextColumn get catalogLicense => text().nullable()();
}
