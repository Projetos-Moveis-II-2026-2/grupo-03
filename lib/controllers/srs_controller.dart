import 'package:flutter/material.dart';
import '../controllers/progresso_controller.dart';
import '../models/questao_simulado.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/questao_repository.dart';
import '../services/recomendacao_service.dart';

/// Controlador que gerencia a sessão de estudos (Simulado/Quiz) 
/// com base no algoritmo SRS em blocos curtos.
class SrsController extends ChangeNotifier {
  final QuestaoRepository _repository;
  final List<QuestaoSimulado>? questoesCustomizadas;

  /// Histórico de erros por palavra (opcional). Quando presente, o bloco
  /// é montado pela recomendação adaptativa e os erros do simulado são
  /// registrados na palavra correspondente (`QuestaoSimulado.cardId`).
  final ProgressoController? progresso;

  /// Usado para consultar o SRS das palavras e seus termos (opcional).
  final FlashcardRepository? flashcards;

  final RecomendacaoService _recomendacao;
  bool _blocoAdaptativo = false;
  List<String> _cardsEmFoco = const [];

  // Limite de questões por bloco (micro-learning para TDAH)
  static const int maxQuestionsPerBlock = 5;
  
  List<QuestaoSimulado> _blockQuestions = [];
  int _currentIndex = 0;
  
  // Métricas do bloco atual
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  SrsController(
    this._repository, {
    this.questoesCustomizadas,
    this.progresso,
    this.flashcards,
    RecomendacaoService recomendacao = const RecomendacaoService(),
  }) : _recomendacao = recomendacao {
    _initBlock();
  }

  /// Inicializa um novo bloco de estudos buscando as questões mais urgentes
  /// e, havendo histórico, priorizando os pontos fracos do estudante.
  void _initBlock() {
    final progressoAtual = progresso;
    if (progressoAtual == null) {
      _blockQuestions = _repository.getDueQuestionsBlock(
        maxQuestionsPerBlock,
        questoesFiltro: questoesCustomizadas,
      );
      _blocoAdaptativo = false;
      _cardsEmFoco = const [];
    } else {
      // Todas as candidatas na ordem do SRS; a recomendação escolhe o bloco.
      final candidatas = _repository.getDueQuestionsBlock(
        1 << 30,
        questoesFiltro: questoesCustomizadas,
      );
      final bloco = _recomendacao.montarBloco(
        candidatas: candidatas,
        limite: maxQuestionsPerBlock,
        errosPorCard: progressoAtual.errosPorCard,
        intervaloDoCard: flashcards?.getInterval,
      );
      _blockQuestions = bloco.questoes;
      _blocoAdaptativo = bloco.adaptativo;
      _cardsEmFoco = bloco.cardsEmFoco;
    }
    _currentIndex = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    notifyListeners();
  }

  /// Retorna a questão atual ou null se o bloco acabou
  QuestaoSimulado? get currentQuestion {
    if (_currentIndex < _blockQuestions.length) {
      return _blockQuestions[_currentIndex];
    }
    return null;
  }
  
  int get currentIndex => _currentIndex;
  bool get isFinished => _currentIndex >= _blockQuestions.length;
  int get totalQuestions => _blockQuestions.length;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;

  /// Indica se o bloco atual foi montado com foco nos pontos fracos.
  bool get blocoAdaptativo => _blocoAdaptativo;

  /// Termos em inglês das palavras em foco no bloco adaptativo.
  List<String> get termosEmFoco {
    final cards = flashcards?.getAll() ?? const [];
    return [
      for (final id in _cardsEmFoco)
        for (final card in cards)
          if (card.id == id) card.termo,
    ];
  }

  /// Taxa de acerto do bloco em porcentagem (0 - 100)
  double get successRate => totalQuestions > 0 ? (_correctAnswers / totalQuestions) * 100 : 0.0;

  /// Processa a resposta selecionada pelo usuário
  void processAnswer(int selectedIndex) {
    final currentQ = currentQuestion;
    if (currentQ == null) return;

    final isCorrect = selectedIndex == currentQ.indiceCorreto;
    
    if (isCorrect) {
      _correctAnswers++;
    } else {
      _wrongAnswers++;
    }
    
    // Obter o intervalo atual e atualiza
    final interval = _repository.getInterval(currentQ.id);
    interval.update(isCorrect);
    _repository.saveInterval(currentQ.id, interval);

    // Alimenta o histórico de pontos fracos da palavra avaliada
    final cardId = currentQ.cardId;
    if (cardId != null) {
      if (isCorrect) {
        progresso?.registrarAcerto(cardId);
      } else {
        progresso?.registrarErro(cardId);
      }
    }

    _currentIndex++;
    notifyListeners();
  }
  
  /// Inicia um novo bloco com a próxima fila de questões
  void restartBlock() {
    _initBlock();
  }
}
