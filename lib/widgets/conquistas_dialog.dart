import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/progresso_controller.dart';
import '../repositories/flashcard_repository.dart';
import '../services/recompensa_service.dart';
import '../theme/app_colors.dart';

const List<Conquista> _marcosConquista = [
  RecompensaService.primeiroPasso,
  RecompensaService.blocoPerfeito,
  RecompensaService.nuncaDesiste,
  RecompensaService.iniciaOfensiva,
  RecompensaService.wordMaster,
  RecompensaService.focusChampion,
  RecompensaService.quinzePalavras,
  RecompensaService.vinteCincoBlocos,
  RecompensaService.umaHoraFoco,
];

int _contarPalavrasDominadas(BuildContext context) {
  try {
    return Provider.of<FlashcardRepository>(
      context,
      listen: false,
    ).contarDominados();
  } on ProviderNotFoundException {
    return 0;
  }
}

String? _progressoMarco(
  Conquista marco,
  ProgressoController progresso,
  int palavrasDominadas,
) {
  if (marco.id == RecompensaService.primeiroPasso.id) {
    return '${progresso.blocosConcluidos.clamp(0, 1)} de 1 bloco concluído';
  }
  if (marco.id == RecompensaService.iniciaOfensiva.id) {
    return '${progresso.ofensiva.clamp(0, 3)} de 3 dias na sequência atual';
  }
  if (marco.id == RecompensaService.wordMaster.id) {
    return '${palavrasDominadas.clamp(0, 5)} de 5 palavras dominadas';
  }
  if (marco.id == RecompensaService.focusChampion.id) {
    return '${progresso.blocosConcluidos.clamp(0, 10)} de 10 blocos concluídos';
  }
  if (marco.id == RecompensaService.quinzePalavras.id) {
    return '${palavrasDominadas.clamp(0, 15)} de 15 palavras dominadas';
  }
  if (marco.id == RecompensaService.vinteCincoBlocos.id) {
    return '${progresso.blocosConcluidos.clamp(0, 25)} de 25 blocos concluídos';
  }
  if (marco.id == RecompensaService.umaHoraFoco.id) {
    return '${progresso.minutosEstudados.clamp(0, 60)} de 60 minutos focados';
  }
  return null;
}

/// Exibe um diálogo com os marcos conquistados e os próximos objetivos do aluno.
Future<void> mostrarConquistasDialog(BuildContext context) {
  final progresso = ProgressoController.of(context);
  final palavrasDominadas = _contarPalavrasDominadas(context);
  final obtidas = progresso.conquistas.toSet();
  final marcosDesbloqueados = _marcosConquista
      .where((m) => obtidas.contains(m.id))
      .length;
  final totalExpressoes =
      RecompensaService.mensagensIncentivo.length +
      RecompensaService.mensagensAcolhedoras.length;
  final expressoesColecionadas = progresso.expressoesAprendidas.length;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final textTheme = Theme.of(dialogContext).textTheme;
      return AlertDialog(
        title: const Text('Conquistas'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marcosDesbloqueados == 0
                            ? 'Conclua seu primeiro bloco curto para desbloquear marcos!'
                            : '$marcosDesbloqueados de ${_marcosConquista.length} marcos desbloqueados',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${progresso.blocosConcluidos} blocos • '
                        '$palavrasDominadas ${palavrasDominadas == 1 ? 'palavra dominada' : 'palavras dominadas'} • '
                        '${progresso.minutosEstudados} min focados',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '💬 $expressoesColecionadas de $totalExpressoes expressões culturais colecionadas',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔥 Ofensiva atual: '
                        '${progresso.ofensiva == 1 ? '1 dia' : '${progresso.ofensiva} dias'}',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final marco in _marcosConquista) ...[
                  Builder(
                    builder: (context) {
                      final desbloqueada = obtidas.contains(marco.id);
                      final progressoTexto = desbloqueada
                          ? null
                          : _progressoMarco(
                              marco,
                              progresso,
                              palavrasDominadas,
                            );
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Opacity(
                          opacity: desbloqueada ? 1 : 0.35,
                          child: Text(
                            marco.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          marco.titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: desbloqueada
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.45),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              marco.descricao,
                              style: TextStyle(
                                color: desbloqueada
                                    ? AppColors.textPrimary.withValues(
                                        alpha: 0.75,
                                      )
                                    : AppColors.textPrimary.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                            if (progressoTexto != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                progressoTexto,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          desbloqueada
                              ? Icons.check_circle
                              : Icons.lock_outline,
                          color: desbloqueada
                              ? AppColors.success
                              : AppColors.border,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}
