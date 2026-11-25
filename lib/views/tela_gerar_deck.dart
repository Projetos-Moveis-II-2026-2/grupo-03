import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/flashcard_repository.dart';
import '../repositories/questao_repository.dart';
import '../services/gerador_conteudo_service.dart';
import '../services/vocabulario_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'tela_estudo_flashcards.dart';
import 'tela_simulado_ingles.dart';

/// Tema sugerido (busca em inglês + rótulo em português).
class TemaSugerido {
  final String tema;
  final String rotulo;
  final String emoji;

  const TemaSugerido(this.tema, this.rotulo, this.emoji);
}

/// Tela de geração automática de decks. Temas sugeridos usam listas prontas
/// (`temas_prontos.dart`); para temas digitados, o app
/// busca palavras (Datamuse), exemplos (Free Dictionary) e traduções
/// (MyMemory), montando flashcards e um simulado prontos para estudar.
class TelaGerarDeck extends StatefulWidget {
  /// Injetável para testes; por padrão usa as APIs públicas reais.
  final GeradorConteudoService? gerador;

  const TelaGerarDeck({super.key, this.gerador});

  static const List<TemaSugerido> sugestoes = [
    TemaSugerido('travel', 'Viagem', '✈️'),
    TemaSugerido('work', 'Trabalho', '💼'),
    TemaSugerido('food', 'Comida', '🍎'),
    TemaSugerido('health', 'Saúde', '🩺'),
    TemaSugerido('home', 'Casa', '🏠'),
    TemaSugerido('school', 'Escola', '🎒'),
  ];

  @override
  State<TelaGerarDeck> createState() => _TelaGerarDeckState();
}

class _TelaGerarDeckState extends State<TelaGerarDeck> {
  late final GeradorConteudoService _gerador =
      widget.gerador ?? GeradorConteudoService();
  final TextEditingController _temaController = TextEditingController();

  TemaSugerido? _sugestaoSelecionada;
  bool _gerando = false;
  String? _erro;
  DeckGerado? _deck;

  @override
  void dispose() {
    _temaController.dispose();
    super.dispose();
  }

  String get _temaDigitado => _temaController.text.trim();

  Future<void> _gerar() async {
    final sugestao = _sugestaoSelecionada;
    final tema = _temaDigitado.isNotEmpty ? _temaDigitado : sugestao?.tema;
    if (tema == null || tema.isEmpty) {
      setState(() => _erro = 'Escolha um tema ou digite um em inglês.');
      return;
    }
    final titulo = _temaDigitado.isEmpty ? sugestao?.rotulo : null;

    setState(() {
      _gerando = true;
      _erro = null;
      _deck = null;
    });
    try {
      final rotulo =
          titulo ??
          TelaGerarDeck.sugestoes
              .where((s) => s.tema == tema.toLowerCase())
              .firstOrNull
              ?.rotulo;
      final deck =
          _gerador.deckPronto(tema, titulo: rotulo) ??
          await _gerador.gerarDeck(tema, titulo: titulo);
      if (!mounted) return;
      _salvar(deck);
      setState(() => _deck = deck);
    } on VocabularioApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _erro =
            'Não foi possível gerar o deck agora. Verifique sua conexão.',
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  /// Guarda o deck nos repositórios para aparecer em Temas, na revisão
  /// geral e no simulado (inclusive na recomendação adaptativa).
  void _salvar(DeckGerado deck) {
    try {
      context.read<FlashcardRepository>().adicionarGerados(deck.cards);
      context.read<QuestaoRepository>().adicionarGeradas(deck.questoes);
    } on ProviderNotFoundException {
      // Sem Provider (ex.: testes isolados): o deck ainda pode ser estudado.
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gerar deck automático')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Escolha um tema',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Os temas abaixo usam listas prontas para iniciantes. Temas '
                    'digitados usam dicionários on-line, sem inteligência '
                    'artificial.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in TelaGerarDeck.sugestoes)
                        ChoiceChip(
                          label: Text('${s.emoji} ${s.rotulo}'),
                          selected: _sugestaoSelecionada == s,
                          onSelected: _gerando
                              ? null
                              : (selecionado) => setState(() {
                                  _sugestaoSelecionada = selecionado ? s : null;
                                  if (selecionado) _temaController.clear();
                                }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Ou digite um tema em inglês',
                    hintText: 'ex.: music, sports, weather',
                    controller: _temaController,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: _gerando ? 'Gerando...' : 'Gerar deck',
                    onPressed: _gerando ? null : _gerar,
                  ),
                  const SizedBox(height: 24),
                  if (_gerando) _construirCarregando(textTheme),
                  if (_erro != null) _construirErro(textTheme),
                  if (_deck != null) _construirResultado(_deck!, textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCarregando(TextTheme textTheme) => Column(
    children: [
      const CircularProgressIndicator(),
      const SizedBox(height: 12),
      Text(
        'Buscando palavras, exemplos e traduções...',
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _construirErro(TextTheme textTheme) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Text(_erro!, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextButton(onPressed: _gerar, child: const Text('Tentar novamente')),
      ],
    ),
  );

  Widget _construirResultado(DeckGerado deck, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Deck "${deck.titulo}" pronto!',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${deck.cards.length} palavras · ${deck.questoes.length} questões',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final card in deck.cards)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      card.termo,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      card.traducao,
                      textAlign: TextAlign.end,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Estudar flashcards',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TelaEstudoFlashcards(
                  tituloDeck: deck.titulo,
                  cardsCustomizados: deck.cards,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TelaSimuladoIngles(questoes: deck.questoes),
              ),
            ),
            child: const Text('Fazer simulado'),
          ),
        ],
      ),
    );
  }
}
