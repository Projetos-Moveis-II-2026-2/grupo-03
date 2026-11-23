import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/controllers/progresso_controller.dart';
import 'package:projeto_com_api/models/questao_simulado.dart';
import 'package:projeto_com_api/models/srs_interval.dart';
import 'package:projeto_com_api/repositories/flashcard_repository.dart';
import 'package:projeto_com_api/repositories/progresso_repository.dart';
import 'package:projeto_com_api/services/conteudo_api.dart';

class _FakeConteudoApi extends ConteudoApi {
  _FakeConteudoApi(this.linhas) : super();

  final List<Map<String, dynamic>> linhas;

  @override
  Future<List<Map<String, dynamic>>> listar(String tabela) async => linhas;
}

Map<String, dynamic> _card(String id) => {
  'id': id,
  'termo': 'Term $id',
  'traducao': 'Tradução',
  'categoria': 'Teste',
};

void main() {
  group('Contadores do dashboard com conteúdo do Supabase', () {
    test('ignoram os cartões embutidos quando a API usa outros ids', () async {
      final repo = FlashcardRepository(
        api: _FakeConteudoApi([_card('uuid-a'), _card('uuid-b')]),
      );
      // Antes da API: os 5 cartões embutidos estão pendentes.
      expect(repo.contarPendentes(), 5);

      await repo.carregar();
      expect(repo.contarPendentes(), 2);

      repo.saveInterval('uuid-a', SrsInterval(repetition: 3));
      // Um cartão embutido "dominado" não conta mais após a troca.
      repo.saveInterval('card_1', SrsInterval(repetition: 5));
      expect(repo.contarDominados(), 1);
    });
  });

  group('QuestaoSimulado.fromJson', () {
    test('aceita card_id numérico vindo do banco', () {
      final q = QuestaoSimulado.fromJson({
        'id': 10,
        'enunciado': 'Pergunta',
        'opcoes': ['a', 'b'],
        'indice_correto': 1,
        'card_id': 42,
      });
      expect(q.cardId, '42');
      expect(q.id, '10');
    });

    test('card_id ausente continua nulo', () {
      final q = QuestaoSimulado.fromJson({'id': 'q', 'opcoes': []});
      expect(q.cardId, isNull);
    });
  });

  group('Chave do progresso', () {
    test('usa o UUID do Supabase quando disponível', () {
      expect(
        ProgressoController.chaveDoUsuario(
          id: '7f1c-uuid',
          email: 'raquel@email.com',
        ),
        '7f1c-uuid',
      );
    });

    test('usa o e-mail quando ainda não há UUID', () {
      expect(
        ProgressoController.chaveDoUsuario(id: null, email: 'a@b.com'),
        'a@b.com',
      );
      expect(
        ProgressoController.chaveDoUsuario(id: '  ', email: 'a@b.com'),
        'a@b.com',
      );
    });

    test('trocar o e-mail não perde o progresso (mesmo UUID)', () async {
      final repo = ProgressoRepositoryLocal();
      final antes = ProgressoController(repo);
      await antes.carregarUsuario(
        ProgressoController.chaveDoUsuario(id: 'uuid-1', email: 'velho@x.com'),
      );
      antes.registrarBlocoConcluido(
        duracao: const Duration(minutes: 4),
        acertos: 5,
        total: 5,
      );
      await Future<void>.value();

      final depois = ProgressoController(repo);
      await depois.carregarUsuario(
        ProgressoController.chaveDoUsuario(id: 'uuid-1', email: 'novo@x.com'),
      );
      expect(depois.minutosEstudados, 4);
      expect(depois.ofensiva, 1);
    });
  });
}
