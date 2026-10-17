import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/coach/api_key_store.dart';
import 'package:flexify/coach/coach_client.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final _input = TextEditingController();
  final _lines = <_Line>[];
  var _ready = false;
  var _hasKey = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await readAiKey();
    if (!mounted) return;
    setState(() {
      _hasKey = key.trim().isNotEmpty;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiCoachTitle)),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : !_hasKey
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.aiOffNotice),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final line in _lines)
                        Align(
                          alignment: line.mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: line.mine
                                  ? AlphaTheme.of(
                                      context,
                                    ).accent.withValues(alpha: 0.2)
                                  : AlphaTheme.of(context).card,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(line.text),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(hintText: l10n.coachHint),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : _send,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _send() async {
    final prompt = _input.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _busy = true;
      _lines.add(_Line(prompt, true));
      _input.clear();
    });
    final history = await _recentTraining();
    final note = alphaPrefs.coachNote.trim();
    final reply = await askCoach(
      '${note.isEmpty ? '' : 'Notiz: $note\n'}'
      '${history.isEmpty ? '' : 'Letzte Sätze:\n$history\n'}'
      'Frage: $prompt',
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lines.add(_Line(reply?.text ?? context.l10n.aiOffNotice, false));
    });
    final suggestion = reply?.suggestion;
    if (suggestion == null || suggestion.isEmpty || !mounted) return;
    final palette = AlphaTheme.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        content: Text(suggestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionReject),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionAccept),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    final current = alphaPrefs.coachNote.trim();
    alphaPrefs.coachNote = current.isEmpty
        ? suggestion
        : '$current\n$suggestion';
    await alphaPrefs.save();
  }

  Future<String> _recentTraining() async {
    final rows = await (db.select(db.exerciseSets).join([
      innerJoin(
        db.exercises,
        db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
      ),
    ])).get();
    rows.sort(
      (a, b) => b
          .readTable(db.exerciseSets)
          .timestamp
          .compareTo(a.readTable(db.exerciseSets).timestamp),
    );
    final lines = <String>[];
    for (final row in rows.take(12)) {
      final set = row.readTable(db.exerciseSets);
      if ((set.notes ?? '').contains('warmup')) continue;
      final exercise = row.readTable(db.exercises);
      final name = exercise.germanName ?? exercise.name;
      lines.add('$name ${set.loadKg ?? 0} kg × ${set.reps ?? 0}');
    }
    return lines.join('\n');
  }
}

class _Line {
  const _Line(this.text, this.mine);

  final String text;
  final bool mine;
}
