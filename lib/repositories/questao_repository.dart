import '../models/questao_simulado.dart';
import '../models/srs_interval.dart';

/// Repositório em memória para as questões de simulado e seus
/// estados de repetição espaçada. Na Etapa 3 será substituído por
/// integração com Supabase.
class QuestaoRepository {
  // Lista fixa de questões (pode ser carregada de um JSON futuro).
  final List<QuestaoSimulado> _questoes = List.from(QuestaoSimulado.simuladoInicial);

  // Mapeamento id -> SrsInterval para cada questão.
  final Map<String, SrsInterval> _intervals = {};

  QuestaoRepository() {
    // Inicializa o intervalo padrão para cada questão.
    for (var q in _questoes) {
      _intervals[q.id] = SrsInterval();
    }
  }

  /// Retorna todas as questões.
  List<QuestaoSimulado> getAll() => List.unmodifiable(_questoes);

  /// Obtém o intervalo SRS associado a uma questão.
  SrsInterval getInterval(String questaoId) =>
      _intervals[questaoId] ?? SrsInterval();

  /// Persiste (ou atualiza) o intervalo de uma questão.
  void saveInterval(String questaoId, SrsInterval intervalo) {
    _intervals[questaoId] = intervalo;
  }

  /// Busca um bloco de questões para a próxima sessão de revisão.
  /// Prioriza questões cujo próximo review já passou e limita ao tamanho do bloco.
  List<QuestaoSimulado> getDueQuestionsBlock(int limit) {
    final now = DateTime.now();
    
    // Lista de todas as questões
    final all = _questoes.toList();
    
    // Ordena priorizando quem já passou do prazo, e depois pelo tempo do proximo review
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
