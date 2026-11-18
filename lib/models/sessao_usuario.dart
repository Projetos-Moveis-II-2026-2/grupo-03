import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gerenciador de sessão do usuário atual no FocoDeck.
///
/// Mantém os dados da conta conectada (nome e e-mail) em memória
/// e notifica os ouvintes (HomeScreen, TelaPerfil, etc.) em caso de alteração.
enum EtapaRecuperacao { solicitar, redefinir, invalida }

class SessaoUsuario extends ChangeNotifier {
  SessaoUsuario._();

  static final SessaoUsuario instance = SessaoUsuario._();

  Session? _sessao;
  EtapaRecuperacao? _recuperacao;
  EtapaRecuperacao? get recuperacao => _recuperacao;
  String? _idRecuperacao;

  Future<void> solicitarRecuperacao(String email) async {
    final destino = kIsWeb
        ? Uri.base.resolve('?fluxo=recuperacao').toString()
        : null;
    await _auth.resetPasswordForEmail(email.trim(), redirectTo: destino);
  }

  Future<void> abrirRecuperacao(Uri retorno) async {
    try {
      final resposta = await _auth.getSessionFromUrl(retorno);
      if (!['passwordRecovery', 'recovery'].contains(resposta.redirectType)) {
        throw const AuthException('Link inválido');
      }
      _idRecuperacao = resposta.session.user.id;
      _recuperacao = EtapaRecuperacao.redefinir;
    } catch (_) {
      _recuperacao = EtapaRecuperacao.invalida;
    }
    _sincronizar();
  }

  Future<void> redefinirSenha(String senha) async {
    if (_idRecuperacao == null || _auth.currentUser?.id != _idRecuperacao) {
      throw const AuthException('Sessão de recuperação inválida');
    }
    await _auth.updateUser(UserAttributes(password: senha));
  }

  void concluirRecuperacao() {
    _idRecuperacao = null;
    _recuperacao = null;
    notifyListeners();
  }

  StreamSubscription<AuthState>? _eventos;
  GoTrueClient get _auth => Supabase.instance.client.auth;
  String? get id => _sessao?.user.id;
  String get email => _sessao?.user.email ?? '';
  String get nome =>
      _sessao?.user.userMetadata?['nome'] as String? ?? 'Estudante';
  bool get estaLogado => _sessao != null;

  /// Retorna o primeiro nome para saudações personalizadas (ex: "Olá, Emily! 👋")
  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isNotEmpty && partes.first.isNotEmpty
        ? partes.first
        : 'Estudante';
  }

  /// Retorna as iniciais do nome do usuário (ex: "EV" para Emily Vitória)
  String get iniciais {
    final partes = nome
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
    await prefs.remove('focodeck_usuarios');
    await prefs.remove('focodeck_sessao_ativa');
    await _eventos?.cancel();
    _sincronizar();
    _eventos = _auth.onAuthStateChange.listen(
      (_) => _sincronizar(),
      onError: (Object erro) => _sincronizar(),
    );
  }

  void _sincronizar() {
    _sessao = _auth.currentSession;
    if (_recuperacao == EtapaRecuperacao.redefinir && id != _idRecuperacao) {
      _recuperacao = EtapaRecuperacao.invalida;
      _idRecuperacao = null;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String senha}) async {
    final resposta = await _auth.signInWithPassword(
      email: email.trim(),
      password: senha,
    );
    if (resposta.session == null) {
      throw const AuthException('Sessão indisponível');
    }
    _sincronizar();
  }

  /// Cadastra no Auth sem armazenar a senha ou criar uma sessão local.
  /// Retorna false quando ainda é necessário confirmar o e-mail.
  Future<bool> cadastrarNoSupabase({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final resposta = await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: senha,
      data: {'nome': nome.trim()},
    );
    final sessao = resposta.session;
    if (sessao == null) return false;

    _sincronizar();
    return true;
  }

  Future<void> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    await _auth.updateUser(
      UserAttributes(
        data: {'nome': nome.trim()},
        email: email.trim() == this.email ? null : email.trim(),
      ),
    );
    _sincronizar();
  }

  Future<void> logout() async {
    try {
      await _auth.signOut(scope: SignOutScope.local);
    } finally {
      _sincronizar();
    }
  }
}
