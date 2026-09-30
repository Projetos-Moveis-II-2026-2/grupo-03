import 'package:flutter/material.dart';
import '../models/questao_simulado.dart';
import '../repositories/questao_repository.dart';

/// Controlador que gerencia a sessão de estudos (Simulado/Quiz) 
/// com base no algoritmo SRS em blocos curtos.
class SrsController extends ChangeNotifier {
  final QuestaoRepository _repository;
  
  // Limite de questões por bloco (micro-learning para TDAH)
  static const int maxQuestionsPerBlock = 5;
  
  List<QuestaoSimulado> _blockQuestions = [];
  int _currentIndex = 0;
  
  // Métricas do bloco atual
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  SrsController(this._repository) {
    _initBlock();
  }

  /// Inicializa um novo bloco de estudos buscando as questões mais urgentes
  void _initBlock() {
    _blockQuestions = _repository.getDueQuestionsBlock(maxQuestionsPerBlock);
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
  
  bool get isFinished => _currentIndex >= _blockQuestions.length;
  int get totalQuestions => _blockQuestions.length;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  
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
    
    _currentIndex++;
    notifyListeners();
  }
  
  /// Inicia um novo bloco com a próxima fila de questões
  void restartBlock() {
    _initBlock();
  }
}
