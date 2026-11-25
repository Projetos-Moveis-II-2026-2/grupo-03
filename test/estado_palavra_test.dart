import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/controllers/flashcard_controller.dart';
import 'package:projeto_com_api/controllers/progresso_controller.dart';
import 'package:projeto_com_api/models/card_ingles.dart';
import 'package:projeto_com_api/models/nivel_autoavaliacao.dart';
import 'package:projeto_com_api/models/srs_interval.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/repositories/progresso_repository.dart';
import 'package:projeto_com_api/services/conteudo_api.dart';
import 'package:projeto_com_api/views/home_screen.dart';
import 'package:projeto_com_api/views/tela_estudo_flashcards.dart';
import 'package:projeto_com_api/views/tela_perfil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ApiOffline extends ConteudoApi {
  @override
  Future<List<Map<String, dynamic>>> listar(String tabela) async =>
      throw StateError('offline');
}

void _responderBloco(FlashcardController c, NivelAutoavaliacao nivel) {
  while (!c.isFinished) {
    c.processarAutoavaliacao(nivel);
  }
}

void main() {
  group('SrsInterval', () {
    final noite = DateTime(2026, 11, 24, 22);
    SrsInterval novo() => SrsInterval(nextReview: noite);

    test('nova -> aprendendo -> dominada com 3 revisões espaçadas', () {
      final i = novo();
      expect(i.estado, EstadoPalavra.nova);
      i.update(true, agora: noite);
      expect(i.estado, EstadoPalavra.aprendendo);
      i.update(true, agora: i.nextReview);
      expect(i.estado, EstadoPalavra.aprendendo);
      i.update(true, agora: i.nextReview);
      expect(i.estado, EstadoPalavra.dominada);
    });

    test('acertos repetidos no mesmo dia não dominam nem adiam a revisão', () {
      final i = novo()..update(true, agora: noite);
      final revisao = i.nextReview;
      for (var n = 1; n <= 5; n++) {
        i.update(true, isEasy: true, agora: noite.add(Duration(minutes: n)));
      }
      expect(i.repetition, 1);
      expect(i.nextReview, revisao);
      expect(i.easeFactor, 2.5);
    });

    test('a revisão vence na manhã seguinte', () {
      final i = novo()..update(true, agora: noite);
      expect(i.estaVencido(DateTime(2026, 11, 24, 23, 59)), isFalse);
      expect(i.estaVencido(DateTime(2026, 11, 25, 7)), isTrue);
    });

    test('erro reinicia o domínio mesmo fora da data', () {
      final i = SrsInterval(repetition: 3, nextReview: DateTime(2027))
        ..update(false, agora: noite);
      expect(i.estado, EstadoPalavra.aprendendo);
      expect(i.repetition, 0);
    });

    test('serializa a última revisão e aceita dados antigos', () {
      final i = novo()..update(false, agora: noite);
      expect(SrsInterval.fromJson(i.toJson()).ultimaRevisao, noite);
      final antigo = SrsInterval.fromJson({
        'repetition': 1,
        'nextReview': noite.toIso8601String(),
      });
      expect(antigo.estado, EstadoPalavra.aprendendo);
    });
  });

  test('bloco repetido 3 vezes no mesmo dia não domina palavras', () {
    final repo = FlashcardRepository(api: _ApiOffline());
    final c = FlashcardController(repo);
    for (var n = 0; n < 3; n++) {
      _responderBloco(c, NivelAutoavaliacao.facil);
      c.restartBlock();
    }
    expect(repo.contarDominados(), 0);
  });

  test('resumo conta cada palavra uma única vez', () {
    final repo = FlashcardRepository(api: _ApiOffline());
    final c = FlashcardController(repo)
      ..processarAutoavaliacao(NivelAutoavaliacao.rever);
    _responderBloco(c, NivelAutoavaliacao.bom);
    expect(c.palavrasParaRever, 1);
    expect(c.palavrasAprendendo, 4);
    expect(c.palavrasDominadas, 0);
  });

  test('resumo e contador geral concordam na terceira revisão', () {
    final repo = FlashcardRepository(api: _ApiOffline());
    for (final card in repo.getAll()) {
      repo.saveInterval(card.id, SrsInterval(repetition: 2));
    }
    final c = FlashcardController(repo);
    _responderBloco(c, NivelAutoavaliacao.bom);
    expect(c.palavrasDominadas, 5);
    expect(repo.contarDominados(), 5);
  });

  test('decks salvos com emoji no título são limpos', () async {
    final card = CardIngles.cardsIniciais.first.toJson()
      ..['id'] = 'gen_home_x'
      ..['categoria'] = 'Casa ✨';
    SharedPreferences.setMockInitialValues({
      'focodeck_cards_gerados': jsonEncode([card]),
    });
    final repo = FlashcardRepository(
      prefs: await SharedPreferences.getInstance(),
    );
    expect(repo.cardsGerados.single.categoria, 'Casa');
  });

  test('Home convida para um bloco e nunca mostra o total acumulado', () {
    expect(
      mensagemRevisao(pendentes: 30, metaBatida: true),
      'Quer fazer mais um bloco de 5?',
    );
    expect(
      mensagemRevisao(pendentes: 30, metaBatida: false),
      'Seu bloco de 5 cartões está pronto',
    );
    expect(
      mensagemRevisao(pendentes: 1, metaBatida: false),
      'Seu bloco de 1 cartão está pronto',
    );
    expect(mensagemRevisao(pendentes: 0, metaBatida: true), contains('Tudo'));
  });

  Widget app(FlashcardRepository repo, Widget home) => MultiProvider(
    providers: [
      ChangeNotifierProvider<FlashcardRepository>.value(value: repo),
      ChangeNotifierProvider(
        create: (_) => ProgressoController(ProgressoRepositoryLocal()),
      ),
    ],
    child: MaterialApp(home: home),
  );

  testWidgets('Perfil atualiza quando o repositório muda', (tester) async {
    final repo = FlashcardRepository(api: _ApiOffline());
    await tester.pumpWidget(app(repo, const TelaPerfil()));
    repo.saveInterval('card_1', SrsInterval(repetition: 3));
    await tester.pump();
    expect(find.text('palavra dominada'), findsOneWidget);
  });

  testWidgets('fim de bloco mostra os três estados', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FlashcardRepository(api: _ApiOffline());
    await tester.pumpWidget(
      app(
        repo,
        TelaEstudoFlashcards(
          cardsCustomizados: [CardIngles.cardsIniciais.first],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Toque para virar o cartão'));
    await tester.tap(find.text('Toque para virar o cartão'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Bom'));
    await tester.tap(find.text('Bom'));
    await tester.pumpAndSettle();
    expect(find.text('Aprendendo'), findsOneWidget);
    expect(find.text('Dominadas'), findsOneWidget);
    expect(find.text('Para rever'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
