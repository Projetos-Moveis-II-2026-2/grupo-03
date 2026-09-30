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
  /// Número de repetições corretas consecutivas.
  int repetition;

  /// Fator de facilidade – controla o crescimento do intervalo.
  /// Valor inicial recomendado: 2.5 (padrão SM‑2).
  double easeFactor;

  /// Intervalo em dias até a próxima revisão.
  int intervalDays;

  /// Data da próxima revisão calculada a partir de `DateTime.now()`.
  DateTime nextReview;

  /// Cria um novo intervalo. Por padrão, a primeira revisão ocorre
  /// no próximo dia.
  SrsInterval({
    this.repetition = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    DateTime? nextReview,
  }) : nextReview = nextReview ?? DateTime.now().add(const Duration(days: 1));

  /// Atualiza o intervalo com base no resultado da última tentativa.
  ///
  /// - `correct` – `true` se o usuário acertou a questão.
  /// - `isEasy` - `true` se o usuário achou muito fácil, o que turbina o intervalo.
  /// - Retorna a própria instância para permitir encadeamento.
  SrsInterval update(bool correct, {bool isEasy = false}) {
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
    // Recalcula a data da próxima revisão.
    nextReview = DateTime.now().add(Duration(days: intervalDays));
    return this;
  }

  /// Converte o objeto em um `Map` para persistência futura.
  Map<String, dynamic> toMap() => {
        'repetition': repetition,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReview': nextReview.toIso8601String(),
      };

  /// Cria uma instância a partir de um `Map`.
  factory SrsInterval.fromMap(Map<String, dynamic> map) => SrsInterval(
        repetition: map['repetition'] as int? ?? 0,
        easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: map['intervalDays'] as int? ?? 1,
        nextReview: DateTime.parse(map['nextReview'] as String? ??
            DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      );
}
