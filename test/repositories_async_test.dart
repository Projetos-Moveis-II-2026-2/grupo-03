import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/models/srs_interval.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/repositories/questao_repository.dart';
import 'package:projeto_com_api/models/questao_simulado.dart';
import 'package:projeto_com_api/services/conteudo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeConteudoApi extends ConteudoApi {
  _FakeConteudoApi(this.responder) : super();

  final Future<List<Map<String, dynamic>>> Function(String tabela) responder;
  int chamadas = 0;

  @override
  Future<List<Map<String, dynamic>>> listar(String tabela) {
    chamadas++;
    return responder(tabela);
  }
}

void main() {
  test('ConteudoApi usa URL/chave configuradas e JWT da sessão', () async {
    RequestOptions? requisicao;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requisicao = options;
            handler.resolve(
              Response<List<dynamic>>(
                requestOptions: options,
                data: [
                  {'id': 'api_card'},
                ],
              ),
            );
          },
        ),
      );
    final api = ConteudoApi(
      dio: dio,
      url: 'https://project.example.supabase.co',
      publishableKey: 'public-test-key',
      accessTokenProvider: () => 'user-session-jwt',
    );

    final rows = await api.listar('cards_vocabulario');
    expect(rows.single['id'], 'api_card');
    expect(requisicao!.uri.path, '/rest/v1/cards_vocabulario');
    expect(requisicao!.headers['apikey'], 'public-test-key');
    expect(requisicao!.headers['Authorization'], 'Bearer user-session-jwt');
  });

  group('FlashcardRepository', () {
    test('reutiliza o cache remoto durante a sessão', () async {
      final api = _FakeConteudoApi(
        (_) async => [
          {
            'id': 'remote_1',
            'termo': 'Focus',
            'fonetica': '',
            'traducao': 'Foco',
            'exemplo_ingles': '',
            'traducao_exemplo': '',
            'categoria': 'Estudos',
          },
        ],
      );
      final repository = FlashcardRepository(api: api);

      expect((await repository.carregar()).single.id, 'remote_1');
      expect((await repository.carregar()).single.id, 'remote_1');
      expect(api.chamadas, 1);
    });

    test('converte campos REST e deduplica carregamentos em andamento', () async {
      var liberar = Completer<List<Map<String, dynamic>>>();
      final api = _FakeConteudoApi((tabela) {
        expect(tabela, 'cards_vocabulario');
        return liberar.future;
      });
      final repository = FlashcardRepository(api: api);

      final primeiro = repository.carregar();
      final segundo = repository.carregar(atualizar: true);
      expect(api.chamadas, 1);
      liberar.complete([
        {
          'id': 'r1',
          'termo': 'Focus',
          'pronuncia_fonetica': '/foʊkəs/',
          'traducao': 'Foco',
          'exemplo_ingles': 'Keep your focus.',
          'traducao_exemplo': 'Mantenha o foco.',
          'categoria': 'Estudos',
        },
      ]);

      final cards = await primeiro;
      expect((await segundo).single.id, 'r1');
      expect(cards.single.fonetica, '/foʊkəs/');
      expect(cards.single.exemploIngles, 'Keep your focus.');
      expect(cards.single.traducaoExemplo, 'Mantenha o foco.');
    });

    test('carrega remoto na chamada explícita após falha anterior', () async {
      var chamadas = 0;
      final api = _FakeConteudoApi((_) async {
        chamadas++;
        if (chamadas == 1) throw Exception('offline');
        return [
          {'id': 'r2', 'termo': 'Retry'},
        ];
      });
      final repository = FlashcardRepository(api: api);

      await expectLater(repository.carregar(), throwsException);
      expect((await repository.carregar(atualizar: true)).single.id, 'r2');
      expect(chamadas, 2);
    });

    test(
      'preserva o cache remoto quando atualização falha ou vem vazia',
      () async {
        var chamadas = 0;
        final api = _FakeConteudoApi((_) async {
          chamadas++;
          if (chamadas == 1) {
            return [
              {'id': 'remote_1', 'termo': 'Focus'},
            ];
          }
          if (chamadas == 2) {
            throw Exception('offline');
          }
          return [];
        });
        final repository = FlashcardRepository(api: api);
        await repository.carregar();

        await expectLater(
          repository.carregar(atualizar: true),
          throwsException,
        );
        expect(repository.getAll().single.id, 'remote_1');
        await expectLater(
          repository.carregar(atualizar: true),
          throwsStateError,
        );
        expect(repository.getAll().single.id, 'remote_1');
      },
    );

    test('persiste intervalos SRS no SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = FlashcardRepository(prefs: prefs);
      repository.saveInterval(
        'card_1',
        SrsInterval(repetition: 2, nextReview: DateTime(2026, 11, 18)),
      );

      final reloaded = FlashcardRepository(prefs: prefs);
      expect(reloaded.getInterval('card_1').repetition, 2);
      expect(reloaded.getInterval('card_1').nextReview, DateTime(2026, 11, 18));
    });
  });

  test(
    'QuestaoRepository preserva questões carregadas após falha de refresh',
    () async {
      var chamadas = 0;
      final api = _FakeConteudoApi((_) async {
        chamadas++;
        if (chamadas == 1) {
          return [
            {
              'id': 'remote_q1',
              'enunciado': 'Question?',
              'opcoes': ['Yes', 'No'],
              'indice_correto': 0,
              'explicacao': '',
            },
          ];
        }
        throw Exception('offline');
      });
      final repository = QuestaoRepository(api: api);
      await repository.carregar();

      await expectLater(repository.carregar(atualizar: true), throwsException);
      expect(repository.getAll().single.id, 'remote_q1');
    },
  );

  test('QuestaoRepository converte e deduplica leitura REST', () async {
    final liberar = Completer<List<Map<String, dynamic>>>();
    final api = _FakeConteudoApi((tabela) {
      expect(tabela, 'questoes_simulado');
      return liberar.future;
    });
    final repository = QuestaoRepository(api: api);
    final primeira = repository.carregar();
    final segunda = repository.carregar();
    expect(api.chamadas, 1);
    liberar.complete([
      {
        'id': 'q_remote',
        'pergunta': 'Choose one',
        'alternativas': ['A', 'B'],
        'indice_correto': 1,
        'explicacao': 'B is correct.',
        'card_id': 'card_2',
      },
    ]);
    final QuestaoSimulado questao = (await primeira).single;
    await segunda;
    expect(questao.enunciado, 'Choose one');
    expect(questao.opcoes, ['A', 'B']);
    expect(questao.indiceCorreto, 1);
    expect(questao.cardId, 'card_2');
  });

  test('QuestaoRepository preserva cache após resposta vazia', () async {
    var chamadas = 0;
    final api = _FakeConteudoApi((_) async {
      chamadas++;
      return chamadas == 1
          ? [
              {
                'id': 'q_cached',
                'pergunta': 'Cached?',
                'alternativas': ['Yes'],
              },
            ]
          : [];
    });
    final repository = QuestaoRepository(api: api);
    await repository.carregar();
    await expectLater(repository.carregar(atualizar: true), throwsStateError);
    expect(repository.getAll().single.id, 'q_cached');
  });

  test('QuestaoRepository persiste intervalos SRS localmente', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = QuestaoRepository(prefs: prefs);
    repository.saveInterval(
      'q_1',
      SrsInterval(repetition: 3, nextReview: DateTime(2026, 11, 19)),
    );

    final reloaded = QuestaoRepository(prefs: prefs);
    expect(reloaded.getInterval('q_1').repetition, 3);
    expect(reloaded.getInterval('q_1').nextReview, DateTime(2026, 11, 19));
  });
}
