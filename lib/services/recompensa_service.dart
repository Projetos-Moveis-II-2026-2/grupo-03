import 'dart:math';

import '../controllers/progresso_controller.dart';

/// Mensagem de incentivo cultural em inglês (expressão idiomática + tradução).
class MensagemIncentivo {
  final String id;
  final String emoji;
  final String expressaoIngles;
  final String traducao;
  final String nota;

  const MensagemIncentivo({
    required this.id,
    required this.emoji,
    required this.expressaoIngles,
    required this.traducao,
    required this.nota,
  });
}

/// Conquista leve. As de [marco] são ganhas uma única vez (persistidas);
/// as surpresas aparecem de forma aleatória e não são registradas.
class Conquista {
  final String id;
  final String emoji;
  final String titulo;
  final String descricao;
  final bool marco;

  const Conquista({
    required this.id,
    required this.emoji,
    required this.titulo,
    required this.descricao,
    this.marco = true,
  });
}

/// Dados do bloco recém-concluído usados no sorteio.
class ContextoRecompensa {
  final int acertos;
  final int total;
  final int blocosConcluidos;
  final int ofensiva;
  final int palavrasDominadas;
  final Set<String> conquistasObtidas;

  const ContextoRecompensa({
    required this.acertos,
    required this.total,
    this.blocosConcluidos = 1,
    this.ofensiva = 1,
    this.palavrasDominadas = 0,
    this.conquistasObtidas = const {},
  });

  double get taxaAcerto => total == 0 ? 0 : acertos / total;
}

class ResultadoRecompensa {
  final MensagemIncentivo mensagem;
  final Conquista? conquista;

  const ResultadoRecompensa({required this.mensagem, this.conquista});
}

/// Gerador de micro-recompensas aleatórias (reforço intermitente) para TDAH.
///
/// Regras:
/// 1. Todo bloco concluído recebe uma mensagem de incentivo em inglês.
/// 2. Blocos com muitos erros recebem mensagens acolhedoras — nunca punitivas.
/// 3. Marcos atingidos (1º bloco, ofensiva de 3 dias, etc.) liberam uma
///    conquista leve, uma única vez.
/// 4. Sem marco novo, há [chanceSurpresa] de aparecer uma conquista surpresa.
/// 5. A mesma mensagem não se repete duas vezes seguidas.
class RecompensaService {
  /// Probabilidade de uma conquista surpresa quando não há marco novo.
  static const double chanceSurpresa = 0.25;

  /// Abaixo desta taxa de acerto, usa mensagens acolhedoras.
  static const double limiteAcolhimento = 0.6;

  /// Instância compartilhada (lembra a última mensagem durante a sessão).
  static final RecompensaService padrao = RecompensaService();

  final Random _random;
  String? _ultimaMensagemId;

  RecompensaService({Random? random}) : _random = random ?? Random();

  static const List<MensagemIncentivo> mensagensIncentivo = [
    MensagemIncentivo(
      id: 'practice_perfect',
      emoji: '🎯',
      expressaoIngles: 'Practice makes perfect!',
      traducao: 'A prática leva à perfeição!',
      nota: 'Expressão clássica usada em escolas de língua inglesa.',
    ),
    MensagemIncentivo(
      id: 'on_fire',
      emoji: '🔥',
      expressaoIngles: "You're on fire!",
      traducao: 'Você está mandando muito bem!',
      nota: 'Gíria comum nos EUA para quem está numa boa sequência.',
    ),
    MensagemIncentivo(
      id: 'piece_of_cake',
      emoji: '🍰',
      expressaoIngles: 'That was a piece of cake!',
      traducao: 'Essa foi moleza!',
      nota: 'Literalmente "um pedaço de bolo": algo fácil de fazer.',
    ),
    MensagemIncentivo(
      id: 'nailed_it',
      emoji: '🔨',
      expressaoIngles: 'You nailed it!',
      traducao: 'Você acertou em cheio!',
      nota: 'Vem de "acertar o prego" com o martelo.',
    ),
    MensagemIncentivo(
      id: 'small_steps',
      emoji: '👣',
      expressaoIngles: 'Small steps, big wins!',
      traducao: 'Passos pequenos, grandes vitórias!',
      nota: 'Blocos curtos somam muito ao longo da semana.',
    ),
    MensagemIncentivo(
      id: 'brain_loves',
      emoji: '🧠',
      expressaoIngles: 'Your brain loves this!',
      traducao: 'Seu cérebro adora isso!',
      nota: 'Revisões espaçadas fortalecem a memória de longo prazo.',
    ),
    MensagemIncentivo(
      id: 'way_to_go',
      emoji: '🙌',
      expressaoIngles: 'Way to go!',
      traducao: 'É isso aí!',
      nota: 'Elogio informal muito usado por professores nos EUA.',
    ),
    MensagemIncentivo(
      id: 'keep_it_up',
      emoji: '🚀',
      expressaoIngles: 'Keep it up!',
      traducao: 'Continue assim!',
      nota: '"Keep it up" = manter o ritmo de algo que está dando certo.',
    ),
  ];

  static const List<MensagemIncentivo> mensagensAcolhedoras = [
    MensagemIncentivo(
      id: 'mistakes_help',
      emoji: '🌱',
      expressaoIngles: 'Mistakes help you learn!',
      traducao: 'Os erros ajudam você a aprender!',
      nota: 'Errar e revisar é exatamente como o SRS fixa as palavras.',
    ),
    MensagemIncentivo(
      id: 'rome_day',
      emoji: '🏛️',
      expressaoIngles: "Rome wasn't built in a day.",
      traducao: 'Roma não foi construída em um dia.',
      nota: 'Provérbio inglês: grandes resultados levam tempo.',
    ),
    MensagemIncentivo(
      id: 'every_try',
      emoji: '💜',
      expressaoIngles: 'Every try counts!',
      traducao: 'Cada tentativa conta!',
      nota: 'As palavras marcadas para rever voltam no momento certo.',
    ),
    MensagemIncentivo(
      id: 'getting_there',
      emoji: '🧭',
      expressaoIngles: "You're getting there!",
      traducao: 'Você está chegando lá!',
      nota: 'Usado para encorajar quem está no meio do caminho.',
    ),
  ];

  static const Conquista primeiroPasso = Conquista(
    id: 'first_step',
    emoji: '🌟',
    titulo: 'First Step!',
    descricao: 'Concluiu o seu primeiro bloco de estudo.',
  );
  static const Conquista blocoPerfeito = Conquista(
    id: 'flawless',
    emoji: '💎',
    titulo: 'Flawless!',
    descricao: 'Acertou todos os itens de um bloco.',
  );
  static const Conquista nuncaDesiste = Conquista(
    id: 'never_give_up',
    emoji: '🦾',
    titulo: 'Never Give Up!',
    descricao: 'Concluiu um bloco desafiador até o fim.',
  );
  static const Conquista iniciaOfensiva = Conquista(
    id: 'streak_starter',
    emoji: '🔥',
    titulo: 'Streak Starter',
    descricao: 'Estudou em 3 dias da sua sequência.',
  );
  static const Conquista wordMaster = Conquista(
    id: 'word_master',
    emoji: '📚',
    titulo: 'Word Master!',
    descricao: 'Dominou 5 palavras em inglês.',
  );
  static const Conquista focusChampion = Conquista(
    id: 'focus_champion',
    emoji: '🏆',
    titulo: 'Focus Champion',
    descricao: 'Concluiu 10 blocos curtos de estudo.',
  );

  /// Conquistas surpresa (repetíveis, não persistidas).
  static const List<Conquista> conquistasSurpresa = [
    Conquista(
      id: 'surpresa_brain_booster',
      emoji: '⚡',
      titulo: 'Brain Booster',
      descricao: 'Surpresa! Seu foco rendeu um bônus hoje.',
      marco: false,
    ),
    Conquista(
      id: 'surpresa_curious_mind',
      emoji: '🔍',
      titulo: 'Curious Mind',
      descricao: 'Surpresa! Curiosidade é o motor do aprendizado.',
      marco: false,
    ),
    Conquista(
      id: 'surpresa_steady_learner',
      emoji: '🐢',
      titulo: 'Steady Learner',
      descricao: 'Surpresa! Constância vale mais que velocidade.',
      marco: false,
    ),
  ];

  /// Marcos na ordem de prioridade de exibição (um por bloco, para não
  /// sobrecarregar; os demais aparecem nos próximos blocos).
  static List<Conquista> _marcosAtingidos(ContextoRecompensa c) => [
    if (c.blocosConcluidos >= 1) primeiroPasso,
    if (c.total > 0 && c.acertos >= c.total) blocoPerfeito,
    if (c.total - c.acertos >= 3) nuncaDesiste,
    if (c.ofensiva >= 3) iniciaOfensiva,
    if (c.palavrasDominadas >= 5) wordMaster,
    if (c.blocosConcluidos >= 10) focusChampion,
  ];

  ResultadoRecompensa sortear(ContextoRecompensa contexto) {
    final acolher = contexto.taxaAcerto < limiteAcolhimento;
    final mensagem = _sortearMensagem(
      acolher ? mensagensAcolhedoras : mensagensIncentivo,
    );

    Conquista? conquista;
    for (final marco in _marcosAtingidos(contexto)) {
      if (!contexto.conquistasObtidas.contains(marco.id)) {
        conquista = marco;
        break;
      }
    }
    if (conquista == null && _random.nextDouble() < chanceSurpresa) {
      conquista =
          conquistasSurpresa[_random.nextInt(conquistasSurpresa.length)];
    }

    return ResultadoRecompensa(mensagem: mensagem, conquista: conquista);
  }

  /// Sorteia, registra a conquista de marco no progresso e devolve o
  /// resultado para a tela de conclusão exibir.
  ResultadoRecompensa concederAoConcluirBloco({
    required int acertos,
    required int total,
    required int palavrasDominadas,
    ProgressoController? progresso,
  }) {
    final resultado = sortear(
      ContextoRecompensa(
        acertos: acertos,
        total: total,
        blocosConcluidos: progresso?.blocosConcluidos ?? 1,
        ofensiva: progresso?.ofensiva ?? 1,
        palavrasDominadas: palavrasDominadas,
        conquistasObtidas: progresso?.conquistas.toSet() ?? const {},
      ),
    );
    final conquista = resultado.conquista;
    if (conquista != null && conquista.marco) {
      progresso?.registrarConquista(conquista.id);
    }
    return resultado;
  }

  MensagemIncentivo _sortearMensagem(List<MensagemIncentivo> opcoes) {
    final candidatas = opcoes.length > 1
        ? opcoes.where((m) => m.id != _ultimaMensagemId).toList()
        : opcoes;
    final escolhida = candidatas[_random.nextInt(candidatas.length)];
    _ultimaMensagemId = escolhida.id;
    return escolhida;
  }
}
