import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/models/card_ingles.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/repositories/questao_repository.dart';
import 'package:projeto_com_api/services/conteudo_api.dart';
import 'package:projeto_com_api/services/gerador_conteudo_service.dart';
import 'package:projeto_com_api/services/vocabulario_api.dart';
import 'package:projeto_com_api/views/tela_gerar_deck.dart';
import 'package:shared_preferences/shared_preferences.dart';

PalavraCandidata _c(String palavra, {double f = 10, Set<String>? classes}) =>
    PalavraCandidata(
      palavra: palavra,
      frequencia: f,
      classes: classes ?? const {'n'},
    );

CardIngles _card(String termo, String traducao, {String? exemplo}) =>
    CardIngles(
      id: 'gen_t_${termo.toLowerCase()}',
      termo: termo,
      fonetica: '',
      traducao: traducao,
      exemploIngles: exemplo ?? 'I like the ${termo.toLowerCase()} a lot.',
      traducaoExemplo: '',
      categoria: 'Teste',
    );

/// API simulada: sem rede, respostas controladas.
class _FakeVocabularioApi extends VocabularioApi {
  _FakeVocabularioApi({
    required this.palavras,
    this.semExemplo = const {},
    this.semRede = false,
  });

  final List<PalavraCandidata> palavras;
  final Set<String> semExemplo;
  final bool semRede;

  void _talvezFalhar() {
    if (semRede) throw const VocabularioApiException('Sem conexão.');
  }

  @override
  Future<List<PalavraCandidata>> buscarPalavras(
    String tema, {
    int maximo = 40,
  }) async {
    _talvezFalhar();
    return palavras;
  }

  @override
  Future<DetalhesPalavra?> buscarDetalhes(String palavra) async {
    _talvezFalhar();
    if (semExemplo.contains(palavra)) return null;
    return DetalhesPalavra(
      fonetica: '/$palavra/',
      exemplo: 'We bought a $palavra yesterday.',
    );
  }

  @override
  Future<String?> traduzir(String texto) async {
    _talvezFalhar();
    return texto.contains(' ') ? 'Frase: $texto' : 'pt-$texto';
  }
}

class _ConteudoApiFixa extends ConteudoApi {
  _ConteudoApiFixa(this.linhas) : super();
  final List<Map<String, dynamic>> linhas;

  @override
  Future<List<Map<String, dynamic>>> listar(String tabela) async => linhas;
}

void main() {
  group('filtrarCandidatas', () {
    test('mantém palavras comuns e remove as inadequadas', () {
      final resultado = GeradorConteudoService.filtrarCandidatas([
        _c('trip'),
        _c('locomote', f: 0.01), // rara
        _c('go', f: 300), // genérica demais
        _c('change of location'), // várias palavras
        _c('traveler'), // variação do tema
        _c('touring'), // forma em -ing
        _c('expenses', classes: {}), // sem classe gramatical
        _c('ticket'),
        _c('tickets'), // plural repetido
        _c('passport'),
      ], 'travel');
      expect(resultado.map((c) => c.palavra), ['trip', 'ticket', 'passport']);
    });
  });

  group('gerarQuestoes', () {
    final cards = [
      _card('Trip', 'Viagem'),
      _card('Journey', 'Viagem'),
      _card('Ticket', 'Bilhete'),
      _card('Passport', 'Passaporte'),
      _card('Hotel', 'Hotel'),
    ];

    test('uma questão por cartão, com 4 alternativas distintas e gabarito', () {
      final questoes = GeradorConteudoService.gerarQuestoes(
        cards,
        random: Random(7),
      );
      expect(questoes, hasLength(cards.length));
      for (var i = 0; i < questoes.length; i++) {
        final q = questoes[i];
        expect(q.cardId, cards[i].id);
        expect(q.opcoes, hasLength(4));
        expect(q.opcoes.map((o) => o.toLowerCase()).toSet(), hasLength(4));
        expect(q.indiceCorreto, inInclusiveRange(0, 3));
        expect(q.explicacao, contains(cards[i].termo));
      }
    });

    test('palavras com a mesma tradução não viram resposta dupla', () {
      for (var semente = 0; semente < 20; semente++) {
        final questoes = GeradorConteudoService.gerarQuestoes(
          cards,
          random: Random(semente),
        );
        final trip = questoes.firstWhere((q) => q.cardId == cards[0].id);
        if (trip.enunciado.startsWith('Complete') ||
            trip.enunciado.startsWith('Qual palavra')) {
          expect(
            trip.opcoes.map((o) => o.toLowerCase()),
            isNot(contains('journey')),
          );
        }
      }
    });

    test('a resposta correta corresponde ao formato da questão', () {
      final questoes = GeradorConteudoService.gerarQuestoes(
        cards,
        random: Random(1),
      );
      for (var i = 0; i < questoes.length; i++) {
        final q = questoes[i];
        final correta = q.opcoes[q.indiceCorreto];
        if (q.enunciado.startsWith('Qual a tradução')) {
          expect(correta, cards[i].traducao);
        } else {
          expect(correta.toLowerCase(), cards[i].termo.toLowerCase());
        }
      }
    });
  });

  group('gerarDeck', () {
    final palavras = [
      _c('trip'),
      _c('ticket'),
      _c('luggage'),
      _c('passport'),
      _c('hotel'),
      _c('airport'),
    ];

    test('monta cartões e questões ligadas às palavras', () async {
      final gerador = GeradorConteudoService(
        api: _FakeVocabularioApi(palavras: palavras, semExemplo: {'luggage'}),
        random: Random(3),
      );
      final deck = await gerador.gerarDeck('Travel', titulo: 'Viagem');

      expect(deck.cards, hasLength(GeradorConteudoService.tamanhoDeck));
      expect(deck.cards.map((c) => c.termo), isNot(contains('Luggage')));
      final primeiro = deck.cards.first;
      expect(primeiro.id, 'gen_travel_trip');
      expect(primeiro.termo, 'Trip');
      expect(primeiro.traducao, 'Pt-trip');
      expect(primeiro.fonetica, '/trip/');
      expect(primeiro.categoria, 'Viagem');
      expect(deck.questoes, hasLength(deck.cards.length));
      expect(
        deck.questoes.map((q) => q.cardId).toSet(),
        deck.cards.map((c) => c.id).toSet(),
      );
    });

    test('tema com poucas palavras gera mensagem amigável', () async {
      final gerador = GeradorConteudoService(
        api: _FakeVocabularioApi(palavras: [_c('trip'), _c('ticket')]),
      );
      expect(
        () => gerador.gerarDeck('travel'),
        throwsA(isA<VocabularioApiException>()),
      );
    });

    test('sem internet gera VocabularioApiException', () async {
      final gerador = GeradorConteudoService(
        api: _FakeVocabularioApi(palavras: palavras, semRede: true),
      );
      expect(
        () => gerador.gerarDeck('travel'),
        throwsA(isA<VocabularioApiException>()),
      );
    });

    test('tema inválido é recusado antes de chamar a API', () async {
      final gerador = GeradorConteudoService(
        api: _FakeVocabularioApi(palavras: palavras, semRede: true),
      );
      expect(
        () => gerador.gerarDeck('viagem!!'),
        throwsA(
          isA<VocabularioApiException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('inglês'),
          ),
        ),
      );
    });
  });

  group('VocabularioApi (respostas HTTP simuladas)', () {
    VocabularioApi apiCom(
      Object? Function(RequestOptions) responder, {
      int status = 200,
    }) {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (status != 200) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: status,
                    ),
                  ),
                );
                return;
              }
              handler.resolve(
                Response(requestOptions: options, data: responder(options)),
              );
            },
          ),
        );
      return VocabularioApi(dio: dio);
    }

    test('Datamuse: lê palavra, frequência e classes', () async {
      final api = apiCom(
        (o) => [
          {
            'word': 'trip',
            'tags': ['syn', 'n', 'v', 'f:27.2'],
          },
        ],
      );
      final palavras = await api.buscarPalavras('travel');
      expect(palavras.single.palavra, 'trip');
      expect(palavras.single.frequencia, 27.2);
      expect(palavras.single.classes, {'n', 'v'});
    });

    test('Free Dictionary: palavra inexistente (404) retorna null', () async {
      final api = apiCom((_) => null, status: 404);
      expect(await api.buscarDetalhes('xyzabc'), isNull);
    });

    test('Free Dictionary: lê fonética e exemplo', () async {
      final api = apiCom(
        (_) => [
          {
            'phonetic': '/tɹɪp/',
            'meanings': [
              {
                'definitions': [
                  {'definition': 'A journey'},
                  {'example': 'We made a trip to the beach.'},
                ],
              },
            ],
          },
        ],
      );
      final detalhes = await api.buscarDetalhes('trip');
      expect(detalhes!.fonetica, '/tɹɪp/');
      expect(detalhes.exemplo, 'We made a trip to the beach.');
    });

    test('MyMemory: cota esgotada retorna null', () async {
      final api = apiCom(
        (_) => {
          'responseStatus': 200,
          'quotaFinished': true,
          'responseData': {'translatedText': 'viagem'},
        },
      );
      expect(await api.traduzir('trip'), isNull);
    });

    test('erro de rede vira VocabularioApiException', () async {
      final api = apiCom((_) => null, status: 500);
      expect(
        () => api.traduzir('trip'),
        throwsA(isA<VocabularioApiException>()),
      );
    });
  });

  group('Repositórios com conteúdo gerado', () {
    test(
      'cartões gerados persistem e sobrevivem à carga do Supabase',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final gerados = [_card('Trip', 'Viagem'), _card('Ticket', 'Bilhete')];

        final repo = FlashcardRepository(
          prefs: prefs,
          api: _ConteudoApiFixa([
            {'id': 'uuid-1', 'termo': 'Focus', 'traducao': 'Foco'},
          ]),
        );
        repo.adicionarGerados(gerados);
        await repo.carregar();
        expect(repo.getAll().map((c) => c.id), [
          'uuid-1',
          'gen_t_trip',
          'gen_t_ticket',
        ]);
        expect(repo.contarPendentes(), 3);

        // Nova instância (app reaberto) recupera os gerados do aparelho.
        final reaberto = FlashcardRepository(prefs: prefs);
        expect(reaberto.cardsGerados.map((c) => c.termo), ['Trip', 'Ticket']);
      },
    );

    test('gerar o mesmo tema de novo substitui em vez de duplicar', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = QuestaoRepository(prefs: prefs);
      final questoes = GeradorConteudoService.gerarQuestoes([
        _card('Trip', 'Viagem'),
        _card('Ticket', 'Bilhete'),
        _card('Passport', 'Passaporte'),
        _card('Hotel', 'Hotel'),
      ], random: Random(2));
      repo.adicionarGeradas(questoes);
      repo.adicionarGeradas(questoes);
      final ids = repo.getAll().map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, containsAll(questoes.map((q) => q.id)));
      expect(QuestaoRepository(prefs: prefs).getAll().length, ids.length);
    });
  });

  testWidgets('TelaGerarDeck gera e mostra o deck do tema escolhido', (
    tester,
  ) async {
    final gerador = GeradorConteudoService(
      api: _FakeVocabularioApi(
        palavras: [
          _c('trip'),
          _c('ticket'),
          _c('passport'),
          _c('hotel'),
          _c('airport'),
        ],
      ),
      random: Random(5),
    );
    await tester.pumpWidget(MaterialApp(home: TelaGerarDeck(gerador: gerador)));

    await tester.tap(find.text('✈️ Viagem'));
    await tester.pump();
    await tester.tap(find.text('Gerar deck'));
    await tester.pumpAndSettle();

    expect(find.text('Deck "Viagem" pronto!'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);
    expect(find.text('Estudar flashcards'), findsOneWidget);
    expect(find.text('Fazer simulado'), findsOneWidget);
  });

  testWidgets('TelaGerarDeck pede um tema quando nada foi escolhido', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaGerarDeck(
          gerador: GeradorConteudoService(
            api: _FakeVocabularioApi(palavras: const []),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Gerar deck'));
    await tester.pump();
    expect(
      find.text('Escolha um tema ou digite um em inglês.'),
      findsOneWidget,
    );
  });
}
