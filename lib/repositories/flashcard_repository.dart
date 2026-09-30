import '../models/card_ingles.dart';
import '../models/srs_interval.dart';

/// Repositório em memória para os Flashcards de Inglês e seus
/// estados de repetição espaçada. Na Etapa 3 será substituído por Supabase.
class FlashcardRepository {
  // Inicialize com todos os cartões disponíveis
  final List<CardIngles> _cards = List.from(CardIngles.cardsIniciais);

  // Mapeamento id -> SrsInterval para cada cartão.
  final Map<String, SrsInterval> _intervals = {};

  FlashcardRepository() {
    // Inicializa o intervalo padrão para cada cartão
    for (var card in _cards) {
      _intervals[card.id] = SrsInterval();
    }
  }

  /// Retorna todos os flashcards.
  List<CardIngles> getAll() => List.unmodifiable(_cards);

  /// Obtém o intervalo SRS associado a um cartão.
  SrsInterval getInterval(String cardId) =>
      _intervals[cardId] ?? SrsInterval();

  /// Persiste (ou atualiza) o intervalo de um cartão.
  void saveInterval(String cardId, SrsInterval intervalo) {
    _intervals[cardId] = intervalo;
  }

  /// Busca um bloco de flashcards para a próxima sessão de revisão.
  /// Prioriza cartões cujo próximo review já passou e limita ao tamanho do bloco.
  List<CardIngles> getDueCardsBlock(int limit) {
    final now = DateTime.now();
    
    final all = _cards.toList();
    
    all.sort((a, b) {
      final intA = getInterval(a.id);
      final intB = getInterval(b.id);
      
      final isDueA = intA.nextReview.isBefore(now) ? 0 : 1;
      final isDueB = intB.nextReview.isBefore(now) ? 0 : 1;
      
      if (isDueA != isDueB) return isDueA.compareTo(isDueB);
      
      return intA.nextReview.compareTo(intB.nextReview);
    });
    
    return all.take(limit).toList();
  }
}
