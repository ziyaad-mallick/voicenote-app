import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  late final SpeechToText _speechToText;
  String _lastWords = '';
  bool _isAvailable = false;

  SpeechService() {
    _speechToText = SpeechToText();
  }

  Future<bool> init() async {
    try {
      _isAvailable = await _speechToText.initialize(
        onError: (error) {},
        onStatus: (status) {},
      );
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  bool get isAvailable => _isAvailable;

  bool get isListening => _speechToText.isListening;

  Future<void> start({
    required void Function(String) onPartial,
    void Function(double)? onLevel,
  }) async {
    if (!_isAvailable) {
      throw StateError('SpeechToText not initialized');
    }

    _lastWords = '';

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        onPartial(_lastWords);
      },
      onSoundLevelChange: onLevel ?? (_) {},
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      ),
    );
  }

  Future<String> stop() async {
    await _speechToText.stop();
    return _lastWords;
  }
}
