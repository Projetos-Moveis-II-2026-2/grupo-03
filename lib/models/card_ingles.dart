/// Modelo de dados que representa um cartão de vocabulário em inglês.
class CardIngles {
  final String id;
  final String termo;
  final String fonetica;
  final String traducao;
  final String exemploIngles;
  final String traducaoExemplo;
  final String categoria;

  const CardIngles({
    required this.id,
    required this.termo,
    required this.fonetica,
    required this.traducao,
    required this.exemploIngles,
    required this.traducaoExemplo,
    required this.categoria,
  });

  /// Lista padrão com pronúncia figurada para o português brasileiro
  /// e sílaba tônica em MAIÚSCULAS para indicar a entonação correta.
  static const List<CardIngles> cardsIniciais = [
    CardIngles(
      id: 'card_1',
      termo: 'Focus',
      fonetica: 'FÔU-kâs',
      traducao: 'Foco / Concentração',
      exemploIngles: 'Take a deep breath and keep your focus on this task.',
      traducaoExemplo: 'Respire fundo e mantenha seu foco nesta tarefa.',
      categoria: 'Mindset & Estudos',
    ),
    CardIngles(
      id: 'card_2',
      termo: 'Breakdown',
      fonetica: 'BRÊIK-daun',
      traducao: 'Dividir em partes menores',
      exemploIngles: 'Breakdown large goals into short, actionable steps.',
      traducaoExemplo: 'Divida metas grandes em passos curtos e executáveis.',
      categoria: 'Produtividade',
    ),
    CardIngles(
      id: 'card_3',
      termo: 'Consistency',
      fonetica: 'kân-SÍS-tên-si',
      traducao: 'Consistência / Constância',
      exemploIngles: 'Small daily consistency brings extraordinary results.',
      traducaoExemplo: 'Pequena consistência diária traz resultados extraordinários.',
      categoria: 'Hábitos',
    ),
    CardIngles(
      id: 'card_4',
      termo: 'Achievement',
      fonetica: 'a-TCHÍIV-mênt',
      traducao: 'Conquista / Realização',
      exemploIngles: 'Celebrate every single achievement, no matter how small.',
      traducaoExemplo: 'Celebre cada conquista, por menor que seja.',
      categoria: 'Motivação',
    ),
    CardIngles(
      id: 'card_5',
      termo: 'Reward',
      fonetica: 'ri-WÓRD',
      traducao: 'Recompensa / Prêmio',
      exemploIngles: 'Give your brain a healthy reward after completing a block.',
      traducaoExemplo: 'Dê ao seu cérebro uma recompensa saudável após concluir um bloco.',
      categoria: 'Neurociência & TDAH',
    ),
  ];
}
