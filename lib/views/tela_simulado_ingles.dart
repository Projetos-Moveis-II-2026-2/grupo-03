import 'package:flutter/material.dart';

import '../controllers/srs_controller.dart';
import '../repositories/questao_repository.dart';
import '../models/questao_simulado.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

/// Tela simples de Simulado / Quiz de Inglês em bloco curto (5 questões),
/// projetada com baixo estímulo sensorial e sem contagem regressiva para não gerar ansiedade.
class TelaSimuladoIngles extends StatefulWidget {
  final List<QuestaoSimulado>? questoes;

  const TelaSimuladoIngles({super.key, this.questoes});

  @override
  State<TelaSimuladoIngles> createState() => _TelaSimuladoInglesState();
}

class _TelaSimuladoInglesState extends State<TelaSimuladoIngles> {
  late final SrsController _controller;
  int? _opcaoSelecionada;
  bool _jaRespondeu = false;

  @override
  void initState() {
    super.initState();
    // Instanciamos o Repositório e Controlador da lógica SRS.
    _controller = SrsController(QuestaoRepository());
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selecionarOpcao(int indice) {
    if (_jaRespondeu) return;

    setState(() {
      _opcaoSelecionada = indice;
      _jaRespondeu = true;
    });
  }

  void _avancarQuestao() {
    if (_opcaoSelecionada != null) {
      _controller.processAnswer(_opcaoSelecionada!);
    }
    
    setState(() {
      _opcaoSelecionada = null;
      _jaRespondeu = false;
    });
  }

  void _reiniciarSimulado() {
    _controller.restartBlock();
    setState(() {
      _opcaoSelecionada = null;
      _jaRespondeu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Simulado de Inglês'),
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
              child: _controller.isFinished
                  ? _construirTelaResultado(context, textTheme)
                  : _construirPergunta(context, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirPergunta(BuildContext context, TextTheme textTheme) {
    final questao = _controller.currentQuestion!;
    final progresso = (_controller.currentIndex + 1) / _controller.totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicador de progresso do simulado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quiz Rápido',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Questão ${_controller.currentIndex + 1} de ${_controller.totalQuestions}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        const SizedBox(height: 24),

        // Cartão do Enunciado
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            questao.enunciado,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Lista de 4 alternativas
        ...List.generate(questao.opcoes.length, (index) {
          return _construirBotaoOpcao(index, questao, textTheme);
        }),

        const SizedBox(height: 16),

        // Caixa de feedback após responder
        if (_jaRespondeu) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _opcaoSelecionada == questao.indiceCorreto
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _opcaoSelecionada == questao.indiceCorreto
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: _opcaoSelecionada == questao.indiceCorreto
                      ? AppColors.success
                      : AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    questao.explicacao,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: _controller.currentIndex + 1 < _controller.totalQuestions
                ? 'Próxima questão'
                : 'Ver resultado',
            onPressed: _avancarQuestao,
          ),
        ],
      ],
    );
  }

  Widget _construirBotaoOpcao(
    int index,
    QuestaoSimulado questao,
    TextTheme textTheme,
  ) {
    Color corFundo = AppColors.card;
    Color corBorda = AppColors.border;
    Color corTexto = AppColors.textPrimary;
    IconData? iconeStatus;

    if (_jaRespondeu) {
      if (index == questao.indiceCorreto) {
        corFundo = AppColors.success.withValues(alpha: 0.12);
        corBorda = AppColors.success;
        corTexto = AppColors.success;
        iconeStatus = Icons.check_circle_rounded;
      } else if (index == _opcaoSelecionada) {
        corFundo = AppColors.error.withValues(alpha: 0.12);
        corBorda = AppColors.error;
        corTexto = AppColors.error;
        iconeStatus = Icons.cancel_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selecionarOpcao(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: corBorda, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  questao.opcoes[index],
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: corTexto,
                  ),
                ),
              ),
              if (iconeStatus != null)
                Icon(iconeStatus, color: corTexto, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTelaResultado(BuildContext context, TextTheme textTheme) {
    final aproveitamento = _controller.successRate;

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
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: aproveitamento >= 60
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.highlight.withValues(alpha: 0.2),
              child: Icon(
                aproveitamento >= 60
                    ? Icons.emoji_events_rounded
                    : Icons.refresh_rounded,
                size: 40,
                color: aproveitamento >= 60
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            aproveitamento >= 60
                ? 'Excelente desempenho! 🎉'
                : 'Bom esforço! Continue praticando 💪',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você respondeu o bloco de fixação sem pressão de tempo.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Painel de acertos
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_controller.correctAnswers} / ${_controller.totalQuestions}',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acertos',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${aproveitamento.toInt()}%',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aproveitamento',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          AppButton(
            text: 'Refazer simulado',
            onPressed: _reiniciarSimulado,
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
