import '../models/questao_simulado.dart';
import '../models/srs_interval.dart';

/// Resultado da montagem de um bloco de simulado.
class BlocoRecomendado {
  final List<QuestaoSimulado> questoes;

  /// `true` quando o bloco foi priorizado pelos pontos fracos do estudante.
  final bool adaptativo;

  /// Ids dos cartões (palavras) que motivaram a priorização, do mais fraco
  /// para o menos fraco.
  final List<String> cardsEmFoco;

  const BlocoRecomendado({
    required this.questoes,
    this.adaptativo = false,
    this.cardsEmFoco = const [],
  });
}

/// Motor de recomendação adaptativa (recurso inteligente da Etapa 4).
///
/// Analisa o histórico individual do estudante — erros/"Rever" por palavra
/// e o fator de facilidade do SRS (SM-2) — para calcular um **peso de
/// fraqueza** de cada questão e montar blocos curtos que reforçam os pontos
/// fracos, sem transformar o bloco inteiro em "só erros" (o que frustraria).
///
/// ```
/// peso = 3 × erros da palavra
///      + 2 × (2.5 − easeFactor da palavra)   // só se < 2.5
///      − 1 × (palavra já dominada ? 1 : 0)
/// ```
///
/// Classe pura: recebe dados e devolve uma lista; não acessa UI nem storage.
class RecomendacaoService {
  /// Fração máxima do bloco reservada para os pontos fracos (≈70%).
  /// O restante segue a ordem normal do SRS (vencidas/novas).
  static const double proporcaoFoco = 0.7;

  static const double _easeInicial = 2.5;
  static const int _repeticoesDominio =
      SrsInterval.repeticoesParaDominar;

  const RecomendacaoService();

  /// Peso de fraqueza de uma questão (0 = sem dificuldade registrada).
  double pesoFraqueza(
    QuestaoSimulado questao, {
    required Map<String, int> errosPorCard,
    SrsInterval? Function(String cardId)? intervaloDoCard,
  }) {
    final cardId = questao.cardId;
    if (cardId == null) return 0;

    final erros = errosPorCard[cardId] ?? 0;
    final intervalo = intervaloDoCard?.call(cardId);
    final dificuldade = intervalo == null
        ? 0.0
        : (_easeInicial - intervalo.easeFactor).clamp(0.0, _easeInicial);
    final dominada =
        intervalo != null && intervalo.repetition >= _repeticoesDominio;

    final peso = 3.0 * erros + 2.0 * dificuldade - (dominada ? 1 : 0);
    return peso < 0 ? 0 : peso;
  }

  /// Monta um bloco de até [limite] questões.
  ///
  /// [candidatas] deve vir na ordem padrão do SRS (vencidas primeiro); essa
  /// ordem é usada como desempate e para completar o bloco.
  BlocoRecomendado montarBloco({
    required List<QuestaoSimulado> candidatas,
    required int limite,
    required Map<String, int> errosPorCard,
    SrsInterval? Function(String cardId)? intervaloDoCard,
  }) {
    if (limite <= 0 || candidatas.isEmpty) {
      return const BlocoRecomendado(questoes: []);
    }

    final pesos = <QuestaoSimulado, double>{
      for (final q in candidatas)
        q: pesoFraqueza(
          q,
          errosPorCard: errosPorCard,
          intervaloDoCard: intervaloDoCard,
        ),
    };
    final ordemSrs = {
      for (var i = 0; i < candidatas.length; i++) candidatas[i]: i,
    };

    final fracas = candidatas.where((q) => pesos[q]! > 0).toList()
      ..sort((a, b) {
        final porPeso = pesos[b]!.compareTo(pesos[a]!);
        return porPeso != 0 ? porPeso : ordemSrs[a]!.compareTo(ordemSrs[b]!);
      });

    if (fracas.isEmpty) {
      return BlocoRecomendado(questoes: candidatas.take(limite).toList());
    }

    final vagasFoco = (limite * proporcaoFoco).ceil().clamp(1, limite);
    final emFoco = fracas.take(vagasFoco).toList();
    final restantes = candidatas.where((q) => !emFoco.contains(q));
    final bloco = [...emFoco, ...restantes].take(limite).toList();

    final cardsEmFoco = <String>[];
    for (final q in emFoco) {
      final id = q.cardId;
      if (id != null && !cardsEmFoco.contains(id)) cardsEmFoco.add(id);
    }

    return BlocoRecomendado(
      questoes: bloco,
      adaptativo: true,
      cardsEmFoco: cardsEmFoco,
    );
  }
}
