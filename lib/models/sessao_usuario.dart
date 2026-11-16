import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerenciador de sessão do usuário atual no FocoDeck.
///
/// Mantém os dados da conta conectada (nome e e-mail) em memória
/// e notifica os ouvintes (HomeScreen, TelaPerfil, etc.) em caso de alteração.
class SessaoUsuario extends ChangeNotifier {
  SessaoUsuario._();

  static final SessaoUsuario instance = SessaoUsuario._();

  static const String _prefsUsuariosKey = 'focodeck_usuarios';
  static const String _prefsSessaoAtivaKey = 'focodeck_sessao_ativa';

  SharedPreferences? _prefs;

  // Banco de usuários cadastrados em memória
  final Map<String, Map<String, String>> _usuariosCadastrados = {
    'emily@email.com': {
      'nome': 'Emily Vitória',
      'senha': '123456',
    },
  };

  String _nome = 'Emily Vitória';
  String _email = 'emily@email.com';
  bool _estaLogado = false;
  bool _sessaoRestaurada = false;

  String get nome => _nome;
  String get email => _email;
  bool get estaLogado => _estaLogado;
  bool get sessaoRestaurada => _sessaoRestaurada;

  /// Retorna o primeiro nome para saudações personalizadas (ex: "Olá, Emily! 👋")
  String get primeiroNome {
    final partes = _nome.trim().split(RegExp(r'\s+'));
    return partes.isNotEmpty && partes.first.isNotEmpty
        ? partes.first
        : 'Estudante';
  }

  /// Retorna as iniciais do nome do usuário (ex: "EV" para Emily Vitória)
  String get iniciais {
    final partes = _nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'FD';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  static SessaoUsuario of(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<SessaoUsuario>(context, listen: listen);
    } on ProviderNotFoundException {
      return instance;
    }
  }

  Future<void> carregar(SharedPreferences prefs) async {
    _prefs = prefs;

    final rawUsuarios = _prefs?.getString(_prefsUsuariosKey);
    if (rawUsuarios != null && rawUsuarios.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUsuarios);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          _usuariosCadastrados.clear();
          for (final entry in decoded.entries) {
            if (entry.value is Map) {
              final dados = (entry.value as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              );
              _usuariosCadastrados[entry.key] = dados;
            }
          }
        }
      } catch (_) {
        // Mantém os usuários padrão em memória se o JSON for inválido
      }
    }

    if (_usuariosCadastrados.isEmpty) {
      _usuariosCadastrados['emily@email.com'] = {
        'nome': 'Emily Vitória',
        'senha': '123456',
      };
    }

    final emailAtivo =
        _prefs?.getString(_prefsSessaoAtivaKey)?.trim().toLowerCase();
    if (emailAtivo != null && _usuariosCadastrados.containsKey(emailAtivo)) {
      _email = emailAtivo;
      _nome = _usuariosCadastrados[emailAtivo]!['nome']!;
      _estaLogado = true;
      _sessaoRestaurada = true;
      notifyListeners();
    }
  }

  void _persistir() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(_prefsUsuariosKey, jsonEncode(_usuariosCadastrados));
    if (_estaLogado) {
      prefs.setString(_prefsSessaoAtivaKey, _email.trim().toLowerCase());
    } else {
      prefs.remove(_prefsSessaoAtivaKey);
    }
  }

  /// Realiza login do usuário com base no e-mail informado
  bool login({required String email, String? senha}) {
    final emailFormatado = email.trim().toLowerCase();
    if (!_usuariosCadastrados.containsKey(emailFormatado)) {
      return false;
    }

    if (senha != null) {
      final senhaArmazenada =
          _usuariosCadastrados[emailFormatado]!['senha'] ?? '';
      if (senhaArmazenada.isNotEmpty && senhaArmazenada != senha) {
        return false;
      }
    }

    _email = emailFormatado;
    _nome = _usuariosCadastrados[emailFormatado]!['nome']!;
    _estaLogado = true;
    _persistir();
    notifyListeners();
    return true;
  }

  /// Registra um novo usuário a partir do formulário de cadastro
  void cadastrar({
    required String nome,
    required String email,
    String senha = '',
  }) {
    final emailFormatado = email.trim().toLowerCase();
    _usuariosCadastrados[emailFormatado] = {
      'nome': nome.trim(),
      'senha': senha,
    };
    _nome = nome.trim();
    _email = email.trim();
    _estaLogado = true;
    _persistir();
    notifyListeners();
  }

  /// Atualiza o perfil (nome e e-mail) do usuário conectado
  void atualizarPerfil({required String nome, required String email}) {
    final emailAntigo = _email.trim().toLowerCase();
    final emailNovo = email.trim().toLowerCase();
    final senha = _usuariosCadastrados[emailAntigo]?['senha'] ?? '';

    if (emailAntigo != emailNovo) {
      _usuariosCadastrados.remove(emailAntigo);
    }
    _nome = nome.trim();
    _email = email.trim();
    _usuariosCadastrados[emailNovo] = {
      'nome': _nome,
      'senha': senha,
    };
    _persistir();
    notifyListeners();
  }

  /// Finaliza a sessão do usuário
  void logout() {
    _nome = 'Estudante';
    _email = '';
    _estaLogado = false;
    _sessaoRestaurada = false;
    _persistir();
    notifyListeners();
  }
}
