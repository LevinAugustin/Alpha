import 'dart:convert';
import 'dart:io';

import 'package:flexify/database/catalog_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog =
      jsonDecode(File('assets/exercises/exercises_de.json').readAsStringSync())
          as List;
  final cases =
      (jsonDecode(File('test/fixtures/suchtests.json').readAsStringSync())
              as Map)['tests']
          as List;

  List<Map<String, dynamic>> rows() => [
    for (final row in catalog) Map<String, dynamic>.from(row as Map),
  ];

  String aliasesOf(Map<String, dynamic> exercise) =>
      (exercise['synonyme'] as List).join('|');

  String englishAliasesOf(Map<String, dynamic> exercise) {
    final raw = exercise['synonyme_en'];
    if (raw is! List) return '';
    return raw.join('|');
  }

  bool matches(Map<String, dynamic> exercise, String query) {
    return exerciseMatchesQuery(
      name: exercise['id'] as String,
      germanName: exercise['name_de'] as String?,
      aliases: aliasesOf(exercise),
      englishName: exercise['name_en'] as String?,
      englishAliases: englishAliasesOf(exercise),
      category: exercise['kategorie'] as String?,
      equipment: exercise['geraet'] as String?,
      primaryMuscles: jsonEncode(exercise['primaermuskeln']),
      secondaryMuscles: jsonEncode(exercise['sekundaermuskeln']),
      familie: exercise['familie'] as String?,
      grip: exercise['griff'] as String?,
      position: exercise['position'] as String?,
      movement: exercise['bewegung'] as String?,
      query: query,
    );
  }

  List<String> search(String query) {
    final hits = [
      for (final exercise in rows())
        if (matches(exercise, query)) exercise,
    ];
    hits.sort(
      (left, right) => compareExerciseSearch(
        query: query,
        leftName: left['id'] as String,
        leftGermanName: left['name_de'] as String?,
        leftAliases: aliasesOf(left),
        leftEnglishName: left['name_en'] as String?,
        leftEnglishAliases: englishAliasesOf(left),
        rightName: right['id'] as String,
        rightGermanName: right['name_de'] as String?,
        rightAliases: aliasesOf(right),
        rightEnglishName: right['name_en'] as String?,
        rightEnglishAliases: englishAliasesOf(right),
      ),
    );
    return [for (final hit in hits) hit['id'] as String];
  }

  List<String> exact(String query) {
    final hits = [
      for (final exercise in rows())
        if (exerciseExactNameOrAlias(
          name: exercise['id'] as String,
          germanName: exercise['name_de'] as String?,
          aliases: aliasesOf(exercise),
          englishName: exercise['name_en'] as String?,
          englishAliases: englishAliasesOf(exercise),
          query: query,
        ))
          exercise,
    ];
    hits.sort(
      (left, right) => compareExerciseSearch(
        query: query,
        leftName: left['id'] as String,
        leftGermanName: left['name_de'] as String?,
        leftAliases: aliasesOf(left),
        leftEnglishName: left['name_en'] as String?,
        leftEnglishAliases: englishAliasesOf(left),
        rightName: right['id'] as String,
        rightGermanName: right['name_de'] as String?,
        rightAliases: aliasesOf(right),
        rightEnglishName: right['name_en'] as String?,
        rightEnglishAliases: englishAliasesOf(right),
      ),
    );
    return [for (final hit in hits) hit['id'] as String];
  }

  test('suchtests.json matches the 2.5.1 search spec', () {
    expect(cases, hasLength(50));
    for (final raw in cases) {
      final item = Map<String, dynamic>.from(raw as Map);
      final query = item['suchbegriff'] as String;
      final hits = search(query);
      final must = [
        for (final id in item['muss_enthalten'] as List) id as String,
      ];
      final banned = [
        for (final id in (item['darf_nicht_enthalten'] as List?) ?? const [])
          id as String,
      ];
      expect(hits, containsAll(must), reason: query);
      for (final id in banned) {
        expect(hits.contains(id), isFalse, reason: '$query / $id');
      }
      if (item['darf_nicht_leer'] != false) {
        expect(hits, isNotEmpty, reason: query);
      }
      final minimum = item['min_treffer'];
      if (minimum is int) {
        expect(hits.length, greaterThanOrEqualTo(minimum), reason: query);
      }
      final first = item['erster'];
      if (first is String) expect(hits.first, first, reason: query);
      final order = item['vor_allen'];
      if (order is Map) {
        final front = [
          for (final id in order['vorne'] as List)
            if (hits.contains(id)) hits.indexOf(id as String),
        ];
        final back = [
          for (final id in order['hinten'] as List)
            if (hits.contains(id)) hits.indexOf(id as String),
        ];
        if (front.isNotEmpty && back.isNotEmpty) {
          expect(
            front.reduce((left, right) => left > right ? left : right),
            lessThan(back.reduce((left, right) => left < right ? left : right)),
            reason: query,
          );
        }
      }
    }
  });

  test('hevy matching is a normalized exact name or synonym', () {
    expect(exact('Lat Pulldown').first, 'latziehen-breit');
    expect(exact('Lat Pulldown extra'), isEmpty);
    expect(exact('Hüftabduktion'), ['abduktorenmaschine', 'abduktion-kabel']);
    expect(exact('Trizepsdrücken (Maschine)'), [
      'dipmaschine',
      'trizepsmaschine',
    ]);
    expect(
      exerciseExactNameOrAlias(
        name: 'latziehen-breit',
        germanName: 'Latziehen',
        aliases: 'Lat Pulldown|Latzug',
        query: 'breit',
      ),
      isFalse,
    );
    expect(
      exerciseMatchesQuery(
        name: 'latziehen-breit',
        germanName: 'Latziehen',
        aliases: 'Lat Pulldown|Latzug',
        query: 'breit',
      ),
      isTrue,
    );
  });

  test('english names and synonyms are searchable', () {
    expect(search('lat pulldown').first, 'latziehen-breit');
    expect(search('hammer curl rope'), ['hammercurls-seil']);
    expect(search('hammer curl'), contains('hammercurls-seil'));
    expect(exact('Cable Rope Hammer Curl'), ['hammercurls-seil']);
  });
}
