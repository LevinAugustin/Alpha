import 'dart:io';

import 'package:flexify/feedback/feedback_mail.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

typedef FeedbackSender = Future<bool> Function(FeedbackDraft draft);

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({
    super.key,
    this.exerciseName,
    this.exerciseId,
    this.sender,
  });

  final String? exerciseName;
  final String? exerciseId;
  final FeedbackSender? sender;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _message = TextEditingController();
  var _category = FeedbackCategory.bug;
  var _recording = false;
  var _sending = false;
  String? _attachment;
  String _version = '2.7.0';
  String _build = '459';
  String _manufacturer = '—';
  String _model = '—';
  String _android = '—';

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadDevice() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _build = feedbackBuildLabel(info.buildNumber);
    } catch (_) {}
    if (!Platform.isAndroid) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final raw = await androidChannel.invokeMethod<Object>('deviceInfo');
      if (raw is Map) {
        _manufacturer = '${raw['manufacturer'] ?? '—'}';
        _model = '${raw['model'] ?? '—'}';
        _android = '${raw['release'] ?? '—'}';
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _dictate() async {
    final code = Localizations.localeOf(context).languageCode;
    final language = code == 'de' ? 'de-DE' : 'en-US';
    String? spoken;
    try {
      spoken = await androidChannel.invokeMethod<String>('listenSpeech', {
        'language': language,
        'preferOffline': true,
      });
    } catch (_) {
      spoken = '';
    }
    if (!mounted) return;
    final text = (spoken ?? '').trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.speechFailed)));
      return;
    }
    final current = _message.text.trim();
    _message.text = current.isEmpty ? text : '$current $text';
    _message.selection = TextSelection.collapsed(offset: _message.text.length);
    setState(() {});
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      String path = '';
      try {
        path =
            await androidChannel.invokeMethod<String>(
              'stopFeedbackRecording',
            ) ??
            '';
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _recording = false;
        _attachment = path.isEmpty ? _attachment : path;
      });
      return;
    }
    final allowed = await Permission.microphone.request();
    if (!allowed.isGranted || !mounted) return;
    try {
      await androidChannel.invokeMethod<String>('startFeedbackRecording');
      if (mounted) setState(() => _recording = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.speechFailed)));
    }
  }

  Future<void> _send() async {
    if (_sending) return;
    final l10n = context.l10n;
    final german = Localizations.localeOf(context).languageCode == 'de';
    final draft = FeedbackDraft(
      category: _category,
      categoryLabel: switch (_category) {
        FeedbackCategory.bug => l10n.feedbackBug,
        FeedbackCategory.improvement => l10n.feedbackImprovement,
        FeedbackCategory.translation => l10n.feedbackTranslation,
      },
      message: _message.text,
      version: _version,
      build: _build,
      language: Localizations.localeOf(context).languageCode,
      manufacturer: _manufacturer,
      model: _model,
      androidVersion: _android,
      exerciseName: widget.exerciseName,
      exerciseId: widget.exerciseId,
      attachmentPath: _attachment,
      german: german,
    );
    setState(() => _sending = true);
    var opened = false;
    try {
      final sender = widget.sender;
      opened = sender != null ? await sender(draft) : await _share(draft);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackMailUnavailable)));
    }
  }

  Future<bool> _share(FeedbackDraft draft) async {
    if (!Platform.isAndroid) return false;
    final opened = await androidChannel.invokeMethod<bool>('shareFeedback', {
      'email': feedbackAddress,
      'subject': draft.subject,
      'body': draft.body,
      'attachment': draft.attachmentPath,
    });
    return opened == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(l10n.feedbackCategory),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(FeedbackCategory.bug, l10n.feedbackBug),
              _chip(FeedbackCategory.improvement, l10n.feedbackImprovement),
              _chip(FeedbackCategory.translation, l10n.feedbackTranslation),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('feedback-message'),
            controller: _message,
            minLines: 6,
            maxLines: 10,
            enableInteractiveSelection: true,
            decoration: InputDecoration(hintText: l10n.feedbackMessageHint),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: FilledButton.icon(
              key: const Key('feedback-dictate'),
              onPressed: _dictate,
              icon: const Icon(Icons.mic, size: 32),
              label: Text(l10n.feedbackDictate),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('feedback-record'),
            onPressed: _toggleRecording,
            icon: Icon(_recording ? Icons.stop : Icons.graphic_eq),
            label: Text(
              _recording
                  ? l10n.feedbackStopRecording
                  : l10n.feedbackAttachAudio,
            ),
          ),
          if ((_attachment ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.audio_file_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_attachment!.split(Platform.pathSeparator).last),
                ),
                IconButton(
                  key: const Key('feedback-remove-audio'),
                  tooltip: l10n.feedbackRemoveAudio,
                  onPressed: () => setState(() => _attachment = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('feedback-send'),
            onPressed: _sending ? null : _send,
            child: Text(l10n.feedbackSend),
          ),
        ],
      ),
    );
  }

  Widget _chip(FeedbackCategory category, String label) {
    return ChoiceChip(
      key: Key('feedback-${category.name}'),
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => setState(() => _category = category),
    );
  }
}
