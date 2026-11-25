import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_ingles.dart';
import '../repositories/flashcard_repository.dart';
import '../theme/app_colors.dart';
import 'tela_estudo_flashcards.dart';
import 'tela_gerar_deck.dart';

/// Modelo simples para representar um Baralho (Deck) de estudo.
class DeckTema {
  final String id;
  final String titulo;
  final String descricao;
  final IconData icone;
  final List<CardIngles> cards;

  const DeckTema({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cards,
  });
}

/// Tela simples de seleção de temas de inglês para estudo em blocos curtos.
class TelaDecksIngles extends StatefulWidget {
  const TelaDecksIngles({super.key});

  /// Lista acadêmica de baralhos temáticos (3 a 5 cards cada para não cansar)
  static const List<DeckTema> baralhos = [
    DeckTema(
      id: 'foco_estudos',
      titulo: 'Foco & Produtividade',
      descricao: 'Vocabulário essencial para rotina de estudos e foco mental.',
      icone: Icons.psychology_outlined,
      cards: CardIngles.cardsIniciais,
    ),
    DeckTema(
      id: 'daily_routine',
      titulo: 'Daily Routine (Rotina)',
      descricao: 'Ações e hábitos cotidianos para falar do seu dia a dia.',
      icone: Icons.wb_sunny_outlined,
      cards: [
        CardIngles(
          id: 'rt_1',
          termo: 'Wake up',
          fonetica: 'UÊIK-âp',
          traducao: 'Acordar',
          exemploIngles: 'I wake up at seven every morning.',
          traducaoExemplo: 'Eu acordo às sete toda manhã.',
          categoria: 'Rotina Diária',
        ),
        CardIngles(
          id: 'rt_2',
          termo: 'Get ready',
          fonetica: 'GÉT-ré-di',
          traducao: 'Se arrumar / Preparar-se',
          exemploIngles: 'Take ten minutes to get ready.',
          traducaoExemplo: 'Tire dez minutos para se arrumar.',
          categoria: 'Rotina Diária',
        ),
        CardIngles(
          id: 'rt_3',
          termo: 'Schedule',
          fonetica: 'SKÉ-djuul',
          traducao: 'Cronograma / Horário',
          exemploIngles: 'Check your study schedule today.',
          traducaoExemplo: 'Verifique seu cronograma de estudos hoje.',
          categoria: 'Rotina Diária',
        ),
        CardIngles(
          id: 'rt_4',
          termo: 'Break',
          fonetica: 'BRÊIK',
          traducao: 'Pausa / Intervalo',
          exemploIngles: 'Take a short break between tasks.',
          traducaoExemplo: 'Faça uma pausa curta entre as tarefas.',
          categoria: 'Rotina Diária',
        ),
      ],
    ),
    DeckTema(
      id: 'travel',
      titulo: 'Travel Essentials (Viagem)',
      descricao: 'Termos e expressões indispensáveis para se comunicar fora.',
      icone: Icons.flight_takeoff_outlined,
      cards: [
        CardIngles(
          id: 'tr_1',
          termo: 'Boarding pass',
          fonetica: 'BÓR-ding-pés',
          traducao: 'Cartão de embarque',
          exemploIngles: 'Please show your boarding pass at the gate.',
          traducaoExemplo: 'Por favor, mostre seu cartão de embarque no portão.',
          categoria: 'Viagem',
        ),
        CardIngles(
          id: 'tr_2',
          termo: 'Directions',
          fonetica: 'di-RÉK-chânz',
          traducao: 'Direções / Orientações',
          exemploIngles: 'Can you give me directions to the station?',
          traducaoExemplo: 'Você pode me dar orientações para a estação?',
          categoria: 'Viagem',
        ),
        CardIngles(
          id: 'tr_3',
          termo: 'Luggage',
          fonetica: 'LÂ-guidj',
          traducao: 'Bagagem',
          exemploIngles: 'Keep your luggage close to you.',
          traducaoExemplo: 'Mantenha sua bagagem perto de você.',
          categoria: 'Viagem',
        ),
      ],
    ),
  ];

  @override
  State<TelaDecksIngles> createState() => _TelaDecksInglesState();
}

class _TelaDecksInglesState extends State<TelaDecksIngles> {
  late final FlashcardRepository _repo;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    try {
      _repo = context.read<FlashcardRepository>();
    } on ProviderNotFoundException {
      _repo = FlashcardRepository();
    }
    _carregarDecks();
  }

  Future<void> _carregarDecks() async {
    if (_repo.hasRemoteData) return;
    _carregando = true;
    try {
      await _repo.carregar();
    } catch (_) {
      // Offline ou erro na API: mantém o catálogo embutido como fallback.
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  /// Decks gerados automaticamente, agrupados por tema (mais recentes antes).
  List<DeckTema> _decksGerados() {
    final gerados = _repo.cardsGerados;
    final porTema = <String, List<CardIngles>>{};
    for (final card in gerados) {
      porTema.putIfAbsent(card.categoria, () => []).add(card);
    }
    return [
      for (final entrada in porTema.entries.toList().reversed)
        DeckTema(
          id: entrada.key,
          titulo: entrada.key,
          descricao: 'Gerado automaticamente a partir do tema.',
          icone: Icons.auto_awesome_outlined,
          cards: entrada.value,
        ),
    ];
  }

  List<DeckTema> _decksCatalogo() {
    if (!_repo.hasRemoteData) return TelaDecksIngles.baralhos;
    final geradosIds = _repo.cardsGerados.map((c) => c.id).toSet();
    final porCategoria = <String, List<CardIngles>>{};
    for (final card in _repo.getAll()) {
      if (geradosIds.contains(card.id)) continue;
      final categoria = card.categoria.trim().isEmpty
          ? 'Vocabulário Geral'
          : card.categoria;
      porCategoria.putIfAbsent(categoria, () => []).add(card);
    }
    return [
      for (final entrada in porCategoria.entries)
        DeckTema(
          id: entrada.key,
          titulo: entrada.key,
          descricao: 'Vocabulário de ${entrada.key}.',
          icone: Icons.style_outlined,
          cards: entrada.value,
        ),
    ];
  }

  Future<void> _abrirGerador() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const TelaGerarDeck()),
    );
    // Atualiza a lista com o deck que acabou de ser gerado.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final decksGerados = _decksGerados();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Temas de Inglês'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_carregando) const LinearProgressIndicator(minHeight: 2),
            Expanded(
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
                          'Blocos curtos de 3 a 5 cartões para aprender sem cansaço.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Geração automática de decks (Datamuse + dicionário)
                        OutlinedButton.icon(
                          onPressed: _abrirGerador,
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Gerar deck automático'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (decksGerados.isNotEmpty) ...[
                          Text(
                            'Seus decks gerados',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...decksGerados.map(
                            (deck) => _CardDeckItem(deck: deck),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Lista de baralhos
                        ..._decksCatalogo().map(
                          (deck) => _CardDeckItem(deck: deck),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDeckItem extends StatelessWidget {
  final DeckTema deck;

  const _CardDeckItem({required this.deck});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => TelaEstudoFlashcards(
                tituloDeck: deck.titulo,
                cardsCustomizados: deck.cards,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(deck.icone, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.titulo,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deck.descricao,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.style_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${deck.cards.length} flashcards',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
