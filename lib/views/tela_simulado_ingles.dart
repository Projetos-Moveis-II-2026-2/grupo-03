import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/progresso_controller.dart';
import '../controllers/srs_controller.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/questao_repository.dart';
import '../models/questao_simulado.dart';
import '../services/recompensa_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/recompensa_card.dart';
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
  late SrsController _controller;
  late QuestaoRepository _repo;
  bool _carregando = true;
  bool _erroCarga = false;
  bool _falhaConexao = false;
  bool _controllerInicializado = false;
  ProgressoController? _progresso;
  FlashcardRepository? _flashcards;

  /// Mede o tempo efetivo do bloco para os "minutos estudados".
  final Stopwatch _cronometro = Stopwatch();
  bool _blocoRegistrado = false;

  /// Micro-recompensa sorteada ao concluir o bloco.
  ResultadoRecompensa? _recompensa;
  int? _opcaoSelecionada;
  bool _jaRespondeu = false;

  @override
  void initState() {
    super.initState();
    QuestaoRepository repo;
    try {
      repo = context.read<QuestaoRepository>();
    } on ProviderNotFoundException {
      repo = QuestaoRepository();
    }
    _repo = repo;
    try {
      _progresso = context.read<ProgressoController>();
    } on ProviderNotFoundException {
      _progresso = null;
    }
    try {
      _flashcards = context.read<FlashcardRepository>();
    } on ProviderNotFoundException {
      _flashcards = null;
    }
    final cache = _filtrarQuestoes(_repo.getAll());
    if (cache.isNotEmpty) {
      _inicializarController(_repo, cache);
      _carregando = false;
    }
    _carregarQuestoes(repo);
  }

  Future<void> _carregarQuestoes(
    QuestaoRepository repo, {
    bool atualizar = false,
  }) async {
    setState(() {
      _carregando = !_controllerInicializado;
      _erroCarga = false;
    });
    try {
      final questoes = await repo.carregar(atualizar: atualizar);
      if (!mounted) return;
      final filtradas = _filtrarQuestoes(questoes);
      if (filtradas.isEmpty) throw StateError('Conteúdo indisponível');
      final blocoIntacto = !_controllerInicializado ||
          (_controller.currentIndex == 0 &&
              _controller.correctAnswers == 0 &&
              _controller.wrongAnswers == 0 &&
              !_jaRespondeu);
      if (blocoIntacto || atualizar) {
        _inicializarController(repo, filtradas);
      }
      setState(() {
        _carregando = false;
        _falhaConexao = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (!_controllerInicializado) {
        final cache = widget.questoes?.isNotEmpty == true
            ? widget.questoes!
            : repo.getAll();
        final filtradas = _filtrarQuestoes(cache);
        if (filtradas.isNotEmpty) _inicializarController(repo, filtradas);
      }
      setState(() {
        _carregando = false;
        _erroCarga = !_controllerInicializado;
        _falhaConexao = true;
      });
    }
  }

  List<QuestaoSimulado> _filtrarQuestoes(List<QuestaoSimulado> questoes) {
    final selecionadas = widget.questoes;
    if (selecionadas == null || selecionadas.isEmpty) return questoes;
    final ids = selecionadas.map((questao) => questao.id).toSet();
    final correspondentes = questoes
        .where((questao) => ids.contains(questao.id))
        .toList();
    return correspondentes.isNotEmpty ? correspondentes : selecionadas;
  }

  void _inicializarController(
    QuestaoRepository repo,
    List<QuestaoSimulado> questoes,
  ) {
    if (_controllerInicializado) {
      _controller.dispose();
    }
    _opcaoSelecionada = null;
    _jaRespondeu = false;
    _blocoRegistrado = false;
    _recompensa = null;
    _controller = SrsController(
      repo,
      questoesCustomizadas: questoes,
      progresso: _progresso,
      flashcards: _flashcards,
    );
    _controller.addListener(() {
      _registrarBlocoSeConcluido();
      if (mounted) setState(() {});
    });
    _controllerInicializado = true;
    _cronometro
      ..reset()
      ..start();
  }

  /// Registra o bloco no progresso uma única vez, ao concluir.
  void _registrarBlocoSeConcluido() {
    if (_blocoRegistrado || !_controller.isFinished) return;
    _blocoRegistrado = true;
    _cronometro.stop();
    _progresso?.registrarBlocoConcluido(
      duracao: _cronometro.elapsed,
      acertos: _controller.correctAnswers,
      total: _controller.totalQuestions,
    );
    _recompensa = RecompensaService.padrao.concederAoConcluirBloco(
      acertos: _controller.correctAnswers,
      total: _controller.totalQuestions,
      palavrasDominadas: _flashcards?.contarDominados() ?? 0,
      progresso: _progresso,
    );
  }

  @override
  void dispose() {
    if (_controllerInicializado) {
      _controller.dispose();
    }
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
    _blocoRegistrado = false;
    _recompensa = null;
    _cronometro
      ..reset()
      ..start();
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
              child: _carregando && !_controllerInicializado
                  ? const CircularProgressIndicator()
                  : _erroCarga
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Não foi possível carregar as questões. Verifique sua conexão.',
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              _carregarQuestoes(_repo, atualizar: true),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_carregando) const LinearProgressIndicator(),
                        if (_falhaConexao) ...[
                          const Text(
                            'Sem conexão. Você pode continuar com as questões disponíveis.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () =>
                                _carregarQuestoes(_repo, atualizar: true),
                            child: const Text('Tentar novamente'),
                          ),
                          const SizedBox(height: 8),
                        ],
                        _controller.isFinished
                            ? _construirTelaResultado(context, textTheme)
                            : _construirPergunta(context, textTheme),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirPergunta(BuildContext context, TextTheme textTheme) {
    final questao = _controller.currentQuestion!;
    final progresso =
        (_controller.currentIndex + 1) / _controller.totalQuestions;

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

        // Selo da recomendação adaptativa (IA): deixa visível ao estudante
        // que o bloco foi montado a partir das palavras que ele mais errou.
        if (_controller.blocoAdaptativo) ...[
          const SizedBox(height: 16),
          _SeloBlocoAdaptativo(termos: _controller.termosEmFoco),
        ],

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
          if (_recompensa != null) ...[
            RecompensaCard(resultado: _recompensa!),
            const SizedBox(height: 24),
          ],

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

          AppButton(text: 'Refazer simulado', onPressed: _reiniciarSimulado),
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

/// Selo discreto informando que o bloco prioriza os pontos fracos.
class _SeloBlocoAdaptativo extends StatelessWidget {
  final List<String> termos;

  const _SeloBlocoAdaptativo({required this.termos});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detalhe = termos.isEmpty ? '' : ': ${termos.join(', ')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bloco focado nas palavras que você mais precisa rever$detalhe',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
