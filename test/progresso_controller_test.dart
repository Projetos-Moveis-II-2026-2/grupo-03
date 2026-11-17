import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/controllers/progresso_controller.dart';
import 'package:projeto_com_api/models/progresso_estudo.dart';
import 'package:projeto_com_api/repositories/progresso_repository.dart';

void main() {
  late DateTime agora;
  late ProgressoRepositoryLocal repo;
  late ProgressoController controller;

  void concluirBloco({int acertos = 5, int total = 5, int segundos = 180}) {
    controller.registrarBlocoConcluido(
      duracao: Duration(seconds: segundos),
      acertos: acertos,
      total: total,
    );
  }

  setUp(() async {
    agora = DateTime(2026, 11, 17, 10);
    repo = ProgressoRepositoryLocal();
    controller = ProgressoController(repo, agora: () => agora);
    await controller.carregarUsuario('raquel@email.com');
  });

  group('Ofensiva flexível', () {
    test('primeiro bloco inicia a ofensiva em 1', () {
      expect(controller.ofensiva, 0);
      concluirBloco();
      expect(controller.ofensiva, 1);
    });

    test('vários blocos no mesmo dia não aumentam a ofensiva', () {
      concluirBloco();
      concluirBloco();
      expect(controller.ofensiva, 1);
    });

    test('estudar no dia seguinte aumenta a ofensiva', () {
      concluirBloco();
      agora = agora.add(const Duration(days: 1));
      concluirBloco();
      expect(controller.ofensiva, 2);
    });

    test('pular 1 dia é tolerado (ofensiva continua)', () {
      concluirBloco();
      agora = agora.add(const Duration(days: 2));
      expect(controller.ofensiva, 1);
      concluirBloco();
      expect(controller.ofensiva, 2);
    });

    test('pular 2 dias ou mais zera a exibição e recomeça em 1', () {
      concluirBloco();
      agora = agora.add(const Duration(days: 1));
      concluirBloco();
      agora = agora.add(const Duration(days: 3));
      expect(controller.ofensiva, 0);
      concluirBloco();
      expect(controller.ofensiva, 1);
      expect(controller.maiorOfensiva, 2);
    });
  });

  group('Minutos e meta diária', () {
    test('soma os minutos estudados', () {
      concluirBloco(segundos: 150);
      concluirBloco(segundos: 150);
      expect(controller.minutosEstudados, 5);
    });

    test('meta diária progride e zera no dia seguinte', () {
      concluirBloco(total: 3);
      expect(controller.revisoesHoje, 3);
      expect(controller.progressoMetaDiaria, closeTo(0.6, 0.001));
      concluirBloco(total: 5);
      expect(controller.metaDiariaBatida, isTrue);
      expect(controller.progressoMetaDiaria, 1.0);

      agora = agora.add(const Duration(days: 1));
      expect(controller.revisoesHoje, 0);
    });

    test('bloco vazio não é registrado', () {
      concluirBloco(total: 0, acertos: 0);
      expect(controller.blocosConcluidos, 0);
      expect(controller.ofensiva, 0);
    });

    test('calcula a taxa de acerto', () {
      concluirBloco(acertos: 4, total: 5);
      concluirBloco(acertos: 2, total: 5);
      expect(controller.taxaAcerto, closeTo(60, 0.001));
    });
  });

  group('Erros por palavra', () {
    test('Rever incrementa e acertos reduzem gradualmente', () {
      controller.registrarErro('card_1');
      controller.registrarErro('card_1');
      expect(controller.errosDoCard('card_1'), 2);
      controller.registrarAcerto('card_1');
      expect(controller.errosDoCard('card_1'), 1);
      controller.registrarAcerto('card_1');
      expect(controller.errosDoCard('card_1'), 0);
      expect(controller.errosPorCard.containsKey('card_1'), isFalse);
    });
  });

  group('Persistência', () {
    test('progresso é salvo e recarregado por usuário', () async {
      concluirBloco(segundos: 120);
      controller.registrarErro('card_2');
      await Future<void>.value();

      final outro = ProgressoController(repo, agora: () => agora);
      await outro.carregarUsuario('RAQUEL@email.com');
      expect(outro.minutosEstudados, 2);
      expect(outro.ofensiva, 1);
      expect(outro.errosDoCard('card_2'), 1);

      await outro.carregarUsuario('outra@email.com');
      expect(outro.minutosEstudados, 0);
    });

    test('ProgressoEstudo serializa e desserializa', () {
      final original = ProgressoEstudo(
        ofensivaAtual: 3,
        ultimoDiaEstudo: DateTime(2026, 11, 17),
        segundosEstudados: 600,
        errosPorCard: {'card_1': 2},
        conquistas: ['word_master'],
      );
      final copia = ProgressoEstudo.fromJson(original.toJson());
      expect(copia.ofensivaAtual, 3);
      expect(copia.ultimoDiaEstudo, DateTime(2026, 11, 17));
      expect(copia.segundosEstudados, 600);
      expect(copia.errosPorCard, {'card_1': 2});
      expect(copia.conquistas, ['word_master']);
    });
  });
}
