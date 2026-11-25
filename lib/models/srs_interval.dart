/// Estado de aprendizagem de uma palavra, derivado do seu [SrsInterval].
///
/// - [nova]: ainda não foi estudada;
/// - [aprendendo]: já foi estudada, mas não atingiu o critério de domínio;
/// - [dominada]: [SrsInterval.repeticoesParaDominar] acertos seguidos em
///   revisões espaçadas (dias diferentes).
enum EstadoPalavra { nova, aprendendo, dominada }

/// Modelo que representa o intervalo de revisão espaçada (SRS) de uma questão.
///
/// Utiliza uma versão simplificada do algoritmo SM‑2, suficiente para a
/// primeira iteração do módulo de questões. Cada questão possui um
/// `SrsInterval` associado que controla:
///   * `repetition` – número de repetições corretas consecutivas.
///   * `easeFactor` – fator de facilidade (inicial 2.5, mínimo 1.3).
///   * `intervalDays` – quantidade de dias até a próxima revisão.
///   * `nextReview` – data calculada da próxima revisão.
///
/// O método `update` recebe se o usuário acertou a questão e recalcula
/// os campos de acordo com a lógica abaixo:
///   * Acertou → `repetition++` e intervalo cresce exponencialmente.
///   * Errou → `repetition = 0`, `easeFactor` diminui (mínimo 1.3) e
///     `intervalDays` volta a 1.
///
/// Essa classe é **pura** (sem dependências de UI) e pode ser
/// serializada facilmente para armazenamento futuro (Supabase na Etapa 3).
class SrsInterval {
  /// Acertos espaçados consecutivos para uma palavra ser "dominada".
  static const int repeticoesParaDominar = 3;

  /// Número de acertos consecutivos em revisões espaçadas. Treinos feitos
  /// antes da data da próxima revisão não aumentam este número.
  int repetition;

  /// Fator de facilidade – controla o crescimento do intervalo.
  /// Valor inicial recomendado: 2.5 (padrão SM‑2).
  double easeFactor;

  /// Intervalo em dias até a próxima revisão.
  int intervalDays;

  /// Data da próxima revisão calculada a partir de `DateTime.now()`.
  DateTime nextReview;

  /// Última vez em que o item foi respondido (`null` = nunca estudado).
  DateTime? ultimaRevisao;

  /// Cria um novo intervalo. Por padrão, cartões novos aparecem
  /// imediatamente disponíveis para o primeiro estudo.
  SrsInterval({
    this.repetition = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    DateTime? nextReview,
    this.ultimaRevisao,
  }) : nextReview = nextReview ?? DateTime.now();

  /// Indica se a revisão já está disponível em [agora].
  bool estaVencido(DateTime agora) => !nextReview.isAfter(agora);

  EstadoPalavra get estado {
    if (repetition >= repeticoesParaDominar) return EstadoPalavra.dominada;
    // Dados salvos por versões antigas não têm `ultimaRevisao`; qualquer
    // intervalo alterado em relação ao padrão indica que já houve estudo.
    final estudada =
        ultimaRevisao != null || repetition > 0 || easeFactor < 2.5;
    return estudada ? EstadoPalavra.aprendendo : EstadoPalavra.nova;
  }

  /// Ordem de prioridade: vencidos primeiro, depois a revisão mais próxima
  /// e, em empate, o item praticado há mais tempo.
  static int compararPrioridade(SrsInterval a, SrsInterval b, DateTime agora) {
    final vencidoA = a.estaVencido(agora);
    if (vencidoA != b.estaVencido(agora)) return vencidoA ? -1 : 1;
    final porData = a.nextReview.compareTo(b.nextReview);
    if (porData != 0) return porData;
    final inicio = DateTime.fromMillisecondsSinceEpoch(0);
    return (a.ultimaRevisao ?? inicio).compareTo(b.ultimaRevisao ?? inicio);
  }

  /// Atualiza o intervalo com base no resultado da última tentativa.
  ///
  /// - `correct` – `true` se o usuário acertou a questão.
  /// - `isEasy` - `true` se o usuário achou muito fácil, o que turbina o intervalo.
  /// - `agora` - momento da resposta (injetável para testes).
  ///
  /// Um acerto antes da revisão vencer é treino extra: não avança o domínio
  /// nem a agenda. Assim, refazer o bloco no mesmo dia não "domina" a palavra.
  /// - Retorna a própria instância para permitir encadeamento.
  SrsInterval update(bool correct, {bool isEasy = false, DateTime? agora}) {
    final momento = agora ?? DateTime.now();
    ultimaRevisao = momento;
    if (correct && !estaVencido(momento)) return this;

    if (correct) {
      // Acertou – aumenta a sequência de repetições.
      repetition += 1;
      
      if (isEasy) {
        easeFactor += 0.15; // Turbina a facilidade
      }

      // Primeiro e segundo acertos têm intervalos fixos.
      if (repetition == 1) {
        intervalDays = isEasy ? 4 : 1; 
      } else if (repetition == 2) {
        intervalDays = isEasy ? 10 : 6; 
      } else {
        // A partir da terceira repetição, usa o fator de facilidade.
        intervalDays = (intervalDays * easeFactor).round();
      }
    } else {
      // Errou – reinicia a sequência e penaliza o fator de facilidade.
      repetition = 0;
      easeFactor = (easeFactor - 0.2).clamp(1.3, double.infinity);
      intervalDays = 1;
    }
    // A revisão vence no início do dia: quem estudou à noite pode revisar
    // na manhã seguinte.
    nextReview = DateTime(
      momento.year,
      momento.month,
      momento.day + intervalDays,
    );
    return this;
  }

  /// Converte o objeto em um `Map` para persistência futura.
  Map<String, dynamic> toMap() => {
        'repetition': repetition,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReview': nextReview.toIso8601String(),
        'ultimaRevisao': ultimaRevisao?.toIso8601String(),
      };

  /// Cria uma instância a partir de um `Map`.
  factory SrsInterval.fromMap(Map<String, dynamic> map) => SrsInterval(
        repetition: map['repetition'] as int? ?? 0,
        easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: map['intervalDays'] as int? ?? 1,
        nextReview: DateTime.parse(map['nextReview'] as String? ??
            DateTime.now().toIso8601String()),
        ultimaRevisao: DateTime.tryParse(
          map['ultimaRevisao'] as String? ?? '',
        ),
      );

  Map<String, dynamic> toJson() => toMap();

  factory SrsInterval.fromJson(Map<String, dynamic> json) => SrsInterval.fromMap(json);
}
