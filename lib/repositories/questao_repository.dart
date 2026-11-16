import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questao_simulado.dart';
import '../models/srs_interval.dart';

/// Repositório em memória para as questões de simulado e seus
/// estados de repetição espaçada. Na Etapa 3 será substituído por
/// integração com Supabase.
class QuestaoRepository {
  static const String _prefsKey = 'srs_questoes_intervals';

  final SharedPreferences? _prefs;

  // Lista fixa de questões (pode ser carregada de um JSON futuro).
  final List<QuestaoSimulado> _questoes = List.from(QuestaoSimulado.simuladoInicial);

  // Mapeamento id -> SrsInterval para cada questão.
  final Map<String, SrsInterval> _intervals = {};

  QuestaoRepository({SharedPreferences? prefs}) : _prefs = prefs {
    // Inicializa o intervalo padrão para cada questão.
    for (var q in _questoes) {
      _intervals[q.id] = SrsInterval();
    }
    _carregarDoPrefs();
  }

  void _carregarDoPrefs() {
    if (_prefs == null) return;
    final jsonStr = _prefs.getString(_prefsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        data.forEach((key, value) {
          if (value is Map) {
            _intervals[key] = SrsInterval.fromMap(Map<String, dynamic>.from(value));
          }
        });
      } catch (_) {}
    }
  }

  void _salvarNoPrefs() {
    if (_prefs == null) return;
    final jsonStr = jsonEncode(_intervals.map((k, v) => MapEntry(k, v.toMap())));
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
  List<QuestaoSimulado> getDueQuestionsBlock(int limit, {List<QuestaoSimulado>? questoesFiltro}) {
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
