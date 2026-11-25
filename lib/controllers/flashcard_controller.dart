import 'package:flutter/material.dart';
import '../models/card_ingles.dart';
import '../models/srs_interval.dart';
import '../models/nivel_autoavaliacao.dart';
import '../controllers/progresso_controller.dart';
import '../repositories/flashcard_repository.dart';

/// Controlador que gerencia a sessão de Flashcards
/// com base no algoritmo SRS em blocos curtos.
class FlashcardController extends ChangeNotifier {
  final FlashcardRepository _repository;
  final List<CardIngles>? cardsCustomizados;

  /// Registra erros/acertos por palavra para a recomendação adaptativa.
  /// Opcional para manter o controller testável de forma isolada.
  final ProgressoController? progresso;
  
  // Limite de cartas por bloco (micro-learning para TDAH)
  static const int maxCardsPerBlock = 5;
  
  List<CardIngles> _filaCards = [];
  int _currentIndex = 0;
  
  // Métricas do bloco atual
  int _cardsRevisadosComSucesso = 0;
  int _cardsParaRepetir = 0;
  final Set<String> _idsParaRever = {};

  FlashcardController(
    this._repository, {
    this.cardsCustomizados,
    this.progresso,
  }) {
    _initBlock();
  }

  void _initBlock() {
    _filaCards = _repository.getDueCardsBlock(maxCardsPerBlock, cardsFiltro: cardsCustomizados);
    _currentIndex = 0;
    _cardsRevisadosComSucesso = 0;
    _cardsParaRepetir = 0;
    _idsParaRever.clear();
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

  Set<String> get _idsDoBloco => _filaCards.map((c) => c.id).toSet();

  /// Palavras do bloco marcadas como "Rever" ao menos uma vez.
  int get palavrasParaRever => _idsParaRever.length;

  /// Palavras do bloco (fora as "para rever") que ainda não estão dominadas.
  int get palavrasAprendendo => _contarEstado(EstadoPalavra.aprendendo);

  /// Palavras do bloco já dominadas segundo o repositório.
  int get palavrasDominadas => _contarEstado(EstadoPalavra.dominada);

  int _contarEstado(EstadoPalavra estado) => _idsDoBloco
      .difference(_idsParaRever)
      .where((id) => _repository.estadoDaPalavra(id) == estado)
      .length;

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
      _idsParaRever.add(current.id);
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

    // Histórico de pontos fracos ("Rever") por palavra
    if (correct) {
      progresso?.registrarAcerto(current.id);
    } else {
      progresso?.registrarErro(current.id);
    }
    
    _currentIndex++;
    notifyListeners();
  }
  
  void restartBlock() {
    _initBlock();
  }
}
