import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questao_simulado.dart';
import '../models/srs_interval.dart';
import '../services/conteudo_api.dart';

/// Repositório REST das questões e persistência local dos intervalos SRS.
class QuestaoRepository {
  static const String _prefsKey = 'srs_questoes_intervals';

  final SharedPreferences? _prefs;

  // Lista fixa de questões (pode ser carregada de um JSON futuro).
  final ConteudoApi _api;
  // Conteúdo embarcado é apenas fallback offline; o primeiro carregamento
  // sempre consulta a API REST.
  final List<QuestaoSimulado> _questoes = List.from(
    QuestaoSimulado.simuladoInicial,
  );
  Future<List<QuestaoSimulado>>? _carregamento;
  bool _carregado = true;
  bool _remotoCarregado = false;

  // Mapeamento id -> SrsInterval para cada questão.
  final Map<String, SrsInterval> _intervals = {};

  QuestaoRepository({SharedPreferences? prefs, ConteudoApi? api})
    : _prefs = prefs,
      _api = api ?? ConteudoApi() {
    // Inicializa o intervalo padrão para cada questão.
    for (var q in _questoes) {
      _intervals[q.id] = SrsInterval();
    }
    _carregarDoPrefs();
  }

  bool get hasCachedQuestions => _carregado && _questoes.isNotEmpty;

  /// Busca questões da tabela documentada `questoes_simulado` e conserva
  /// a resposta em memória durante a sessão.
  Future<List<QuestaoSimulado>> carregar({bool atualizar = false}) {
    if (!atualizar && _remotoCarregado) return Future.value(getAll());
    if (!atualizar && _carregamento != null) return _carregamento!;
    final request = _api.listar('questoes_simulado').then((rows) {
      final questoes = rows
          .map(QuestaoSimulado.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
      _questoes
        ..clear()
        ..addAll(questoes);
      for (final questao in questoes) {
        _intervals.putIfAbsent(questao.id, SrsInterval.new);
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

  /// Retorna todas as questões.
  List<QuestaoSimulado> getAll() => List.unmodifiable(_questoes);

  /// Obtém o intervalo SRS associado a uma questão.
  SrsInterval getInterval(String questaoId) =>
      _intervals[questaoId] ?? SrsInterval();

  /// Persiste (ou atualiza) o intervalo de uma questão.
  void saveInterval(String questaoId, SrsInterval intervalo) {
    _intervals[questaoId] = intervalo;
    _salvarNoPrefs();
  }

  /// Busca um bloco de questões para a próxima sessão de revisão.
  /// Prioriza questões cujo próximo review já passou e limita ao tamanho do bloco.
  List<QuestaoSimulado> getDueQuestionsBlock(
    int limit, {
    List<QuestaoSimulado>? questoesFiltro,
  }) {
    final now = DateTime.now();

    final List<QuestaoSimulado> sourceList;
    if (questoesFiltro != null && questoesFiltro.isNotEmpty) {
      for (final q in questoesFiltro) {
        _intervals.putIfAbsent(q.id, () => SrsInterval());
      }
      sourceList = questoesFiltro.toList();
    } else {
      sourceList = _questoes.toList();
    }

    // Ordena priorizando quem já passou do prazo, e depois pelo tempo do proximo review
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
