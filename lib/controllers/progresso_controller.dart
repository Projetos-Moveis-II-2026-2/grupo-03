import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/progresso_estudo.dart';
import '../repositories/progresso_repository.dart';

/// Controlador das métricas de estudo (ofensiva, minutos, meta diária,
/// taxa de acerto e histórico de erros por palavra).
///
/// Alimenta o dashboard da HomeScreen/TelaPerfil, a gamificação leve e a
/// recomendação adaptativa dos simulados. A persistência é delegada a um
/// [ProgressoRepository] (local agora, remoto na Etapa 3).
class ProgressoController extends ChangeNotifier {
  /// Revisões por dia para cumprir a meta (= 1 bloco curto de 5 itens).
  static const int metaDiaria = 5;

  /// Dias sem estudo tolerados sem perder a ofensiva (ofensiva flexível).
  /// Ex.: estudou segunda, pulou terça, voltou quarta → ofensiva continua.
  static const int diasDeTolerancia = 1;

  final ProgressoRepository _repository;
  final DateTime Function() _agora;

  ProgressoEstudo _progresso = ProgressoEstudo();
  String? _usuarioId;

  ProgressoController(this._repository, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  /// Instância vazia usada quando a tela é montada sem Provider (ex.: testes).
  static final ProgressoController _semProvider = ProgressoController(
    ProgressoRepositoryLocal(),
  );

  /// Obtém o controller do Provider, com fallback seguro (mesmo padrão
  /// de `SessaoUsuario.of`).
  static ProgressoController of(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<ProgressoController>(context, listen: listen);
    } on ProviderNotFoundException {
      return _semProvider;
    }
  }

  String? get usuarioId => _usuarioId;

  /// Chave estável do progresso: o UUID do Supabase Auth, que não muda
  /// quando o estudante troca o e-mail no Perfil. Usa o e-mail apenas como
  /// alternativa quando ainda não há UUID (ex.: sessão local em testes).
  static String chaveDoUsuario({String? id, required String email}) =>
      (id != null && id.trim().isNotEmpty) ? id.trim() : email;

  /// Carrega o progresso do usuário informado (chamado ao logar/trocar conta).
  Future<void> carregarUsuario(String usuarioId) async {
    final id = usuarioId.trim().toLowerCase();
    if (id == _usuarioId) return;
    _usuarioId = id;
    if (id.isEmpty) {
      _progresso = ProgressoEstudo();
      // Adia a notificação: este método é chamado pelo ProxyProvider
      // durante o build, onde notifyListeners síncrono não é permitido.
      await Future<void>.value();
      if (_usuarioId == id) notifyListeners();
      return;
    }
    final carregado = await _repository.carregar(id);
    // Evita sobrescrever se o usuário mudou durante o carregamento.
    if (_usuarioId != id) return;
    _progresso = carregado;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Leitura das métricas
  // ---------------------------------------------------------------------------

  DateTime get _hoje => _soData(_agora());

  static DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _diasEntre(DateTime de, DateTime ate) =>
      _soData(ate).difference(_soData(de)).inDays;

  /// Ofensiva exibida. Se o estudante passou do limite de tolerância sem
  /// estudar, mostra 0 (sem punição: ela recomeça no próximo bloco).
  int get ofensiva {
    final ultimo = _progresso.ultimoDiaEstudo;
    if (ultimo == null) return 0;
    if (_diasEntre(ultimo, _hoje) > diasDeTolerancia + 1) return 0;
    return _progresso.ofensivaAtual;
  }

  int get maiorOfensiva => _progresso.maiorOfensiva;

  bool get estudouHoje {
    final ultimo = _progresso.ultimoDiaEstudo;
    return ultimo != null && _diasEntre(ultimo, _hoje) == 0;
  }

  int get minutosEstudados => (_progresso.segundosEstudados / 60).round();

  int get blocosConcluidos => _progresso.blocosConcluidos;

  /// Revisões de hoje (zera automaticamente na virada do dia).
  int get revisoesHoje {
    final data = _progresso.dataRevisoesHoje;
    if (data == null || _diasEntre(data, _hoje) != 0) return 0;
    return _progresso.revisoesHoje;
  }

  /// Progresso da meta diária entre 0.0 e 1.0.
  double get progressoMetaDiaria =>
      (revisoesHoje / metaDiaria).clamp(0.0, 1.0).toDouble();

  bool get metaDiariaBatida => revisoesHoje >= metaDiaria;

  /// Taxa de acerto geral (0 a 100).
  double get taxaAcerto => _progresso.respostasTotais == 0
      ? 0
      : _progresso.acertosTotais / _progresso.respostasTotais * 100;

  Map<String, int> get errosPorCard =>
      Map.unmodifiable(_progresso.errosPorCard);

  int errosDoCard(String cardId) => _progresso.errosPorCard[cardId] ?? 0;

  List<String> get conquistas => List.unmodifiable(_progresso.conquistas);

  List<String> get expressoesAprendidas =>
      List.unmodifiable(_progresso.expressoesAprendidas);

  /// Cópia somente leitura do progresso (útil para serviços e testes).
  ProgressoEstudo get progresso =>
      ProgressoEstudo.fromJson(_progresso.toJson());

  // ---------------------------------------------------------------------------
  // Registro de eventos
  // ---------------------------------------------------------------------------

  /// Registra que a palavra foi marcada como "Rever" ou errada no simulado.
  void registrarErro(String cardId) {
    _progresso.errosPorCard[cardId] = errosDoCard(cardId) + 1;
    _salvar();
  }

  /// Registra um acerto: reduz gradualmente o peso de erro da palavra,
  /// para que a recomendação adaptativa acompanhe a evolução do estudante.
  void registrarAcerto(String cardId) {
    final erros = errosDoCard(cardId);
    if (erros <= 0) return;
    if (erros == 1) {
      _progresso.errosPorCard.remove(cardId);
    } else {
      _progresso.errosPorCard[cardId] = erros - 1;
    }
    _salvar();
  }

  /// Registra a conclusão de um bloco curto de estudo.
  ///
  /// - [duracao]: tempo efetivo do bloco (medido por Stopwatch na tela).
  /// - [acertos]/[total]: respostas corretas e total de respostas do bloco.
  void registrarBlocoConcluido({
    required Duration duracao,
    required int acertos,
    required int total,
  }) {
    if (total <= 0) return;
    final hoje = _hoje;

    _atualizarOfensiva(hoje);

    _progresso.segundosEstudados += duracao.inSeconds;
    _progresso.blocosConcluidos += 1;

    final dataRevisoes = _progresso.dataRevisoesHoje;
    if (dataRevisoes == null || _diasEntre(dataRevisoes, hoje) != 0) {
      _progresso.revisoesHoje = 0;
      _progresso.dataRevisoesHoje = hoje;
    }
    _progresso.revisoesHoje += total;

    _progresso.acertosTotais += acertos.clamp(0, total);
    _progresso.respostasTotais += total;

    _salvar();
  }

  /// Registra uma conquista leve (ignorada se já obtida).
  /// Retorna `true` se a conquista é nova.
  bool registrarConquista(String conquistaId) {
    if (_progresso.conquistas.contains(conquistaId)) return false;
    _progresso.conquistas.add(conquistaId);
    _salvar();
    return true;
  }

  /// Registra uma expressão cultural aprendida (ignorada se já colecionada).
  void registrarExpressao(String expressaoId) {
    if (_progresso.expressoesAprendidas.contains(expressaoId)) return;
    _progresso.expressoesAprendidas.add(expressaoId);
    _salvar();
  }

  void _atualizarOfensiva(DateTime hoje) {
    final ultimo = _progresso.ultimoDiaEstudo;
    if (ultimo == null) {
      _progresso.ofensivaAtual = 1;
    } else {
      final dias = _diasEntre(ultimo, hoje);
      if (dias <= 0) {
        // Já estudou hoje: mantém a ofensiva.
        if (_progresso.ofensivaAtual == 0) _progresso.ofensivaAtual = 1;
      } else if (dias <= diasDeTolerancia + 1) {
        _progresso.ofensivaAtual += 1;
      } else {
        // Recomeça sem penalidade além de reiniciar a contagem.
        _progresso.ofensivaAtual = 1;
      }
    }
    _progresso.ultimoDiaEstudo = hoje;
    if (_progresso.ofensivaAtual > _progresso.maiorOfensiva) {
      _progresso.maiorOfensiva = _progresso.ofensivaAtual;
    }
  }

  void _salvar() {
    notifyListeners();
    final id = _usuarioId;
    if (id == null || id.isEmpty) return;
    _repository.salvar(id, _progresso);
  }
}
