import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progresso_estudo.dart';

/// Contrato de persistência do progresso do estudante.
///
/// A implementação atual é local ([ProgressoRepositoryLocal]). Na Etapa 3,
/// basta criar uma implementação remota (ex.: `ProgressoRepositorySupabase`)
/// que respeite esta interface e trocá-la no `main.dart` — o
/// `ProgressoController` e as telas não precisam ser alterados.
abstract class ProgressoRepository {
  /// Carrega o progresso do usuário. Retorna um progresso vazio se não houver.
  Future<ProgressoEstudo> carregar(String usuarioId);

  /// Grava o progresso do usuário.
  Future<void> salvar(String usuarioId, ProgressoEstudo progresso);
}

/// Persistência local via SharedPreferences (uma chave por usuário).
///
/// Sem `prefs` (ex.: em testes), mantém os dados apenas em memória.
class ProgressoRepositoryLocal implements ProgressoRepository {
  static const String _prefixoChave = 'focodeck_progresso_';

  final SharedPreferences? _prefs;
  final Map<String, String> _memoria = {};

  ProgressoRepositoryLocal({SharedPreferences? prefs}) : _prefs = prefs;

  String _chave(String usuarioId) =>
      '$_prefixoChave${usuarioId.trim().toLowerCase()}';

  @override
  Future<ProgressoEstudo> carregar(String usuarioId) async {
    final chave = _chave(usuarioId);
    final raw = _prefs?.getString(chave) ?? _memoria[chave];
    if (raw == null || raw.isEmpty) return ProgressoEstudo();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ProgressoEstudo.fromJson(decoded);
      }
    } catch (_) {
      // JSON inválido: recomeça com progresso vazio em vez de quebrar o app.
    }
    return ProgressoEstudo();
  }

  @override
  Future<void> salvar(String usuarioId, ProgressoEstudo progresso) async {
    final chave = _chave(usuarioId);
    final raw = jsonEncode(progresso.toJson());
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(chave, raw);
    } else {
      _memoria[chave] = raw;
    }
  }
}
