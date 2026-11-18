/// Modelo simples para representar uma questão de simulado ou quiz rápido de inglês.
class QuestaoSimulado {
  final String id;
  final String enunciado;
  final List<String> opcoes;
  final int indiceCorreto;
  final String explicacao;

  /// Id do cartão de vocabulário (`CardIngles.id`) avaliado pela questão.
  /// Liga o desempenho no simulado à palavra, permitindo a recomendação
  /// adaptativa (priorizar as palavras com mais erros/"Rever").
  final String? cardId;

  const QuestaoSimulado({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.indiceCorreto,
    required this.explicacao,
    this.cardId,
  });

  /// Conjunto acadêmico inicial de questões em bloco curto (5 itens)
  /// focado no vocabulário já trabalhado nos flashcards.
  static const List<QuestaoSimulado> simuladoInicial = [
    QuestaoSimulado(
      id: 'q_1',
      cardId: 'card_4',
      enunciado: 'Qual a tradução mais adequada para o termo "Achievement"?',
      opcoes: [
        'Divisão de tarefas',
        'Conquista / Realização',
        'Recompensa imediata',
        'Consistência diária',
      ],
      indiceCorreto: 1,
      explicacao:
          '"Achievement" significa conquista ou realização de um objetivo.',
    ),
    QuestaoSimulado(
      id: 'q_2',
      cardId: 'card_1',
      enunciado:
          'Complete a frase com foco nos estudos: "Take a deep breath and keep your _____ on this task."',
      opcoes: ['focus', 'break', 'schedule', 'luggage'],
      indiceCorreto: 0,
      explicacao:
          '"Focus" (foco/concentração) é a palavra que melhor completa o sentido da frase.',
    ),
    QuestaoSimulado(
      id: 'q_3',
      cardId: 'card_2',
      enunciado:
          'O que significa a expressão "Breakdown" em um contexto de produtividade?',
      opcoes: [
        'Desistir de uma meta difícil',
        'Trabalhar sem fazer pausas',
        'Dividir uma meta grande em partes menores',
        'Chegar atrasado a um compromisso',
      ],
      indiceCorreto: 2,
      explicacao:
          '"Breakdown" refere-se a fragmentar um objetivo complexo em etapas curtas e fáceis.',
    ),
    QuestaoSimulado(
      id: 'q_4',
      cardId: 'card_3',
      enunciado:
          'Qual termo representa o conceito de "Consistência / Constância"?',
      opcoes: ['Schedule', 'Reward', 'Boarding pass', 'Consistency'],
      indiceCorreto: 3,
      explicacao:
          '"Consistency" é a prática de manter o hábito de estudos de forma constante.',
    ),
    QuestaoSimulado(
      id: 'q_5',
      cardId: 'card_5',
      enunciado:
          'Qual a tradução da palavra "Reward", essencial para a motivação no TDAH?',
      opcoes: [
        'Recompensa / Prêmio',
        'Horário de dormir',
        'Cartão de embarque',
        'Lista de tarefas pendentes',
      ],
      indiceCorreto: 0,
      explicacao:
          '"Reward" significa recompensa ou prêmio pelo esforço realizado.',
    ),
  ];

  factory QuestaoSimulado.fromJson(Map<String, dynamic> json) {
    return QuestaoSimulado(
      id: '${json['id'] ?? ''}',
      enunciado: (json['enunciado'] ?? json['pergunta'] ?? '') as String,
      opcoes: List<String>.from(
        json['opcoes'] as List? ?? json['alternativas'] as List? ?? const [],
      ),
      indiceCorreto:
          (json['indiceCorreto'] ?? json['indice_correto'] ?? 0) as int,
      explicacao: (json['explicacao'] ?? '') as String,
      cardId: (json['cardId'] ?? json['card_id']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enunciado': enunciado,
      'opcoes': opcoes,
      'indiceCorreto': indiceCorreto,
      'explicacao': explicacao,
      if (cardId != null) 'cardId': cardId,
    };
  }
}
