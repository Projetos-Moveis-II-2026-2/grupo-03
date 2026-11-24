# FIX 03 — Decks e Home Reativos ao Repositório

## Problema
- `TelaDecksIngles` exibe os baralhos padrão estáticos (`DeckTema.baralhos`) sem carregar o catálogo do Supabase, gerando falso aviso de `"Sem conexão"` quando os IDs/categorias remotos diferem dos mocks locais.
- `FlashcardRepository` não notifica ouvintes e `HomeScreen` não dispara o carregamento do catálogo ao iniciar, mantendo os contadores de pendentes/dominadas presos aos 5 cartões locais.

## Arquivos
- `lib/repositories/flashcard_repository.dart`
- `lib/main.dart`
- `lib/dev/main_preview.dart`
- `lib/views/tela_decks_ingles.dart`
- `lib/views/home_screen.dart`

## Ações
1. Tornar `FlashcardRepository` um `ChangeNotifier` com getter `hasRemoteData`, disparando `notifyListeners()` ao concluir `carregar()` e em `saveInterval()`.
2. Trocar `Provider<FlashcardRepository>` por `ChangeNotifierProvider<FlashcardRepository>` em `main.dart` e `main_preview.dart`.
3. Em `TelaDecksIngles`, disparar `_repo.carregar()` no `initState` e agrupar dinamicamente os cartões remotos por categoria (preservando os decks gerados em `cardsGerados` e usando `DeckTema.baralhos` apenas como fallback offline).
4. Em `HomeScreen`, disparar `carregar()` silenciosamente após o primeiro frame quando `!repo.hasRemoteData` e ouvir o repositório para atualizar as métricas do dashboard.
