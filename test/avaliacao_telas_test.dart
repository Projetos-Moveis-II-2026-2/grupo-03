import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/models/card_ingles.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/services/gerador_conteudo_service.dart';
import 'package:projeto_com_api/services/pronuncia.dart';
import 'package:projeto_com_api/services/temas_prontos.dart';
import 'package:projeto_com_api/services/vocabulario_api.dart';
import 'package:projeto_com_api/views/home_screen.dart';
import 'package:projeto_com_api/views/tela_decks_ingles.dart';
import 'package:projeto_com_api/views/tela_gerar_deck.dart';
import 'package:projeto_com_api/views/tela_simulado_ingles.dart';

PalavraCandidata _c(String p, {Set<String> classes = const {'n'}}) =>
    PalavraCandidata(palavra: p, frequencia: 10, classes: classes);

CardIngles _card(String id) => CardIngles(
  id: id,
  termo: id,
  fonetica: '',
  traducao: id,
  exemploIngles: '',
  traducaoExemplo: '',
  categoria: 'Escola',
);

void main() {
  group('pronúncia aportuguesada', () {
    const casos = {
      '/ˈkʌltɪveɪt/': 'KÂL-ti-vêit',
      '/ˈtit͡ʃɚ/': 'TI-tchâr',
      '/ˈlɜːnɪŋ/': 'LÂR-ning',
      '/ˈstjuː.dənt/': 'STIUU-dânt',
      '/ˈɡɑːdn̩/': 'GÁ-dân',
      '/θɪŋk/': 'THINK',
      '/ˈsʌmə(ɹ)/': 'SÂ-mâ',
      'FÔU-kâs': 'FÔU-kâs',
      '': '',
      '/ˈxʘ/': '', // símbolo desconhecido: não mostra IPA
    };
    casos.forEach((ipa, esperado) {
      test('"$ipa" -> "$esperado"', () {
        expect(aportuguesarFonetica(ipa), esperado);
      });
    });
  });

  group('relevância das palavras', () {
    test('palavras nas duas buscas vêm antes; só parecidas ficam no fim', () {
      final ordem = VocabularioApi.ordenarPorRelevancia(
        parecidas: [_c('cultivate'), _c('classroom'), _c('teacher')],
        associadas: [_c('grades'), _c('teacher'), _c('classroom')],
      );
      expect(ordem.map((c) => c.palavra), [
        'teacher',
        'classroom',
        'grades',
        'cultivate',
      ]);
    });

    test('verbos e nomes próprios são descartados', () {
      final r = GeradorConteudoService.filtrarCandidatas([
        _c('cultivate', classes: {'v'}),
        _c('cole', classes: {'n', 'prop'}),
        _c('classroom'),
      ], 'school');
      expect(r.map((c) => c.palavra), ['classroom']);
    });

    test('exemplo prefere substantivo, frase curta e com a palavra', () {
      expect(
        VocabularioApi.escolherExemplo('pencil', [
          (classe: 'verb', texto: 'I pencil a note in the book.'),
          (classe: 'noun', texto: 'city desk'),
          (classe: 'noun', texto: 'This is my new pencil.'),
        ]),
        'This is my new pencil.',
      );
      expect(
        VocabularioApi.escolherExemplo('desk', [
          (classe: 'noun', texto: 'city desk'),
        ]),
        isNull,
      );
    });
  });

  group('temas prontos', () {
    test('todo tema sugerido tem um bloco completo e bem formado', () {
      for (final s in TelaGerarDeck.sugestoes) {
        final palavras = temasProntos[s.tema]!;
        expect(palavras, hasLength(GeradorConteudoService.tamanhoDeck));
        for (final p in palavras) {
          expect(
            p.exemplo.toLowerCase(),
            contains(p.termo.toLowerCase()),
            reason: p.termo,
          );
        }
        final deck = GeradorConteudoService().deckPronto(
          s.tema,
          titulo: s.rotulo,
        )!;
        expect(deck.questoes, hasLength(5));
      }
    });

    test('tema desconhecido não tem deck pronto', () {
      expect(GeradorConteudoService().deckPronto('music'), isNull);
    });

    test('gerar de novo substitui as palavras antigas do tema', () {
      final repo = FlashcardRepository()
        ..adicionarGerados([_card('gen_school_cultivate'), _card('gen_food_x')])
        ..adicionarGerados([_card('gen_school_teacher')]);
      expect(repo.cardsGerados.map((c) => c.id), [
        'gen_food_x',
        'gen_school_teacher',
      ]);
    });
  });

  testWidgets('Início tem um único caminho para cada área', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Continuar estudando'), findsNothing);
    expect(find.text('Simulados'), findsNothing);
    expect(find.text('Estudos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Começar agora'), findsOneWidget);
  });

  testWidgets('Simulado é acessível pela tela de Estudos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TelaDecksIngles()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fazer simulado'));
    await tester.pumpAndSettle();
    expect(find.byType(TelaSimuladoIngles), findsOneWidget);
  });
}
