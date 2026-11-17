import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/controllers/progresso_controller.dart';
import 'package:projeto_com_api/controllers/srs_controller.dart';
import 'package:projeto_com_api/models/questao_simulado.dart';
import 'package:projeto_com_api/models/srs_interval.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/repositories/progresso_repository.dart';
import 'package:projeto_com_api/repositories/questao_repository.dart';
import 'package:projeto_com_api/services/recomendacao_service.dart';

QuestaoSimulado _q(String id, String? cardId) => QuestaoSimulado(
  id: id,
  enunciado: 'Enunciado $id',
  opcoes: const ['a', 'b'],
  indiceCorreto: 0,
  explicacao: '',
  cardId: cardId,
);

void main() {
  const servico = RecomendacaoService();
  final candidatas = [
    _q('q1', 'c1'),
    _q('q2', 'c2'),
    _q('q3', 'c3'),
    _q('q4', 'c4'),
    _q('q5', 'c5'),
    _q('q6', 'c6'),
    _q('q7', null),
  ];

  test('sem histórico de erros mantém a ordem do SRS (não adaptativo)', () {
    final bloco = servico.montarBloco(
      candidatas: candidatas,
      limite: 5,
      errosPorCard: const {},
    );
    expect(bloco.adaptativo, isFalse);
    expect(bloco.questoes.map((q) => q.id), ['q1', 'q2', 'q3', 'q4', 'q5']);
  });

  test('palavra com mais erros vem primeiro', () {
    final bloco = servico.montarBloco(
      candidatas: candidatas,
      limite: 5,
      errosPorCard: const {'c6': 3, 'c4': 1},
    );
    expect(bloco.adaptativo, isTrue);
    expect(bloco.questoes.first.id, 'q6');
    expect(bloco.questoes[1].id, 'q4');
    expect(bloco.cardsEmFoco, ['c6', 'c4']);
    // O resto do bloco segue a ordem do SRS
    expect(bloco.questoes.skip(2).map((q) => q.id), ['q1', 'q2', 'q3']);
  });

  test('foco limitado a ~70% do bloco para não frustrar', () {
    final bloco = servico.montarBloco(
      candidatas: candidatas,
      limite: 5,
      errosPorCard: const {
        'c1': 1,
        'c2': 1,
        'c3': 1,
        'c4': 1,
        'c5': 1,
        'c6': 1,
      },
    );
    expect(bloco.cardsEmFoco.length, 4); // ceil(5 × 0.7)
    expect(bloco.questoes.length, 5);
  });

  test('fator de facilidade baixo no SRS também indica fraqueza', () {
    final intervalos = {'c3': SrsInterval(easeFactor: 1.7)};
    final bloco = servico.montarBloco(
      candidatas: candidatas,
      limite: 5,
      errosPorCard: const {},
      intervaloDoCard: (id) => intervalos[id],
    );
    expect(bloco.adaptativo, isTrue);
    expect(bloco.questoes.first.id, 'q3');
  });

  test('palavra já dominada perde prioridade', () {
    final intervalos = {'c1': SrsInterval(repetition: 4)};
    final pesoDominada = servico.pesoFraqueza(
      candidatas[0],
      errosPorCard: const {'c1': 1},
      intervaloDoCard: (id) => intervalos[id],
    );
    final pesoNormal = servico.pesoFraqueza(
      candidatas[1],
      errosPorCard: const {'c2': 1},
    );
    expect(pesoDominada, lessThan(pesoNormal));
  });

  test('questão sem cardId tem peso zero', () {
    expect(
      servico.pesoFraqueza(candidatas.last, errosPorCard: const {'c1': 5}),
      0,
    );
  });

  group('Integração com SrsController', () {
    late ProgressoController progresso;

    setUp(() async {
      progresso = ProgressoController(ProgressoRepositoryLocal());
      await progresso.carregarUsuario('raquel@email.com');
    });

    test('questões iniciais estão ligadas às palavras dos flashcards', () {
      final ids = FlashcardRepository().getAll().map((c) => c.id).toSet();
      for (final q in QuestaoSimulado.simuladoInicial) {
        expect(ids, contains(q.cardId), reason: q.id);
      }
    });

    test('palavra marcada como "Rever" abre o próximo simulado', () {
      // card_5 = "Reward" → questão q_5
      progresso.registrarErro('card_5');
      progresso.registrarErro('card_5');

      final controller = SrsController(
        QuestaoRepository(),
        progresso: progresso,
        flashcards: FlashcardRepository(),
      );
      expect(controller.blocoAdaptativo, isTrue);
      expect(controller.currentQuestion!.id, 'q_5');
      expect(controller.termosEmFoco, ['Reward']);
    });

    test('erro no simulado é registrado na palavra correspondente', () {
      final controller = SrsController(
        QuestaoRepository(),
        progresso: progresso,
      );
      final questao = controller.currentQuestion!;
      final errada = (questao.indiceCorreto + 1) % questao.opcoes.length;
      controller.processAnswer(errada);
      expect(progresso.errosDoCard(questao.cardId!), 1);
    });

    test('sem ProgressoController o comportamento original é mantido', () {
      final controller = SrsController(QuestaoRepository());
      expect(controller.blocoAdaptativo, isFalse);
      expect(controller.totalQuestions, SrsController.maxQuestionsPerBlock);
    });
  });
}
