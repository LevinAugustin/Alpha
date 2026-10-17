import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/body_weight_repository.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/main.dart';
import 'package:flexify/storage/app_storage_native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const defaultProfileId = 'default';
const profileRegistryName = 'alpha_profiles.json';

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.name,
    required this.fileName,
  });

  final String id;
  final String name;
  final String fileName;

  LocalProfile copyWith({String? name}) =>
      LocalProfile(id: id, name: name ?? this.name, fileName: fileName);

  Map<String, String> toJson() => {'id': id, 'name': name, 'file': fileName};

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      fileName: json['file'] as String,
    );
  }
}

class ProfileRegistry {
  ProfileRegistry({
    required this.activeId,
    required this.profiles,
    required this.onboarded,
  });

  String activeId;
  final List<LocalProfile> profiles;
  final bool onboarded;

  LocalProfile get active {
    for (final profile in profiles) {
      if (profile.id == activeId) return profile;
    }
    if (profiles.isNotEmpty) return profiles.first;
    return const LocalProfile(
      id: defaultProfileId,
      name: '',
      fileName: databaseFileName,
    );
  }
}

Directory? _testSupportDirectory;
Directory? profileSupportDirectoryOverride;

Future<Directory> profileSupportDirectory() async {
  final override = profileSupportDirectoryOverride;
  if (override != null) {
    override.createSync(recursive: true);
    return override;
  }
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    final cached = _testSupportDirectory;
    if (cached != null) return cached;
    final created = Directory.systemTemp.createTempSync('alpha-test-support-');
    _testSupportDirectory = created;
    return created;
  }
  final support = await getApplicationSupportDirectory();
  await support.create(recursive: true);
  return support;
}

Future<File> _registryFile() async {
  final support = await profileSupportDirectory();
  return File(p.join(support.path, profileRegistryName));
}

Future<ProfileRegistry> loadProfileRegistry() async {
  final file = await _registryFile();
  if (file.existsSync()) return _readRegistry(file);
  final support = await profileSupportDirectory();
  final databaseFile = File(p.join(support.path, databaseFileName));
  if (databaseFile.existsSync()) {
    final adopted = await _adoptExistingDatabase(databaseFile);
    await saveProfileRegistry(adopted);
    return adopted;
  }
  final fresh = ProfileRegistry(
    activeId: defaultProfileId,
    profiles: const [],
    onboarded: false,
  );
  await saveProfileRegistry(fresh);
  return fresh;
}

ProfileRegistry _readRegistry(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final profiles = (decoded['profiles'] as List? ?? const [])
      .map(
        (row) => LocalProfile.fromJson(Map<String, dynamic>.from(row as Map)),
      )
      .toList();
  final marked = decoded['onboarded'];
  return ProfileRegistry(
    activeId: decoded['active'] as String? ?? defaultProfileId,
    profiles: profiles,
    onboarded: marked is bool ? marked : profiles.isNotEmpty,
  );
}

Future<ProfileRegistry> _adoptExistingDatabase(File databaseFile) async {
  var name = 'Levin';
  try {
    final database = AppDatabase.forPath(databaseFile.path);
    try {
      final setting = await (database.settings.select()..limit(1))
          .getSingleOrNull();
      final stored = setting?.profileName?.trim() ?? '';
      if (stored.isNotEmpty) {
        name = stored;
      } else if (setting != null) {
        await database.settings.update().write(
          const SettingsCompanion(profileName: Value('Levin')),
        );
      }
    } finally {
      await database.close();
    }
  } catch (error, stack) {
    debugPrint('Could not read the existing profile: $error\n$stack');
  }
  return ProfileRegistry(
    activeId: defaultProfileId,
    profiles: [
      LocalProfile(
        id: defaultProfileId,
        name: name,
        fileName: databaseFileName,
      ),
    ],
    onboarded: true,
  );
}

Future<bool> installNeedsOnboarding() async {
  final registry = await loadProfileRegistry();
  return !registry.onboarded;
}

Future<void> ensureWidgetTestProfile() async {
  if (!Platform.environment.containsKey('FLUTTER_TEST')) return;
  if (profileSupportDirectoryOverride != null) return;
  final registry = await loadProfileRegistry();
  if (registry.onboarded && registry.active.name.trim().isNotEmpty) return;
  await saveProfileRegistry(
    ProfileRegistry(
      activeId: defaultProfileId,
      profiles: const [
        LocalProfile(
          id: defaultProfileId,
          name: 'Levin',
          fileName: databaseFileName,
        ),
      ],
      onboarded: true,
    ),
  );
}

Future<void> completeOnboarding({
  required String name,
  double? bodyWeight,
  String? unit,
}) async {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return;
  final chosen = unit == 'lb' ? 'lb' : (unit == 'kg' ? 'kg' : null);
  final kilos = bodyWeight == null
      ? null
      : canonicalBodyWeightKg(chosen ?? 'kg', bodyWeight);
  await db.settings.update().write(
    SettingsCompanion(
      profileName: Value(trimmed),
      strengthUnit: chosen == null ? const Value.absent() : Value(chosen),
    ),
  );
  if (kilos != null && kilos > 0) {
    await recordBodyWeight(db, timestamp: DateTime.now(), weightKg: kilos);
  }
  await saveProfileRegistry(
    ProfileRegistry(
      activeId: defaultProfileId,
      profiles: [
        LocalProfile(
          id: defaultProfileId,
          name: trimmed,
          fileName: databaseFileName,
        ),
      ],
      onboarded: true,
    ),
  );
}

Future<void> saveProfileRegistry(ProfileRegistry registry) async {
  final file = await _registryFile();
  file.writeAsStringSync(
    jsonEncode({
      'active': registry.activeId,
      'onboarded': registry.onboarded,
      'profiles': registry.profiles.map((profile) => profile.toJson()).toList(),
    }),
  );
}

Future<AppDatabase> openProfileDatabase(LocalProfile profile) async {
  if (profile.fileName == databaseFileName) return AppDatabase.persistent();
  final support = await profileSupportDirectory();
  return AppDatabase.forPath(p.join(support.path, profile.fileName));
}

Future<AppDatabase> openActiveProfile() async {
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      await getDatabaseFile();
    } catch (error, stack) {
      debugPrint('Database lookup failed: $error\n$stack');
    }
  }
  final registry = await loadProfileRegistry();
  return openProfileDatabase(registry.active);
}

Future<void> rememberProfileName(String? name) async {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return;
  final registry = await loadProfileRegistry();
  final index = registry.profiles.indexWhere(
    (profile) => profile.id == registry.activeId,
  );
  if (index < 0 || registry.profiles[index].name == trimmed) return;
  registry.profiles[index] = registry.profiles[index].copyWith(name: trimmed);
  await saveProfileRegistry(registry);
}

Future<LocalProfile> createLocalProfile(String name) async {
  final trimmed = name.trim();
  final id = 'p${DateTime.now().microsecondsSinceEpoch}';
  final profile = LocalProfile(
    id: id,
    name: trimmed,
    fileName: 'profile_$id.sqlite',
  );
  final database = await openProfileDatabase(profile);
  await database.settings.update().write(
    SettingsCompanion(profileName: Value(trimmed)),
  );
  await seedExerciseCatalog(database);
  await database.close();
  final registry = await loadProfileRegistry();
  registry.profiles.add(profile);
  registry.activeId = profile.id;
  await saveProfileRegistry(registry);
  return profile;
}

Future<void> activateLocalProfile(LocalProfile profile) async {
  final registry = await loadProfileRegistry();
  registry.activeId = profile.id;
  await saveProfileRegistry(registry);
  final next = await openProfileDatabase(profile);
  await seedExerciseCatalog(next);
  final previous = db;
  db = next;
  dbVersion.value++;
  await previous.close();
}
