import 'package:flutter/material.dart';
import '../models/card_ingles.dart';
import '../repositories/flashcard_repository.dart';
import '../widgets/flashcard_widget.dart';

/// Controlador que gerencia a sessão de Flashcards
/// com base no algoritmo SRS em blocos curtos.
class FlashcardController extends ChangeNotifier {
  final FlashcardRepository _repository;
  
  // Limite de cartas por bloco (micro-learning para TDAH)
  static const int maxCardsPerBlock = 5;
  
  List<CardIngles> _filaCards = [];
  int _currentIndex = 0;
  
  // Métricas do bloco atual
  int _cardsRevisadosComSucesso = 0;
  int _cardsParaRepetir = 0;

  FlashcardController(this._repository) {
    _initBlock();
  }

  void _initBlock() {
    _filaCards = _repository.getDueCardsBlock(maxCardsPerBlock);
    _currentIndex = 0;
    _cardsRevisadosComSucesso = 0;
    _cardsParaRepetir = 0;
    notifyListeners();
  }

  /// Retorna o cartão atual ou null se o bloco acabou
  CardIngles? get currentCard {
    if (_currentIndex < _filaCards.length) {
      return _filaCards[_currentIndex];
    }
    return null;
  }
  
  int get currentIndex => _currentIndex;
  bool get isFinished => _currentIndex >= _filaCards.length;
  int get totalCards => _filaCards.length;
  int get cardsRevisadosComSucesso => _cardsRevisadosComSucesso;
  int get cardsParaRepetir => _cardsParaRepetir;

  /// Processa a autoavaliação (Rever, Bom, Fácil) do usuário
  void processarAutoavaliacao(NivelAutoavaliacao nivel) {
    final current = currentCard;
    if (current == null) return;

    // Lógica para SRS
    bool correct;
    bool isEasy = false;

    if (nivel == NivelAutoavaliacao.rever) {
      correct = false;
      _cardsParaRepetir++;
      // Reinsere o card no final da fila (fixação imediata no mesmo bloco)
      _filaCards.add(current);
    } else {
      correct = true;
      _cardsRevisadosComSucesso++;
      if (nivel == NivelAutoavaliacao.facil) {
        isEasy = true;
      }
    }
    
    // Obter o intervalo atual e atualiza
    final interval = _repository.getInterval(current.id);
    interval.update(correct, isEasy: isEasy);
    _repository.saveInterval(current.id, interval);
    
    _currentIndex++;
    notifyListeners();
  }
  
  void restartBlock() {
    _initBlock();
  }
}
