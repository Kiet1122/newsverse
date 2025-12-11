import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, paused, stopped }

class TTSService {
  final FlutterTts _tts = FlutterTts();
  TtsState _state = TtsState.stopped;

  TtsState get state => _state;

  String _currentText = "";
  int _pausePosition = 0;

  Future<void> init() async {
    final languages = await _tts.getLanguages;

    if (languages.contains('vi-VN')) {
      await _tts.setLanguage('vi-VN');
    } else if (languages.contains('en-US')) {
      await _tts.setLanguage('en-US');
    } else if (languages.isNotEmpty) {
      await _tts.setLanguage(languages.first);
    }

    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _state = TtsState.playing;
    });

    _tts.setCompletionHandler(() {
      _state = TtsState.stopped;
    });

    _tts.setErrorHandler((message) {
      _state = TtsState.stopped;
      print("TTS Error: $message");
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    _currentText = text;
    _pausePosition = 0;

    await _tts.speak(text);
    _state = TtsState.playing;
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = TtsState.stopped;
  }

  Future<void> pause() async {
    await _tts.stop();
    _state = TtsState.paused;
  }

  Future<void> resume() async {
    if (_state != TtsState.paused) return;

    print("Resume not supported by flutter_tts, reading again from start.");
    await speak(_currentText);
  }

  Future<void> speakFromPosition(String text, int startPos) async {
    if (startPos >= text.length) return;

    final remaining = text.substring(startPos);
    await speak(remaining);
  }

  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  Future<List<String>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  Future<void> dispose() async {
    await stop();
  }
}
