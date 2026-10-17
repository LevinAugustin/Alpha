import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/main.dart';
import 'package:flexify/storage/app_storage_native.dart';
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
  ProfileRegistry({required this.activeId, required this.profiles});

  String activeId;
  final List<LocalProfile> profiles;

  LocalProfile get active =>
      profiles.firstWhere((profile) => profile.id == activeId);
}

Future<Directory> profileSupportDirectory() async {
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
  if (!await file.exists()) {
    final registry = ProfileRegistry(
      activeId: defaultProfileId,
      profiles: const [
        LocalProfile(
          id: defaultProfileId,
          name: 'Levin',
          fileName: databaseFileName,
        ),
      ],
    );
    await saveProfileRegistry(registry);
    return registry;
  }
  final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final profiles = (decoded['profiles'] as List)
      .map(
        (row) => LocalProfile.fromJson(Map<String, dynamic>.from(row as Map)),
      )
      .toList();
  return ProfileRegistry(
    activeId: decoded['active'] as String,
    profiles: profiles,
  );
}

Future<void> saveProfileRegistry(ProfileRegistry registry) async {
  final file = await _registryFile();
  await file.writeAsString(
    jsonEncode({
      'active': registry.activeId,
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
