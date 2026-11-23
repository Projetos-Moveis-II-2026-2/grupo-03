import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/flashcard_controller.dart';
import '../controllers/progresso_controller.dart';
import '../repositories/flashcard_repository.dart';
import '../models/card_ingles.dart';
import '../services/recompensa_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/recompensa_card.dart';
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
  late FlashcardController _controller;
  late final FlashcardRepository _repo;
  bool _carregando = true;
  bool _erroCarga = false;
  bool _falhaConexao = false;
  bool _controllerInicializado = false;
  ProgressoController? _progresso;

  /// Mede o tempo efetivo do bloco para os "minutos estudados".
  final Stopwatch _cronometro = Stopwatch();
  bool _blocoRegistrado = false;

  /// Micro-recompensa sorteada ao concluir o bloco.
  ResultadoRecompensa? _recompensa;

  @override
  void initState() {
    super.initState();
    FlashcardRepository repo;
    try {
      repo = context.read<FlashcardRepository>();
    } on ProviderNotFoundException {
      repo = FlashcardRepository();
    }
    _repo = repo;
    try {
      _progresso = context.read<ProgressoController>();
    } on ProviderNotFoundException {
      _progresso = null;
    }
    final cache = _filtrarCards(_repo.getAll());
    if (cache.isNotEmpty) {
      _inicializarController(cache);
      _carregando = false;
    }
    _carregarCards();
  }

  List<CardIngles> _filtrarCards(List<CardIngles> cards) {
    final selecionados = widget.cardsCustomizados;
    if (selecionados == null || selecionados.isEmpty) return cards;

    final ids = selecionados.map((card) => card.id).toSet();
    final porId = cards.where((card) => ids.contains(card.id)).toList();
    if (porId.isNotEmpty) return porId;

    final categorias = selecionados.map((card) => card.categoria).toSet();
    return cards.where((card) => categorias.contains(card.categoria)).toList();
  }

  void _inicializarController(List<CardIngles> cards) {
    _controller = FlashcardController(
      _repo,
      cardsCustomizados: cards,
      progresso: _progresso,
    );
    _controller.addListener(() {
      _registrarBlocoSeConcluido();
      if (mounted) setState(() {});
    });
    _controllerInicializado = true;
    _cronometro.start();
  }

  Future<void> _carregarCards({bool atualizar = false}) async {
    setState(() {
      _carregando = !_controllerInicializado;
      _erroCarga = false;
    });
    try {
      final cards = await _repo.carregar(atualizar: atualizar);
      if (!mounted) return;
      final filtrados = _filtrarCards(cards);
      if (filtrados.isEmpty) throw StateError('Conteúdo indisponível');
      if (!_controllerInicializado) _inicializarController(filtrados);
      setState(() {
        _carregando = false;
        _falhaConexao = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (!_controllerInicializado) {
        final cache = widget.cardsCustomizados?.isNotEmpty == true
            ? widget.cardsCustomizados!
            : _repo.getAll();
        final filtrados = _filtrarCards(cache);
        if (filtrados.isNotEmpty) _inicializarController(filtrados);
      }
      setState(() {
        _carregando = false;
        _erroCarga = !_controllerInicializado;
        _falhaConexao = true;
      });
    }
  }

  /// Registra o bloco no progresso uma única vez, ao concluir.
  void _registrarBlocoSeConcluido() {
    if (_blocoRegistrado || !_controller.isFinished) return;
    _blocoRegistrado = true;
    _cronometro.stop();
    final acertos = _controller.cardsRevisadosComSucesso;
    final total = acertos + _controller.cardsParaRepetir;
    _progresso?.registrarBlocoConcluido(
      duracao: _cronometro.elapsed,
      acertos: acertos,
      total: total,
    );
    _recompensa = RecompensaService.padrao.concederAoConcluirBloco(
      acertos: acertos,
      total: total,
      palavrasDominadas: _repo.contarDominados(),
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

  void _processarAutoavaliacao(NivelAutoavaliacao nivel) {
    _controller.processarAutoavaliacao(nivel);
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
              child: _carregando && !_controllerInicializado
                  ? const CircularProgressIndicator()
                  : _erroCarga
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Não foi possível carregar os cartões. Verifique sua conexão.',
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => _carregarCards(atualizar: true),
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
                            'Sem conexão. Você pode continuar com os cartões disponíveis.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () => _carregarCards(atualizar: true),
                            child: const Text('Tentar novamente'),
                          ),
                          const SizedBox(height: 8),
                        ],
                        _controller.isFinished
                            ? _construirTelaConclusao(context)
                            : _construirFluxoEstudo(context, textTheme),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirFluxoEstudo(BuildContext context, TextTheme textTheme) {
    final progresso = (_controller.currentIndex + 1) / _controller.totalCards;
    final cardAtual = _controller.currentCard!;

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
              'Card ${_controller.currentIndex + 1} de ${_controller.totalCards}',
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
          key: ValueKey(cardAtual.id + _controller.currentIndex.toString()),
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
          if (_recompensa != null) ...[
            RecompensaCard(resultado: _recompensa!),
            const SizedBox(height: 24),
          ],

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
                  valor: '${_controller.cardsRevisadosComSucesso}',
                  cor: AppColors.success,
                ),
                _ItemResumo(
                  label: 'Revisadas',
                  valor: '${_controller.cardsParaRepetir}',
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
