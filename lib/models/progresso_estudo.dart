/// Métricas acumuladas de estudo de um estudante no FocoDeck.
///
/// Classe pura (sem dependência de UI ou de armazenamento), serializável
/// via `toJson`/`fromJson` para permitir persistência local agora
/// (SharedPreferences) e remota depois (Supabase - Etapa 3).
class ProgressoEstudo {
  /// Dias seguidos de estudo (ofensiva flexível).
  int ofensivaAtual;

  /// Maior ofensiva já alcançada.
  int maiorOfensiva;

  /// Último dia (sem hora) em que o estudante concluiu um bloco.
  DateTime? ultimoDiaEstudo;

  /// Tempo total estudado, em segundos.
  int segundosEstudados;

  /// Quantidade de blocos curtos concluídos.
  int blocosConcluidos;

  /// Revisões feitas no dia indicado em [dataRevisoesHoje].
  int revisoesHoje;

  /// Dia (sem hora) a que [revisoesHoje] se refere.
  DateTime? dataRevisoesHoje;

  /// Total de respostas corretas (flashcards "Bom/Fácil" + acertos no simulado).
  int acertosTotais;

  /// Total de respostas dadas.
  int respostasTotais;

  /// Quantidade de erros/"Rever" por cartão (cardId -> erros).
  /// Base para a recomendação adaptativa (IA) dos simulados.
  Map<String, int> errosPorCard;

  /// Identificadores das conquistas leves já obtidas.
  List<String> conquistas;

  ProgressoEstudo({
    this.ofensivaAtual = 0,
    this.maiorOfensiva = 0,
    this.ultimoDiaEstudo,
    this.segundosEstudados = 0,
    this.blocosConcluidos = 0,
    this.revisoesHoje = 0,
    this.dataRevisoesHoje,
    this.acertosTotais = 0,
    this.respostasTotais = 0,
    Map<String, int>? errosPorCard,
    List<String>? conquistas,
  })  : errosPorCard = errosPorCard ?? {},
        conquistas = conquistas ?? [];

  Map<String, dynamic> toJson() => {
        'ofensivaAtual': ofensivaAtual,
        'maiorOfensiva': maiorOfensiva,
        'ultimoDiaEstudo': ultimoDiaEstudo?.toIso8601String(),
        'segundosEstudados': segundosEstudados,
        'blocosConcluidos': blocosConcluidos,
        'revisoesHoje': revisoesHoje,
        'dataRevisoesHoje': dataRevisoesHoje?.toIso8601String(),
        'acertosTotais': acertosTotais,
        'respostasTotais': respostasTotais,
        'errosPorCard': errosPorCard,
        'conquistas': conquistas,
      };

  factory ProgressoEstudo.fromJson(Map<String, dynamic> json) {
    DateTime? lerData(Object? valor) =>
        valor is String ? DateTime.tryParse(valor) : null;

    final errosRaw = json['errosPorCard'];
    final conquistasRaw = json['conquistas'];

    return ProgressoEstudo(
      ofensivaAtual: (json['ofensivaAtual'] as num?)?.toInt() ?? 0,
      maiorOfensiva: (json['maiorOfensiva'] as num?)?.toInt() ?? 0,
      ultimoDiaEstudo: lerData(json['ultimoDiaEstudo']),
      segundosEstudados: (json['segundosEstudados'] as num?)?.toInt() ?? 0,
      blocosConcluidos: (json['blocosConcluidos'] as num?)?.toInt() ?? 0,
      revisoesHoje: (json['revisoesHoje'] as num?)?.toInt() ?? 0,
      dataRevisoesHoje: lerData(json['dataRevisoesHoje']),
      acertosTotais: (json['acertosTotais'] as num?)?.toInt() ?? 0,
      respostasTotais: (json['respostasTotais'] as num?)?.toInt() ?? 0,
      errosPorCard: errosRaw is Map
          ? errosRaw.map(
              (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
            )
          : null,
      conquistas: conquistasRaw is List
          ? conquistasRaw.map((e) => e.toString()).toList()
          : null,
    );
  }
}
