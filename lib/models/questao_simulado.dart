/// Modelo simples para representar uma questão de simulado ou quiz rápido de inglês.
class QuestaoSimulado {
  final String id;
  final String enunciado;
  final List<String> opcoes;
  final int indiceCorreto;
  final String explicacao;

  const QuestaoSimulado({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.indiceCorreto,
    required this.explicacao,
  });

  /// Conjunto acadêmico inicial de questões em bloco curto (5 itens)
  /// focado no vocabulário já trabalhado nos flashcards.
  static const List<QuestaoSimulado> simuladoInicial = [
    QuestaoSimulado(
      id: 'q_1',
      enunciado: 'Qual a tradução mais adequada para o termo "Achievement"?',
      opcoes: [
        'Divisão de tarefas',
        'Conquista / Realização',
        'Recompensa imediata',
        'Consistência diária',
      ],
      indiceCorreto: 1,
      explicacao: '"Achievement" significa conquista ou realização de um objetivo.',
    ),
    QuestaoSimulado(
      id: 'q_2',
      enunciado: 'Complete a frase com foco nos estudos: "Take a deep breath and keep your _____ on this task."',
      opcoes: [
        'focus',
        'break',
        'schedule',
        'luggage',
      ],
      indiceCorreto: 0,
      explicacao: '"Focus" (foco/concentração) é a palavra que melhor completa o sentido da frase.',
    ),
    QuestaoSimulado(
      id: 'q_3',
      enunciado: 'O que significa a expressão "Breakdown" em um contexto de produtividade?',
      opcoes: [
        'Desistir de uma meta difícil',
        'Trabalhar sem fazer pausas',
        'Dividir uma meta grande em partes menores',
        'Chegar atrasado a um compromisso',
      ],
      indiceCorreto: 2,
      explicacao: '"Breakdown" refere-se a fragmentar um objetivo complexo em etapas curtas e fáceis.',
    ),
    QuestaoSimulado(
      id: 'q_4',
      enunciado: 'Qual termo representa o conceito de "Consistência / Constância"?',
      opcoes: [
        'Schedule',
        'Reward',
        'Boarding pass',
        'Consistency',
      ],
      indiceCorreto: 3,
      explicacao: '"Consistency" é a prática de manter o hábito de estudos de forma constante.',
    ),
    QuestaoSimulado(
      id: 'q_5',
      enunciado: 'Qual a tradução da palavra "Reward", essencial para a motivação no TDAH?',
      opcoes: [
        'Recompensa / Prêmio',
        'Horário de dormir',
        'Cartão de embarque',
        'Lista de tarefas pendentes',
      ],
      indiceCorreto: 0,
      explicacao: '"Reward" significa recompensa ou prêmio pelo esforço realizado.',
    ),
  ];
}
