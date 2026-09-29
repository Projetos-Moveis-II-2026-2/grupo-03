import 'dart:math';
import 'package:flutter/material.dart';

import '../models/card_ingles.dart';
import '../theme/app_colors.dart';

/// Níveis de autoavaliação disponíveis no verso do flashcard.
enum NivelAutoavaliacao {
  rever,
  bom,
  facil,
}

/// Componente visual interativo de Flashcard com efeito de virada 3D (flip)
/// e botões de autoavaliação no verso, desenvolvido para foco e baixo ruído visual.
class FlashcardWidget extends StatefulWidget {
  final CardIngles card;
  final ValueChanged<NivelAutoavaliacao> onAvaliar;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.onAvaliar,
  });

  @override
  State<FlashcardWidget> createState() => FlashcardWidgetState();
}

class FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _mostrarFrente = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        if (_controller.value >= 0.5 && _mostrarFrente) {
          setState(() {
            _mostrarFrente = false;
          });
        } else if (_controller.value < 0.5 && !_mostrarFrente) {
          setState(() {
            _mostrarFrente = true;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _controller.reset();
      _mostrarFrente = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _alternarFace() {
    if (_controller.isAnimating) return;
    if (_mostrarFrente) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angulo = _animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspectiva 3D
          ..rotateY(angulo);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _mostrarFrente
              ? _construirFaceFrente(context)
              : Transform(
                  // Desinverte o conteúdo do verso para manter a leitura normal
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _construirFaceVerso(context),
                ),
        );
      },
    );
  }

  Widget _construirFaceFrente(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: _alternarFace,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 340),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Topo: Categoria sutil
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                widget.card.categoria.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Centro: Termo em inglês e Fonética
            Column(
              children: [
                Text(
                  widget.card.termo,
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.card.fonetica,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                // Frase contextual em inglês
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '"${widget.card.exemploIngles}"',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rodapé: Instrução para virar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Toque para virar o cartão',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFaceVerso(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Topo: Indicador de Verso e botão para desvirar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SIGNIFICADO',
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.flip_to_front_outlined, size: 20),
                tooltip: 'Voltar para frente',
                onPressed: _alternarFace,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Centro: Tradução e Contexto
          Column(
            children: [
              Text(
                widget.card.traducao,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tradução do contexto:',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.traducaoExemplo,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rodapé: Botões de Autoavaliação
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Como foi lembrar desta palavra?',
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BotaoAvaliacao(
                      texto: 'Rever',
                      icone: Icons.replay_outlined,
                      cor: AppColors.error,
                      onTap: () => widget.onAvaliar(NivelAutoavaliacao.rever),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BotaoAvaliacao(
                      texto: 'Bom',
                      icone: Icons.check_circle_outline,
                      cor: AppColors.primary,
                      onTap: () => widget.onAvaliar(NivelAutoavaliacao.bom),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BotaoAvaliacao(
                      texto: 'Fácil',
                      icone: Icons.sentiment_very_satisfied_outlined,
                      cor: AppColors.success,
                      onTap: () => widget.onAvaliar(NivelAutoavaliacao.facil),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotaoAvaliacao extends StatelessWidget {
  final String texto;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoAvaliacao({
    required this.texto,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 20),
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
