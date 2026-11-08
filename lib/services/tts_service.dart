import 'package:flutter_tts/flutter_tts.dart';
import 'settings_service.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(
          SettingsService().language == AppLanguage.fil ? 'fil-PH' : 'en-US');
      await _tts.speak(text);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}