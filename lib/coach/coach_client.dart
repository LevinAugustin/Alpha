import 'dart:convert';
import 'dart:io';

import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/coach/api_key_store.dart';

class CoachReply {
  const CoachReply({required this.text, this.suggestion});

  final String text;
  final String? suggestion;
}

Future<CoachReply?> askCoach(String prompt) async {
  final key = await readAiKey();
  if (key.isEmpty) return null;
  final provider = alphaPrefs.aiProvider;
  final system =
      'Du bist der Trainingscoach in der App Alpha. Antworte kurz auf Deutsch. '
      'Wenn du eine Planänderung vorschlägst, setze eine Zeile an den Anfang: '
      'VORSCHLAG: <ein Satz>.';
  try {
    final text = await _complete(provider, key, system, prompt);
    if (text == null || text.trim().isEmpty) return null;
    final lines = text.trim().split('\n');
    String? suggestion;
    final body = <String>[];
    for (final line in lines) {
      if (line.startsWith('VORSCHLAG:')) {
        suggestion = line.substring('VORSCHLAG:'.length).trim();
      } else {
        body.add(line);
      }
    }
    return CoachReply(
      text: body.join('\n').trim().isEmpty
          ? text.trim()
          : body.join('\n').trim(),
      suggestion: suggestion,
    );
  } catch (_) {
    return null;
  }
}

Future<({double? kg, double? reps, String? exercise})?> parseVoiceCommand(
  String transcript,
) async {
  final local = _localParse(transcript);
  final key = await readAiKey();
  if (key.isEmpty) return local;
  final reply = await _complete(
    alphaPrefs.aiProvider,
    key,
    'Wandle die Trainingsansage in JSON um: {"kg": number|null, "reps": number|null, "exercise": string|null}. Nur JSON.',
    transcript,
  );
  if (reply == null) return local;
  try {
    final start = reply.indexOf('{');
    final end = reply.lastIndexOf('}');
    if (start < 0 || end <= start) return local;
    final json =
        jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;
    return (
      kg: (json['kg'] as num?)?.toDouble() ?? local?.kg,
      reps: (json['reps'] as num?)?.toDouble() ?? local?.reps,
      exercise: json['exercise'] as String? ?? local?.exercise,
    );
  } catch (_) {
    return local;
  }
}

({double? kg, double? reps, String? exercise})? _localParse(String transcript) {
  final kg = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*kg',
    caseSensitive: false,
  ).firstMatch(transcript);
  final reps = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(wdh|wiederhol)',
    caseSensitive: false,
  ).firstMatch(transcript);
  if (kg == null && reps == null) return null;
  return (
    kg: kg == null ? null : double.tryParse(kg.group(1)!.replaceAll(',', '.')),
    reps: reps == null
        ? null
        : double.tryParse(reps.group(1)!.replaceAll(',', '.')),
    exercise: null,
  );
}

Future<String?> _complete(
  String provider,
  String key,
  String system,
  String prompt,
) async {
  final client = HttpClient();
  try {
    late final Uri uri;
    late final Map<String, dynamic> body;
    final headers = <String, String>{'Content-Type': 'application/json'};
    switch (provider) {
      case 'grok':
        uri = Uri.parse('https://api.x.ai/v1/chat/completions');
        headers['Authorization'] = 'Bearer $key';
        body = {
          'model': 'grok-3-mini',
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': prompt},
          ],
        };
      case 'openai':
        uri = Uri.parse('https://api.openai.com/v1/chat/completions');
        headers['Authorization'] = 'Bearer $key';
        body = {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': prompt},
          ],
        };
      default:
        uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key',
        );
        body = {
          'system_instruction': {
            'parts': [
              {'text': system},
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        };
    }
    final request = await client.postUrl(uri);
    headers.forEach(request.headers.set);
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    final raw = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (provider == 'gemini') {
      final candidates = json['candidates'] as List?;
      final parts = (candidates?.first as Map?)?['content']?['parts'] as List?;
      return parts?.map((part) => (part as Map)['text']).join('\n');
    }
    final choices = json['choices'] as List?;
    return (choices?.first as Map?)?['message']?['content'] as String?;
  } finally {
    client.close();
  }
}
