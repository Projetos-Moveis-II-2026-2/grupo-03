import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Lê palavras em inglês com a voz do aparelho (text-to-speech).
class AudioPronuncia {
  static final AudioPronuncia padrao = AudioPronuncia();

  FlutterTts? _tts;

  /// Fala [texto] em inglês. Retorna `false` se o áudio não estiver
  /// disponível (ex.: aparelho sem voz em inglês).
  Future<bool> falar(String texto) async {
    try {
      final tts = _tts ??= FlutterTts();
      await tts.stop();
      if (await tts.setLanguage('en-US') == 0) return false;
      // Um pouco mais devagar que o normal, para facilitar a compreensão.
      // A escala muda por plataforma: normal = 1.0 na web e 0.5 no celular.
      if (kIsWeb) {
        await tts.setSpeechRate(0.8);
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await tts.setSpeechRate(0.4);
      }
      return await tts.speak(texto) != 0;
    } catch (_) {
      return false;
    }
  }

  /// Interrompe a fala atual, se houver.
  Future<void> parar() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
