import 'package:flutter/foundation.dart';

/// Gerenciador de sessão do usuário atual no FocoDeck.
///
/// Mantém os dados da conta conectada (nome e e-mail) em memória
/// e notifica os ouvintes (HomeScreen, TelaPerfil, etc.) em caso de alteração.
class SessaoUsuario extends ChangeNotifier {
  SessaoUsuario._();

  static final SessaoUsuario instance = SessaoUsuario._();

  // Banco de usuários cadastrados em memória
  final Map<String, String> _usuariosCadastrados = {
    'emily@email.com': 'Emily Vitória',
  };

  String _nome = 'Emily Vitória';
  String _email = 'emily@email.com';

  String get nome => _nome;
  String get email => _email;

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

  /// Realiza login do usuário com base no e-mail informado
  void login({required String email}) {
    final emailFormatado = email.trim().toLowerCase();
    _email = email.trim();

    if (_usuariosCadastrados.containsKey(emailFormatado)) {
      _nome = _usuariosCadastrados[emailFormatado]!;
    } else {
      // Se for um novo e-mail não registrado previamente, deriva o nome do usuário
      final prefixo = email.split('@').first;
      final partes = prefixo.split(RegExp(r'[._\-]'));
      final derivado = partes
          .where((p) => p.isNotEmpty)
          .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
          .join(' ');
      _nome = derivado.isNotEmpty ? derivado : 'Estudante';
      _usuariosCadastrados[emailFormatado] = _nome;
    }
    notifyListeners();
  }

  /// Registra um novo usuário a partir do formulário de cadastro
  void cadastrar({required String nome, required String email}) {
    final emailFormatado = email.trim().toLowerCase();
    _nome = nome.trim();
    _email = email.trim();
    _usuariosCadastrados[emailFormatado] = _nome;
    notifyListeners();
  }

  /// Atualiza o perfil (nome e e-mail) do usuário conectado
  void atualizarPerfil({required String nome, required String email}) {
    final emailAntigo = _email.trim().toLowerCase();
    final emailNovo = email.trim().toLowerCase();

    if (emailAntigo != emailNovo) {
      _usuariosCadastrados.remove(emailAntigo);
    }
    _nome = nome.trim();
    _email = email.trim();
    _usuariosCadastrados[emailNovo] = _nome;
    notifyListeners();
  }

  /// Finaliza a sessão do usuário
  void logout() {
    _nome = 'Estudante';
    _email = '';
    notifyListeners();
  }
}
