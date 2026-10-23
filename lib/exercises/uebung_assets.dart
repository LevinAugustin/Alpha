import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

final _idPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
const _storedImagePrefix = 'assets/exercises/img/';

const uebungAssetRoot = 'assets/uebungen';
const uebungManifestAsset = '$uebungAssetRoot/manifest.json';

final _assetName = RegExp(
  '^$uebungAssetRoot/(icons/)?([a-z0-9]+(?:-[a-z0-9]+)*)\\.(mp4|webp)\$',
);

enum ExerciseVisualKind { clip, still, none }

class ExerciseVisual {
  const ExerciseVisual.clip(this.clip, this.still)
    : kind = ExerciseVisualKind.clip;

  const ExerciseVisual.still(this.still)
    : kind = ExerciseVisualKind.still,
      clip = null;

  const ExerciseVisual.none()
    : kind = ExerciseVisualKind.none,
      clip = null,
      still = null;

  final ExerciseVisualKind kind;
  final String? clip;
  final String? still;
}

class _Slot {
  _Slot(this.id);

  final String id;
  String? clip;
  String? still;
  String? icon;
}

class UebungAssetIndex {
  const UebungAssetIndex._(this._byId, this._variants, this.bundled);

  static const empty = UebungAssetIndex._({}, {}, {});

  final Map<String, _Slot> _byId;
  final Map<String, String> _variants;
  final Set<String> bundled;

  factory UebungAssetIndex.parse(Object? decoded, Set<String> bundled) {
    final byId = <String, _Slot>{};
    final variants = <String, String>{};
    final rows = decoded is Map ? decoded['uebungen'] : null;
    if (rows is List) {
      for (final row in rows) {
        if (row is! Map) continue;
        final id = _catalogId(row['id']);
        if (id == null) continue;
        final slot = byId.putIfAbsent(id, () => _Slot(id));
        final files = row['dateien'];
        if (files is List) {
          for (final file in files) {
            if (file is! Map) continue;
            final path = _declaredPath(file['datei']);
            if (path == null || !bundled.contains(path)) continue;
            switch ('${file['rolle']}') {
              case 'clip':
                if (path.endsWith('.mp4')) slot.clip = path;
              case 'standbild':
                if (path.endsWith('.webp')) slot.still = path;
              case 'icon256':
                if (path.endsWith('.webp')) slot.icon = path;
            }
          }
        }
        final parent = _catalogId(row['variant_of']);
        final key = _catalogId(row['key']);
        if (parent != null && key != null) variants['$parent/$key'] = id;
      }
    }
    for (final path in bundled) {
      final match = _assetName.firstMatch(path);
      if (match == null) continue;
      final id = match.group(2)!;
      final slot = byId.putIfAbsent(id, () => _Slot(id));
      final iconDir = match.group(1) != null;
      final ext = match.group(3);
      if (iconDir && ext == 'webp') {
        slot.icon ??= path;
      } else if (!iconDir && ext == 'mp4') {
        slot.clip ??= path;
      } else if (!iconDir && ext == 'webp') {
        slot.still ??= path;
      }
    }
    return UebungAssetIndex._(byId, variants, bundled);
  }

  ExerciseVisual visual({
    String? catalogId,
    String? variantKey,
    String? variantImage,
  }) {
    final id = _visualId(catalogId, variantKey, variantImage);
    if (id == null) return const ExerciseVisual.none();
    final slot = _byId[id];
    final clip = slot?.clip ?? _present('$id.mp4');
    final still = slot?.still ?? _present('$id.webp');
    if (clip != null) return ExerciseVisual.clip(clip, still);
    if (still != null) return ExerciseVisual.still(still);
    return const ExerciseVisual.none();
  }

  String? icon({String? catalogId, String? imagePath}) {
    final id = _catalogId(catalogId) ?? catalogIdFromStoredImage(imagePath);
    if (id == null) return null;
    return _byId[id]?.icon ?? _present('icons/$id.webp');
  }

  String? _visualId(
    String? catalogId,
    String? variantKey,
    String? variantImage,
  ) {
    final parent = _catalogId(catalogId);
    final key = _catalogId(variantKey);
    if (key != null) {
      if (parent != null) {
        final linked = _variants['$parent/$key'];
        if (linked != null && _hasPicture(linked)) return linked;
      }
      final stem = _bildStem(variantImage);
      if (stem != null && _hasPicture(stem)) return stem;
      return null;
    }
    return parent;
  }

  bool _hasPicture(String id) {
    final slot = _byId[id];
    if (slot != null && (slot.clip != null || slot.still != null)) return true;
    return _present('$id.mp4') != null || _present('$id.webp') != null;
  }

  String? _present(String relative) {
    final path = '$uebungAssetRoot/$relative';
    return bundled.contains(path) ? path : null;
  }
}

UebungAssetIndex uebungAssetIndex = UebungAssetIndex.empty;

void installUebungAssetIndex(UebungAssetIndex index) {
  uebungAssetIndex = index;
}

void resetUebungAssetIndex() {
  uebungAssetIndex = UebungAssetIndex.empty;
}

Future<void> loadUebungAssets() async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;
  try {
    final raw = await rootBundle.loadString(uebungManifestAsset);
    final bundle = await AssetManifest.loadFromAssetBundle(rootBundle);
    installUebungAssetIndex(
      UebungAssetIndex.parse(jsonDecode(raw), bundle.listAssets().toSet()),
    );
  } catch (_) {
    installUebungAssetIndex(UebungAssetIndex.empty);
  }
}

String? catalogIdFromStoredImage(String? image) {
  final value = (image ?? '').trim().replaceAll('\\', '/');
  if (!value.startsWith(_storedImagePrefix) || !value.endsWith('.webp')) {
    return null;
  }
  return _catalogId(
    value.substring(_storedImagePrefix.length, value.length - 5),
  );
}

String? _catalogId(Object? value) {
  if (value is! String) return null;
  final id = value.trim();
  if (!_idPattern.hasMatch(id)) return null;
  return id;
}

String? _declaredPath(Object? value) {
  if (value is! String) return null;
  final name = value.trim().replaceAll('\\', '/');
  if (name.isEmpty || name.startsWith('/') || name.contains('..')) return null;
  return '$uebungAssetRoot/$name';
}

String? _bildStem(String? bild) {
  final value = (bild ?? '').trim().replaceAll('\\', '/');
  if (value.contains('/') || value.contains('..')) return null;
  final dot = value.lastIndexOf('.');
  if (dot <= 0) return null;
  final ext = value.substring(dot);
  if (ext != '.webp' && ext != '.mp4') return null;
  return _catalogId(value.substring(0, dot));
}
