import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _keyName = 'alpha_ai_key';

Future<String> readAiKey() async {
  try {
    return await _storage.read(key: _keyName) ?? '';
  } catch (error) {
    debugPrint('Secure storage read failed: $error');
    return '';
  }
}

Future<void> writeAiKey(String value) async {
  try {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await _storage.delete(key: _keyName);
      return;
    }
    await _storage.write(key: _keyName, value: trimmed);
  } catch (error) {
    debugPrint('Secure storage write failed: $error');
  }
}
