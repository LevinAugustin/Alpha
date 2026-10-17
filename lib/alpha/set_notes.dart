const warmupTag = 'warmup';

String encodeSetNotes({
  String? gymId,
  bool warmup = false,
  String userNote = '',
}) {
  final tags = <String>[
    if (gymId != null && gymId.isNotEmpty) 'gym:$gymId',
    if (warmup) warmupTag,
  ];
  final note = userNote.trim();
  if (tags.isEmpty) return note;
  final prefix = '[${tags.join(' ')}]';
  if (note.isEmpty) return prefix;
  return '$prefix $note';
}

bool notesAreWarmup(String? notes) =>
    RegExp(r'\[(.*\s)?warmup(\s.*)?\]').hasMatch(notes ?? '');

String? gymIdFromNotes(String? notes) {
  final match = RegExp(r'\[(?:[^\]]* )?gym:([^\s\]]+)').firstMatch(notes ?? '');
  return match?.group(1);
}

String visibleSetNote(String? notes) {
  final raw = notes ?? '';
  return raw.replaceFirst(RegExp(r'^\[[^\]]*\]\s*'), '').trim();
}

bool sameGym(String? notes, String gymId) {
  final tagged = gymIdFromNotes(notes);
  if (tagged == null) return gymId == 'default';
  return tagged == gymId;
}
