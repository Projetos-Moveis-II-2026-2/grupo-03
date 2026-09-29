import 'package:flutter/material.dart';

import '../models/card_ingles.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/flashcard_widget.dart';
import 'home_screen.dart';
import 'tela_decks_ingles.dart';

/// Tela de estudo dinâmico de Flashcards de Inglês em blocos curtos,
/// projetada para manter o foco e evitar sobrecarga cognitiva em estudantes com TDAH.
class TelaEstudoFlashcards extends StatefulWidget {
  final List<CardIngles>? cardsCustomizados;
  final String tituloDeck;

  const TelaEstudoFlashcards({
    super.key,
    this.cardsCustomizados,
    this.tituloDeck = 'Vocabulário Essencial',
  });

  @override
  State<TelaEstudoFlashcards> createState() => _TelaEstudoFlashcardsState();
}

class _TelaEstudoFlashcardsState extends State<TelaEstudoFlashcards> {
  late List<CardIngles> _filaCards;
  int _indiceAtual = 0;
  int _cardsRevisadosComSucesso = 0;
  int _cardsParaRepetir = 0;
  bool _blocoFinalizado = false;

  @override
  void initState() {
    super.initState();
    _iniciarBloco();
  }

  void _iniciarBloco() {
    setState(() {
      _filaCards = List<CardIngles>.from(
        widget.cardsCustomizados ?? CardIngles.cardsIniciais,
      );
      _indiceAtual = 0;
      _cardsRevisadosComSucesso = 0;
      _cardsParaRepetir = 0;
      _blocoFinalizado = false;
    });
  }

  void _processarAutoavaliacao(NivelAutoavaliacao nivel) {
    final cardAtual = _filaCards[_indiceAtual];

    setState(() {
      if (nivel == NivelAutoavaliacao.rever) {
        _cardsParaRepetir++;
        // Reinsere o card no final da fila para fixação imediata no mesmo bloco
        _filaCards.add(cardAtual);
      } else {
        _cardsRevisadosComSucesso++;
      }

      if (_indiceAtual + 1 < _filaCards.length) {
        _indiceAtual++;
      } else {
        _blocoFinalizado = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.tituloDeck),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _blocoFinalizado
                  ? _construirTelaConclusao(context)
                  : _construirFluxoEstudo(context, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirFluxoEstudo(BuildContext context, TextTheme textTheme) {
    final progresso = (_indiceAtual + 1) / _filaCards.length;
    final cardAtual = _filaCards[_indiceAtual];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicador de progresso em bloco curto
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bloco curto (3-5 min)',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Card ${_indiceAtual + 1} de ${_filaCards.length}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Barra de progresso visual minimalista
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progresso.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        const SizedBox(height: 24),

        // Componente interativo do Flashcard
        FlashcardWidget(
          key: ValueKey(cardAtual.id + _indiceAtual.toString()),
          card: cardAtual,
          onAvaliar: _processarAutoavaliacao,
        ),

        const SizedBox(height: 20),

        // Dica cognitiva de respiro
        Center(
          child: Text(
            'Sem pressa: vire o cartão no seu próprio ritmo.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirTelaConclusao(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.highlight,
              child: Icon(
                Icons.check_circle_rounded,
                size: 42,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Bloco Concluído! 🎉',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Excelente trabalho de foco. Você revisou este conjunto sem sobrecarga mental.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Resumo estatístico do bloco
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ItemResumo(
                  label: 'Dominadas',
                  valor: '$_cardsRevisadosComSucesso',
                  cor: AppColors.success,
                ),
                _ItemResumo(
                  label: 'Revisadas',
                  valor: '$_cardsParaRepetir',
                  cor: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          AppButton(
            text: 'Fazer outro tema',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TelaDecksIngles(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }
}

class _ItemResumo extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _ItemResumo({
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          valor,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
