import 'dart:convert';
import 'dart:io';

import 'package:flexify/profile/local_profiles.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class GymPlace {
  GymPlace({required this.id, required this.name, this.lastUsedAt});

  final String id;
  String name;
  DateTime? lastUsedAt;

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    if (lastUsedAt != null) 'lastUsedAt': lastUsedAt!.toIso8601String(),
  };

  factory GymPlace.fromJson(Map<String, dynamic> json) => GymPlace(
    id: json['id'] as String,
    name: json['name'] as String,
    lastUsedAt: DateTime.tryParse(json['lastUsedAt'] as String? ?? ''),
  );
}

class AlphaPrefs extends ChangeNotifier {
  int weeklyGoal = 5;
  bool weeklyGoalManual = true;
  bool progression = false;
  String aiProvider = 'gemini';
  String coachNote = '';
  List<GymPlace> gyms = [GymPlace(id: 'default', name: 'Studio')];
  String activeGymId = 'default';
  double barKg = 20;
  List<double> plates = [25, 20, 15, 10, 5, 2.5, 1.25];
  double dumbbellHandleKg = 2.5;
  String lengthUnit = 'cm';
  final Map<String, double> nextWeight = {};
  final Map<String, int> nextReps = {};

  GymPlace get activeGym =>
      gyms.firstWhere((gym) => gym.id == activeGymId, orElse: () => gyms.first);

  void applyStored(Map<String, dynamic> json) {
    weeklyGoal = (json['weeklyGoal'] as num?)?.toInt() ?? weeklyGoal;
    weeklyGoalManual = json['weeklyGoalManual'] as bool? ?? weeklyGoalManual;
    progression = json['progression'] as bool? ?? progression;
    aiProvider = json['aiProvider'] as String? ?? aiProvider;
    coachNote = json['coachNote'] as String? ?? coachNote;
    activeGymId = json['activeGymId'] as String? ?? activeGymId;
    barKg = (json['barKg'] as num?)?.toDouble() ?? barKg;
    dumbbellHandleKg =
        _positiveKg(json['dumbbellHandleKg']) ?? dumbbellHandleKg;
    lengthUnit = json['lengthUnit'] as String? ?? lengthUnit;
    final storedPlates = json['plates'];
    if (storedPlates is List && storedPlates.isNotEmpty) {
      plates = storedPlates.map((value) => (value as num).toDouble()).toList();
    }
    final storedGyms = json['gyms'];
    if (storedGyms is List && storedGyms.isNotEmpty) {
      gyms = storedGyms
          .map(
            (row) => GymPlace.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    }
    nextWeight
      ..clear()
      ..addAll(
        ((json['nextWeight'] as Map?) ?? const {}).map(
          (key, value) => MapEntry('$key', (value as num).toDouble()),
        ),
      );
    nextReps
      ..clear()
      ..addAll(
        ((json['nextReps'] as Map?) ?? const {}).map(
          (key, value) => MapEntry('$key', (value as num).toInt()),
        ),
      );
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      applyStored(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
      notifyListeners();
    } catch (error, stack) {
      debugPrint('Alpha prefs unavailable: $error\n$stack');
    }
  }

  Future<void> save() async {
    final file = await _file();
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      jsonEncode({
        'weeklyGoal': weeklyGoal,
        'weeklyGoalManual': weeklyGoalManual,
        'progression': progression,
        'aiProvider': aiProvider,
        'coachNote': coachNote,
        'activeGymId': activeGymId,
        'barKg': barKg,
        'dumbbellHandleKg': dumbbellHandleKg,
        'lengthUnit': lengthUnit,
        'plates': plates,
        'gyms': gyms.map((gym) => gym.toJson()).toList(),
        'nextWeight': nextWeight,
        'nextReps': nextReps,
      }),
    );
    notifyListeners();
  }

  Future<File> _file() async {
    final registry = await loadProfileRegistry();
    final support = await profileSupportDirectory();
    return File(p.join(support.path, '${registry.activeId}.alpha.json'));
  }
}

double? _positiveKg(Object? value) {
  if (value is! num) return null;
  final kg = value.toDouble();
  if (kg <= 0) return null;
  return kg;
}

final alphaPrefs = AlphaPrefs();
