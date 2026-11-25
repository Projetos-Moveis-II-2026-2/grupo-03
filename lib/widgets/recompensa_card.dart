import 'package:flutter/material.dart';

import '../services/recompensa_service.dart';
import '../theme/app_colors.dart';

/// Cartão da micro-recompensa exibido ao concluir um bloco curto.
///
/// Animação discreta (leve aumento + fade), respeitando a preferência
/// do sistema por reduzir animações. Sem confete nem efeitos piscantes.
class RecompensaCard extends StatelessWidget {
  final ResultadoRecompensa resultado;

  const RecompensaCard({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduzirAnimacoes =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final mensagem = resultado.mensagem;
    final conquista = resultado.conquista;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduzirAnimacoes
          ? Duration.zero
          : const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, valor, child) => Opacity(
        opacity: valor.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.92 + 0.08 * valor, child: child),
      ),
      child: Semantics(
        container: true,
        label: 'Recompensa do bloco',
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.highlight.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.highlight.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mensagem.emoji,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(height: 6),
              Text(
                mensagem.expressaoIngles,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mensagem.traducao,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensagem.nota,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              if (conquista != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        conquista.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conquista.marco
                                  ? 'Nova conquista: ${conquista.titulo}'
                                  : conquista.titulo,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              conquista.descricao,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
