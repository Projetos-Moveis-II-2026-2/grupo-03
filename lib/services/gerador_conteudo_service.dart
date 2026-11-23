import 'dart:math';

import '../models/card_ingles.dart';
import '../models/questao_simulado.dart';
import 'vocabulario_api.dart';

/// Deck gerado automaticamente a partir de um tema.
class DeckGerado {
  final String tema;
  final String titulo;
  final List<CardIngles> cards;
  final List<QuestaoSimulado> questoes;

  const DeckGerado({
    required this.tema,
    required this.titulo,
    required this.cards,
    required this.questoes,
  });
}

/// Gera automaticamente flashcards e questões de simulado a partir de um
/// tema em inglês, consumindo APIs públicas (ver [VocabularioApi]):
///
/// 1. **Datamuse** sugere palavras do tema;
/// 2. as candidatas são filtradas (comuns, palavra única, sem variações
///    do próprio tema) para servir a iniciantes;
/// 3. **Free Dictionary** fornece fonética e frase de exemplo;
/// 4. **MyMemory** traduz a palavra e o exemplo para o português;
/// 5. as questões de múltipla escolha são montadas localmente, usando as
///    outras palavras do deck como alternativas incorretas.
///
/// Cada questão gerada já sai ligada à sua palavra (`cardId`), então a
/// recomendação adaptativa funciona com o conteúdo novo.
class GeradorConteudoService {
  /// Palavras por deck (= 1 bloco curto).
  static const int tamanhoDeck = 5;

  /// Mínimo para montar questões com 4 alternativas distintas.
  static const int minimoCards = 4;

  /// Faixa de frequência (ocorrências por milhão) considerada adequada:
  /// exclui palavras raras ("locomote") e genéricas demais ("go").
  static const double frequenciaMinima = 2.0;
  static const double frequenciaMaxima = 120.0;

  static const int _maxCandidatas = 14;

  final VocabularioApi _api;
  final Random _random;

  GeradorConteudoService({VocabularioApi? api, Random? random})
    : _api = api ?? VocabularioApi(),
      _random = random ?? Random();

  /// Gera um deck com até [quantidade] palavras do [tema] (em inglês).
  ///
  /// Lança [VocabularioApiException] com mensagem amigável quando não há
  /// conexão ou o tema não rende palavras suficientes.
  Future<DeckGerado> gerarDeck(
    String tema, {
    String? titulo,
    int quantidade = tamanhoDeck,
  }) async {
    final temaNormalizado = tema.trim().toLowerCase();
    if (!RegExp(r'^[a-z][a-z ]{1,29}$').hasMatch(temaNormalizado)) {
      throw const VocabularioApiException(
        'Digite um tema em inglês, só com letras (ex.: travel, food).',
      );
    }

    final candidatas = filtrarCandidatas(
      await _api.buscarPalavras(temaNormalizado),
      temaNormalizado,
    ).take(_maxCandidatas).toList();
    if (candidatas.length < minimoCards) {
      throw const VocabularioApiException(
        'Encontramos poucas palavras para esse tema. Que tal tentar outro?',
      );
    }

    final detalhes = await _buscarTodos(
      candidatas,
      (c) => _api.buscarDetalhes(c.palavra),
    );
    final comExemplo = [
      for (var i = 0; i < candidatas.length; i++)
        if (detalhes[i] != null) (candidatas[i], detalhes[i]!),
    ].take(quantidade + 3).toList();

    final traducoes = await _buscarTodos(comExemplo, (item) async {
      final (candidata, detalhe) = item;
      final resultado = await Future.wait([
        _api.traduzir(candidata.palavra),
        _api.traduzir(detalhe.exemplo),
      ]);
      if (resultado.contains(null)) return null;
      return (resultado[0]!, resultado[1]!);
    });

    final tituloDeck = titulo ?? _capitalizar(temaNormalizado);
    final cards = <CardIngles>[];
    for (var i = 0; i < comExemplo.length && cards.length < quantidade; i++) {
      final traducao = traducoes[i];
      if (traducao == null) continue;
      final (candidata, detalhe) = comExemplo[i];
      cards.add(
        CardIngles(
          id: 'gen_${_slug(temaNormalizado)}_${candidata.palavra}',
          termo: _capitalizar(candidata.palavra),
          fonetica: detalhe.fonetica,
          traducao: _capitalizar(traducao.$1),
          exemploIngles: detalhe.exemplo,
          traducaoExemplo: traducao.$2,
          categoria: '$tituloDeck ✨',
        ),
      );
    }
    if (cards.length < minimoCards) {
      throw const VocabularioApiException(
        'Não foi possível montar um deck completo agora. '
        'Tente outro tema ou tente novamente mais tarde.',
      );
    }

    return DeckGerado(
      tema: temaNormalizado,
      titulo: tituloDeck,
      cards: cards,
      questoes: gerarQuestoes(cards, random: _random),
    );
  }

  /// Executa [buscar] para cada item em paralelo. Falhas individuais viram
  /// `null` (o item é descartado); se **todas** falharem por erro de rede,
  /// a primeira falha é propagada para a tela mostrar "Tentar novamente".
  static Future<List<R?>> _buscarTodos<T, R>(
    List<T> itens,
    Future<R?> Function(T) buscar,
  ) async {
    VocabularioApiException? primeiraFalha;
    var falhas = 0;
    final resultados = await Future.wait(
      itens.map((item) async {
        try {
          return await buscar(item);
        } on VocabularioApiException catch (e) {
          primeiraFalha ??= e;
          falhas++;
          return null;
        }
      }),
    );
    if (itens.isNotEmpty && falhas == itens.length) throw primeiraFalha!;
    return resultados;
  }

  /// Mantém só palavras úteis para iniciantes, na ordem original.
  static List<PalavraCandidata> filtrarCandidatas(
    List<PalavraCandidata> candidatas,
    String tema,
  ) {
    final raizTema = tema.length > 5 ? tema.substring(0, 5) : tema;
    final chaves = <String>{};
    final resultado = <PalavraCandidata>[];
    for (final c in candidatas) {
      final palavra = c.palavra.toLowerCase();
      if (!RegExp(r'^[a-z]{3,14}$').hasMatch(palavra)) continue;
      if (c.classes.isEmpty) continue;
      if (c.frequencia < frequenciaMinima || c.frequencia > frequenciaMaxima) {
        continue;
      }
      if (palavra.startsWith(raizTema) || tema.startsWith(palavra)) continue;
      // Formas em -ing ("eating", "feeding"): prefere a forma base.
      if (palavra.length > 5 && palavra.endsWith('ing')) continue;
      // Evita "ticket"/"tickets" e "eat"/"eats" no mesmo deck.
      final chave = palavra.length >= 4 && palavra.endsWith('s')
          ? palavra.substring(0, palavra.length - 1)
          : palavra;
      if (!chaves.add(chave)) continue;
      resultado.add(c);
    }
    return resultado;
  }

  /// Monta uma questão de múltipla escolha por cartão, alternando entre
  /// três formatos para variar o estímulo:
  /// - completar a frase de exemplo com a palavra;
  /// - escolher a tradução da palavra;
  /// - escolher a palavra em inglês a partir da tradução.
  ///
  /// As alternativas incorretas vêm das outras palavras do mesmo deck.
  static List<QuestaoSimulado> gerarQuestoes(
    List<CardIngles> cards, {
    Random? random,
  }) {
    final rnd = random ?? Random();
    final questoes = <QuestaoSimulado>[];
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final outros = [...cards]..removeAt(i);
      final formatos = [_completarFrase, _escolherTraducao, _escolherTermo];
      for (var t = 0; t < formatos.length; t++) {
        final questao = formatos[(i + t) % formatos.length](card, outros, rnd);
        if (questao != null) {
          questoes.add(questao);
          break;
        }
      }
    }
    return questoes;
  }

  static QuestaoSimulado? _completarFrase(
    CardIngles card,
    List<CardIngles> outros,
    Random rnd,
  ) {
    final padrao = RegExp(
      '\\b${RegExp.escape(card.termo)}\\b',
      caseSensitive: false,
    );
    if (!padrao.hasMatch(card.exemploIngles)) return null;
    return _montar(
      card: card,
      enunciado:
          'Complete a frase: "${card.exemploIngles.replaceAll(padrao, '_____')}"',
      correta: card.termo.toLowerCase(),
      // Sinônimos de mesma tradução também caberiam na frase: ficam de fora.
      distratores: outros
          .where((c) => c.traducao.toLowerCase() != card.traducao.toLowerCase())
          .map((c) => c.termo.toLowerCase()),
      rnd: rnd,
    );
  }

  static QuestaoSimulado? _escolherTraducao(
    CardIngles card,
    List<CardIngles> outros,
    Random rnd,
  ) => _montar(
    card: card,
    enunciado: 'Qual a tradução mais adequada para "${card.termo}"?',
    correta: card.traducao,
    distratores: outros.map((c) => c.traducao),
    rnd: rnd,
  );

  static QuestaoSimulado? _escolherTermo(
    CardIngles card,
    List<CardIngles> outros,
    Random rnd,
  ) => _montar(
    card: card,
    enunciado: 'Qual palavra em inglês significa "${card.traducao}"?',
    correta: card.termo,
    // Exclui palavras com a mesma tradução ("Trip" e "Journey" = "Viagem"),
    // senão a questão teria duas respostas corretas.
    distratores: outros
        .where((c) => c.traducao.toLowerCase() != card.traducao.toLowerCase())
        .map((c) => c.termo),
    rnd: rnd,
  );

  static QuestaoSimulado? _montar({
    required CardIngles card,
    required String enunciado,
    required String correta,
    required Iterable<String> distratores,
    required Random rnd,
  }) {
    final usadas = {correta.toLowerCase()};
    final incorretas = <String>[];
    for (final d in distratores.toList()..shuffle(rnd)) {
      if (usadas.add(d.toLowerCase())) incorretas.add(d);
      if (incorretas.length == 3) break;
    }
    if (incorretas.length < 3) return null;

    final opcoes = [correta, ...incorretas]..shuffle(rnd);
    return QuestaoSimulado(
      id: 'q_${card.id}',
      cardId: card.id,
      enunciado: enunciado,
      opcoes: opcoes,
      indiceCorreto: opcoes.indexOf(correta),
      explicacao:
          '"${card.termo}" significa "${card.traducao}". '
          'Exemplo: ${card.exemploIngles}',
    );
  }

  static String _capitalizar(String texto) =>
      texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';

  static String _slug(String texto) =>
      texto.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}
