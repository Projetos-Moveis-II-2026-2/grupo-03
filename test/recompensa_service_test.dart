import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/controllers/progresso_controller.dart';
import 'package:projeto_com_api/repositories/progresso_repository.dart';
import 'package:projeto_com_api/services/recompensa_service.dart';

/// Random controlável: devolve sempre os mesmos valores.
class _RandomFixo implements Random {
  final double valorDouble;
  _RandomFixo(this.valorDouble);

  @override
  double nextDouble() => valorDouble;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

void main() {
  final idsAcolhedoras = RecompensaService.mensagensAcolhedoras
      .map((m) => m.id)
      .toSet();
  final idsIncentivo = RecompensaService.mensagensIncentivo
      .map((m) => m.id)
      .toSet();

  test('com a mesma semente o sorteio é determinístico', () {
    const ctx = ContextoRecompensa(acertos: 5, total: 5);
    final a = RecompensaService(random: Random(42)).sortear(ctx);
    final b = RecompensaService(random: Random(42)).sortear(ctx);
    expect(a.mensagem.id, b.mensagem.id);
    expect(a.conquista?.id, b.conquista?.id);
  });

  test(
    'bloco com muitos erros recebe mensagem acolhedora (nunca negativa)',
    () {
      final servico = RecompensaService(random: Random(1));
      for (var i = 0; i < 20; i++) {
        final r = servico.sortear(
          const ContextoRecompensa(acertos: 1, total: 5),
        );
        expect(idsAcolhedoras, contains(r.mensagem.id));
      }
    },
  );

  test('bloco com bom desempenho recebe mensagem de incentivo', () {
    final r = RecompensaService(
      random: Random(3),
    ).sortear(const ContextoRecompensa(acertos: 4, total: 5));
    expect(idsIncentivo, contains(r.mensagem.id));
  });

  test('a mesma mensagem não se repete duas vezes seguidas', () {
    final servico = RecompensaService(random: _RandomFixo(0.9));
    const ctx = ContextoRecompensa(acertos: 5, total: 5);
    String? anterior;
    for (var i = 0; i < 10; i++) {
      final atual = servico.sortear(ctx).mensagem.id;
      expect(atual, isNot(anterior));
      anterior = atual;
    }
  });

  group('Conquistas', () {
    test('primeiro bloco libera "First Step!"', () {
      final r = RecompensaService(random: _RandomFixo(0.9)).sortear(
        const ContextoRecompensa(acertos: 3, total: 5, blocosConcluidos: 1),
      );
      expect(r.conquista?.id, RecompensaService.primeiroPasso.id);
    });

    test('marco já obtido não se repete; passa para o próximo', () {
      final r = RecompensaService(random: _RandomFixo(0.9)).sortear(
        ContextoRecompensa(
          acertos: 5,
          total: 5,
          conquistasObtidas: {RecompensaService.primeiroPasso.id},
        ),
      );
      expect(r.conquista?.id, RecompensaService.blocoPerfeito.id);
    });

    test('bloco difícil concluído libera "Never Give Up!"', () {
      final r = RecompensaService(random: _RandomFixo(0.9)).sortear(
        ContextoRecompensa(
          acertos: 1,
          total: 5,
          conquistasObtidas: {RecompensaService.primeiroPasso.id},
        ),
      );
      expect(r.conquista?.id, RecompensaService.nuncaDesiste.id);
    });

    test('sem marco novo, a surpresa depende do sorteio', () {
      final todos = {
        RecompensaService.primeiroPasso.id,
        RecompensaService.blocoPerfeito.id,
      };
      final semSorte = RecompensaService(random: _RandomFixo(0.9)).sortear(
        ContextoRecompensa(acertos: 5, total: 5, conquistasObtidas: todos),
      );
      expect(semSorte.conquista, isNull);

      final comSorte = RecompensaService(random: _RandomFixo(0.1)).sortear(
        ContextoRecompensa(acertos: 5, total: 5, conquistasObtidas: todos),
      );
      expect(comSorte.conquista, isNotNull);
      expect(comSorte.conquista!.marco, isFalse);
    });
  });

  test(
    'concederAoConcluirBloco registra conquistas de marco no progresso',
    () async {
      final progresso = ProgressoController(ProgressoRepositoryLocal());
      await progresso.carregarUsuario('raquel@email.com');
      progresso.registrarBlocoConcluido(
        duracao: const Duration(minutes: 3),
        acertos: 3,
        total: 5,
      );

      final servico = RecompensaService(random: _RandomFixo(0.9));
      final r = servico.concederAoConcluirBloco(
        acertos: 3,
        total: 5,
        palavrasDominadas: 0,
        progresso: progresso,
      );
      expect(r.conquista?.id, RecompensaService.primeiroPasso.id);
      expect(
        progresso.conquistas,
        contains(RecompensaService.primeiroPasso.id),
      );

      // No bloco seguinte, "First Step!" não aparece de novo.
      final r2 = servico.concederAoConcluirBloco(
        acertos: 3,
        total: 5,
        palavrasDominadas: 0,
        progresso: progresso,
      );
      expect(r2.conquista?.id, isNot(RecompensaService.primeiroPasso.id));
    },
  );
}
