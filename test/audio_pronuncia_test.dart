import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/models/card_ingles.dart';
import 'package:projeto_com_api/services/audio_pronuncia.dart';
import 'package:projeto_com_api/widgets/flashcard_widget.dart';

class _AudioFake extends AudioPronuncia {
  _AudioFake({this.disponivel = true});

  final bool disponivel;
  final List<String> falados = [];
  int paradas = 0;

  @override
  Future<bool> falar(String texto) async {
    falados.add(texto);
    return disponivel;
  }

  @override
  Future<void> parar() async => paradas++;
}

Widget _app(AudioPronuncia audio, {CardIngles? card}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: FlashcardWidget(
        card: card ?? CardIngles.cardsIniciais.first,
        onAvaliar: (_) {},
        audio: audio,
      ),
    ),
  ),
);

void main() {
  final botao = find.byTooltip('Ouvir pronúncia');

  testWidgets('toca a palavra sem virar o cartão', (tester) async {
    final audio = _AudioFake();
    await tester.pumpWidget(_app(audio));
    await tester.tap(botao);
    await tester.pumpAndSettle();
    expect(audio.falados, ['Focus']);
    expect(find.text('Toque para virar o cartão'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('avisa com gentileza quando não há áudio', (tester) async {
    await tester.pumpWidget(_app(_AudioFake(disponivel: false)));
    await tester.tap(botao);
    await tester.pump();
    expect(find.textContaining('áudio não está disponível'), findsOneWidget);
  });

  testWidgets('há áudio mesmo sem pronúncia escrita', (tester) async {
    const card = CardIngles(
      id: 'x',
      termo: 'Teacher',
      fonetica: '',
      traducao: 'Professor',
      exemploIngles: '',
      traducaoExemplo: '',
      categoria: 'Escola',
    );
    final audio = _AudioFake();
    await tester.pumpWidget(_app(audio, card: card));
    expect(find.text('Ouvir'), findsOneWidget);
    await tester.tap(botao);
    expect(audio.falados, ['Teacher']);
  });

  testWidgets('a fala para ao sair do cartão', (tester) async {
    final audio = _AudioFake();
    await tester.pumpWidget(_app(audio));
    await tester.pumpWidget(const SizedBox());
    expect(audio.paradas, 1);
  });

  group('plugin de voz', () {
    const canal = MethodChannel('flutter_tts');
    final chamadas = <MethodCall>[];

    void simular(Object? Function(MethodCall) responder) {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, (chamada) async {
            chamadas.add(chamada);
            return responder(chamada);
          });
    }

    setUp(chamadas.clear);

    test('fala em inglês', () async {
      simular((_) => 1);
      expect(await AudioPronuncia().falar('Focus'), isTrue);
      final idioma = chamadas.firstWhere((c) => c.method == 'setLanguage');
      expect(idioma.arguments, 'en-US');
      expect(chamadas.last.method, 'speak');
    });

    test('sem voz em inglês não tenta falar', () async {
      simular((c) => c.method == 'setLanguage' ? 0 : 1);
      expect(await AudioPronuncia().falar('Focus'), isFalse);
      expect(chamadas.map((c) => c.method), isNot(contains('speak')));
    });

    test('falha do plugin retorna falso sem quebrar', () async {
      simular((_) => throw PlatformException(code: 'erro'));
      expect(await AudioPronuncia().falar('Focus'), isFalse);
    });
  });
}
