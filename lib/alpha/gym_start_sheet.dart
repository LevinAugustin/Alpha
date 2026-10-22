import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

bool hasCreatedStudios(List<GymPlace> gyms) {
  if (gyms.isEmpty) return false;
  if (gyms.length == 1 &&
      gyms.single.id == 'default' &&
      gyms.single.name == 'Studio') {
    return false;
  }
  return true;
}

class GymStartChoice {
  const GymStartChoice({this.gymId});

  final String? gymId;
}

String lastTrainedWhen(AppLocalizations l10n, DateTime when, DateTime now) {
  final day = DateTime(when.year, when.month, when.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return l10n.trainedToday;
  if (days == 1) return l10n.trainedYesterday;
  return l10n.trainedDaysAgo(days);
}

Future<Map<String, DateTime>> latestStudioUse() async {
  final rows =
      await (db.select(db.exerciseSets)
            ..orderBy([(row) => OrderingTerm.desc(row.timestamp)])
            ..limit(400))
          .get();
  final latest = <String, DateTime>{};
  for (final row in rows) {
    final id = gymIdFromNotes(row.notes) ?? 'default';
    latest.putIfAbsent(id, () => row.timestamp);
  }
  return latest;
}

Future<GymStartChoice?> showGymStartSheet(BuildContext context) {
  final palette = AlphaTheme.of(context);
  return showModalBottomSheet<GymStartChoice>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const GymStartSheet(),
  );
}

class GymStartSheet extends StatefulWidget {
  const GymStartSheet({super.key});

  @override
  State<GymStartSheet> createState() => _GymStartSheetState();
}

class _GymStartSheetState extends State<GymStartSheet> {
  String? _selected;
  Map<String, DateTime> _latest = const {};
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _selected = _initialSelection(alphaPrefs.gyms, alphaPrefs.activeGymId);
    _load();
  }

  Future<void> _load() async {
    final latest = await latestStudioUse();
    if (!mounted) return;
    final merged = <String, DateTime>{...latest};
    for (final gym in alphaPrefs.gyms) {
      final stored = gym.lastUsedAt;
      if (stored == null) continue;
      final known = merged[gym.id];
      if (known == null || stored.isAfter(known)) merged[gym.id] = stored;
    }
    setState(() {
      _latest = merged;
      _selected = _initialSelection(
        alphaPrefs.gyms,
        alphaPrefs.activeGymId,
        latest: merged,
      );
      _ready = true;
    });
  }

  Future<void> _addStudio() async {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text(l10n.newGym),
        content: TextField(
          key: const Key('new-studio-field'),
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: l10n.gymNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    final gym = GymPlace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    alphaPrefs.gyms.add(gym);
    await alphaPrefs.save();
    if (!mounted) return;
    setState(() => _selected = gym.id);
  }

  void _start() {
    final selected = _selected;
    if (selected == null) return;
    Navigator.pop(context, GymStartChoice(gymId: selected));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final gyms = alphaPrefs.gyms;
    final created = hasCreatedStudios(gyms);
    final now = DateTime.now();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          key: const Key('gym-start-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              l10n.trainWhereTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 32,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 16),
            if (!created)
              Text(
                l10n.noStudiosYet,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.muted),
              )
            else
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: gyms.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    final selected = gym.id == _selected;
                    final when = _latest[gym.id];
                    return InkWell(
                      key: Key('gym-card-${gym.id}'),
                      onTap: () => setState(() => _selected = gym.id),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 148,
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? palette.accent : palette.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _StudioMark(),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    gym.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: palette.text,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    color: palette.accent,
                                    size: 18,
                                  ),
                              ],
                            ),
                            if (when != null && _ready)
                              Text(
                                l10n.lastTrainedLabel(
                                  lastTrainedWhen(l10n, when, now),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.muted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                key: const Key('gym-add-studio'),
                avatar: Icon(Icons.add, color: palette.accent, size: 18),
                label: Text(l10n.newGym),
                onPressed: _addStudio,
              ),
            ),
            const SizedBox(height: 12),
            if (!created)
              OutlinedButton(
                key: const Key('gym-start-without'),
                onPressed: () => Navigator.pop(context, const GymStartChoice()),
                child: Text(l10n.startWithoutStudio),
              ),
            if (!created) const SizedBox(height: 8),
            FilledButton(
              key: const Key('gym-start-confirm'),
              onPressed: created && _selected != null ? _start : null,
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onAccent,
                minimumSize: const Size.fromHeight(52),
                textStyle: const TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 22,
                ),
              ),
              child: Text(l10n.startTrainingAction),
            ),
            TextButton(
              key: const Key('gym-start-cancel'),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }
}

String? _initialSelection(
  List<GymPlace> gyms,
  String activeId, {
  Map<String, DateTime> latest = const {},
}) {
  if (!hasCreatedStudios(gyms)) return null;
  GymPlace? best;
  DateTime? bestTime;
  for (final gym in gyms) {
    final when = latest[gym.id] ?? gym.lastUsedAt;
    if (when == null) continue;
    if (bestTime == null || when.isAfter(bestTime)) {
      best = gym;
      bestTime = when;
    }
  }
  if (best != null) return best.id;
  if (gyms.any((gym) => gym.id == activeId)) return activeId;
  return gyms.first.id;
}

class _StudioMark extends StatelessWidget {
  const _StudioMark();

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    return SizedBox(
      height: 64,
      child: Stack(
        children: [
          Icon(Icons.apartment, size: 54, color: palette.text),
          Positioned(
            right: 8,
            bottom: 4,
            child: Icon(Icons.fitness_center, size: 28, color: palette.accent),
          ),
        ],
      ),
    );
  }
}
