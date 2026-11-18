import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_ingles.dart';
import '../models/srs_interval.dart';
import '../services/conteudo_api.dart';

/// Repositório REST dos flashcards e persistência local dos intervalos SRS.
class FlashcardRepository {
  static const String _prefsKey = 'srs_flashcards_intervals';

  /// Acertos consecutivos no SRS para considerar uma palavra "dominada".
  /// Após 3 acertos seguidos o intervalo já passa de 1 semana (SM-2).
  static const int repeticoesParaDominar = 3;

  final SharedPreferences? _prefs;

  // Inicialize com todos os cartões disponíveis
  final ConteudoApi _api;
  // Conteúdo embarcado é apenas fallback offline; o primeiro carregamento
  // sempre consulta a API REST.
  final List<CardIngles> _cards = List.from(CardIngles.cardsIniciais);
  Future<List<CardIngles>>? _carregamento;
  bool _carregado = true;
  bool _remotoCarregado = false;

  // Mapeamento id -> SrsInterval para cada cartão.
  final Map<String, SrsInterval> _intervals = {};

  FlashcardRepository({SharedPreferences? prefs, ConteudoApi? api})
    : _prefs = prefs,
      _api = api ?? ConteudoApi() {
    // Inicializa o intervalo padrão para cada cartão
    for (var card in _cards) {
      _intervals[card.id] = SrsInterval();
    }
    _carregarDoPrefs();
  }

  bool get hasCachedCards => _carregado && _cards.isNotEmpty;

  /// Busca conteúdo da tabela documentada `cards_vocabulario`, mantendo o
  /// último resultado em memória para navegação e uso durante a sessão.
  Future<List<CardIngles>> carregar({bool atualizar = false}) {
    if (!atualizar && _remotoCarregado) return Future.value(getAll());
    if (!atualizar && _carregamento != null) return _carregamento!;
    final request = _api.listar('cards_vocabulario').then((rows) {
      final cards = rows
          .map(CardIngles.fromJson)
          .where((c) => c.id.isNotEmpty)
          .toList();
      _cards
        ..clear()
        ..addAll(cards);
      for (final card in cards) {
        _intervals.putIfAbsent(card.id, SrsInterval.new);
      }
      _carregado = true;
      _remotoCarregado = true;
      return getAll();
    });
    _carregamento = request;
    return request.whenComplete(() => _carregamento = null);
  }

  void _carregarDoPrefs() {
    if (_prefs == null) return;
    final jsonStr = _prefs.getString(_prefsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        data.forEach((key, value) {
          if (value is Map) {
            _intervals[key] = SrsInterval.fromMap(
              Map<String, dynamic>.from(value),
            );
          }
        });
      } catch (_) {}
    }
  }

  void _salvarNoPrefs() {
    if (_prefs == null) return;
    final jsonStr = jsonEncode(
      _intervals.map((k, v) => MapEntry(k, v.toMap())),
    );
    _prefs.setString(_prefsKey, jsonStr);
  }

  /// Retorna todos os flashcards.
  List<CardIngles> getAll() => List.unmodifiable(_cards);

  /// Obtém o intervalo SRS associado a um cartão.
  SrsInterval getInterval(String cardId) => _intervals[cardId] ?? SrsInterval();

  /// Persiste (ou atualiza) o intervalo de um cartão.
  void saveInterval(String cardId, SrsInterval intervalo) {
    _intervals[cardId] = intervalo;
    _salvarNoPrefs();
  }

  /// Quantidade de cartões com revisão vencida (disponíveis agora).
  int contarPendentes() {
    final now = DateTime.now();
    return _intervals.values.where((i) => !i.nextReview.isAfter(now)).length;
  }

  /// Quantidade de palavras dominadas pelo estudante.
  int contarDominados() => _intervals.values
      .where((i) => i.repetition >= repeticoesParaDominar)
      .length;

  /// Busca um bloco de flashcards para a próxima sessão de revisão.
  /// Prioriza cartões cujo próximo review já passou e limita ao tamanho do bloco.
  List<CardIngles> getDueCardsBlock(
    int limit, {
    List<CardIngles>? cardsFiltro,
  }) {
    final now = DateTime.now();

    final List<CardIngles> sourceList;
    if (cardsFiltro != null && cardsFiltro.isNotEmpty) {
      for (final card in cardsFiltro) {
        _intervals.putIfAbsent(card.id, () => SrsInterval());
      }
      sourceList = cardsFiltro.toList();
    } else {
      sourceList = _cards.toList();
    }

    sourceList.sort((a, b) {
      final intA = getInterval(a.id);
      final intB = getInterval(b.id);

      final isDueA = !intA.nextReview.isAfter(now) ? 0 : 1;
      final isDueB = !intB.nextReview.isAfter(now) ? 0 : 1;

      if (isDueA != isDueB) return isDueA.compareTo(isDueB);

      return intA.nextReview.compareTo(intB.nextReview);
    });

    return sourceList.take(limit).toList();
  }
}
