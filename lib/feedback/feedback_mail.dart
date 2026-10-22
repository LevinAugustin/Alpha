const feedbackAddress = 'alpha-feedback@mail.grokbot.com';

String feedbackBuildLabel(String build) {
  final trimmed = build.trim();
  final code = int.tryParse(trimmed);
  if (code == null || code < 100) return trimmed;
  final abi = code % 100;
  if (abi < 1 || abi > 3) return trimmed;
  return '${code ~/ 100}';
}

enum FeedbackCategory { bug, improvement, translation }

class FeedbackDraft {
  const FeedbackDraft({
    required this.category,
    required this.categoryLabel,
    required this.message,
    required this.version,
    required this.build,
    required this.language,
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    this.exerciseName,
    this.exerciseId,
    this.attachmentPath,
    this.german = false,
  });

  final FeedbackCategory category;
  final String categoryLabel;
  final String message;
  final String version;
  final String build;
  final String language;
  final String manufacturer;
  final String model;
  final String androidVersion;
  final String? exerciseName;
  final String? exerciseId;
  final String? attachmentPath;
  final bool german;

  String get subject => '[Alpha-Feedback] $categoryLabel $version+$build';

  String get body {
    final versionLabel = german ? 'App-Version' : 'App version';
    final languageLabel = german ? 'Sprache' : 'Language';
    final exerciseLabel = german ? 'Übung' : 'Exercise';
    final deviceLabel = german ? 'Gerät' : 'Device';
    final lines = <String>[
      '$versionLabel: $version+$build',
      '$languageLabel: $language',
    ];
    final name = (exerciseName ?? '').trim();
    final id = (exerciseId ?? '').trim();
    if (name.isNotEmpty || id.isNotEmpty) {
      lines.add('$exerciseLabel: $name ($id)'.trim());
    }
    lines.add('$deviceLabel: $manufacturer $model, Android $androidVersion');
    lines.add('');
    lines.add(message.trim());
    return lines.join('\n');
  }
}
