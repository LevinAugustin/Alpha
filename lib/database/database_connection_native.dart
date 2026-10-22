import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flexify/storage/app_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

QueryExecutor createConnectionForPath(String path) {
  final file = File(path);
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return DatabaseConnection(
      NativeDatabase(file, setup: _configureDatabase),
      closeStreamsSynchronously: true,
    );
  }
  return NativeDatabase.createInBackground(file, setup: _configureDatabase);
}

QueryExecutor createPersistentConnection() {
  return LazyDatabase(() async {
    final file = await getDatabaseFile();

    final cache = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cache;
    return NativeDatabase.createInBackground(file, setup: _configureDatabase);
  });
}

void _configureDatabase(Database database) {
  database.execute('PRAGMA busy_timeout = 5000');
  database.execute('PRAGMA foreign_keys = ON');
}
