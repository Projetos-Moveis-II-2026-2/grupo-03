import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questao_simulado.dart';
import '../models/srs_interval.dart';
import '../services/conteudo_api.dart';
import '../services/gerador_conteudo_service.dart';

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

  /// Questões geradas automaticamente a partir dos decks gerados.
  /// Separadas do conteúdo da API e persistidas no aparelho.
  static const String _prefsGeradasKey = 'focodeck_questoes_geradas';
  final List<QuestaoSimulado> _geradas = [];
  String _usuarioId = '';

  String get _chaveIntervalos =>
      _usuarioId.isEmpty ? _prefsKey : '${_prefsKey}_$_usuarioId';
  String get _chaveGeradas =>
      _usuarioId.isEmpty ? _prefsGeradasKey : '${_prefsGeradasKey}_$_usuarioId';

  QuestaoRepository({SharedPreferences? prefs, ConteudoApi? api})
    : _prefs = prefs,
      _api = api ?? ConteudoApi() {
    // Inicializa o intervalo padrão para cada questão.
    for (var q in _questoes) {
      _intervals[q.id] = SrsInterval();
    }
    _carregarDoPrefs();
    _carregarGeradasDoPrefs();
  }

  /// Define o usuário ativo para isolar intervalos SRS e questões geradas.
  void definirUsuario(String usuarioId) {
    final id = usuarioId.trim().toLowerCase();
    if (id == _usuarioId) return;
    _usuarioId = id;
    _geradas.clear();
    _intervals.clear();
    for (final q in _questoes) {
      _intervals[q.id] = SrsInterval();
    }
    _carregarDoPrefs();
    _carregarGeradasDoPrefs();
  }

  void _carregarGeradasDoPrefs() {
    final raw = _prefs?.getString(_chaveGeradas);
    if (raw == null || raw.isEmpty) return;
    try {
      final lista = jsonDecode(raw);
      if (lista is! List) return;
      for (final item in lista.whereType<Map>()) {
        final questao = QuestaoSimulado.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (questao.id.isEmpty) continue;
        _geradas.add(questao);
        _intervals.putIfAbsent(questao.id, SrsInterval.new);
      }
    } catch (_) {}
  }

  /// Adiciona (ou substitui, pelo id) questões geradas automaticamente.
  void adicionarGeradas(List<QuestaoSimulado> novas) {
    final temas = novas
        .map((q) => GeradorConteudoService.prefixoDoTema(q.id))
        .toSet();
    _geradas
      ..removeWhere(
        (q) => temas.contains(GeradorConteudoService.prefixoDoTema(q.id)),
      )
      ..addAll(novas);
    for (final questao in novas) {
      _intervals.putIfAbsent(questao.id, SrsInterval.new);
    }
    _prefs?.setString(
      _chaveGeradas,
      jsonEncode(_geradas.map((q) => q.toJson()).toList()),
    );
  }

  bool get hasCachedQuestions => _carregado && _questoes.isNotEmpty;

  /// Busca questões da tabela documentada `questoes_simulado` e conserva
  /// a resposta em memória durante a sessão.
  Future<List<QuestaoSimulado>> carregar({bool atualizar = false}) {
    if (_carregamento != null) return _carregamento!;
    if (!atualizar && _remotoCarregado) return Future.value(getAll());
    final request = _api.listar('questoes_simulado').then((rows) {
      final questoes = rows
          .map(QuestaoSimulado.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
      // Preserva o cache válido quando o backend responde sem questões.
      if (questoes.isEmpty) {
        throw StateError('A API não retornou questões.');
      }
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
    final jsonStr = _prefs.getString(_chaveIntervalos);
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
    _prefs.setString(_chaveIntervalos, jsonStr);
  }

  /// Retorna todas as questões (conteúdo da API + geradas).
  List<QuestaoSimulado> getAll() {
    final ids = _questoes.map((q) => q.id).toSet();
    return List.unmodifiable([
      ..._questoes,
      ..._geradas.where((q) => !ids.contains(q.id)),
    ]);
  }

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
      sourceList = getAll().toList();
    }

    // Ordena priorizando quem já passou do prazo, e depois pelo tempo do proximo review
    sourceList.sort((a, b) {
      final intA = getInterval(a.id);
      final intB = getInterval(b.id);

      return SrsInterval.compararPrioridade(intA, intB, now);
    });

    return sourceList.take(limit).toList();
  }
}
