# IMPROVE 03 — Isolamento de Cache por Usuário e Preview Completo

## Objetivo
Evitar que dados locais de revisão espaçada e decks gerados sejam compartilhados entre contas diferentes no mesmo dispositivo e completar o modo preview local.

## Arquivos
- `lib/repositories/flashcard_repository.dart`
- `lib/repositories/questao_repository.dart`
- `lib/dev/main_preview.dart`

## Ações
1. Isolar as chaves de `SharedPreferences` (`srs_flashcards_intervals`, `srs_questoes_intervals`, `focodeck_cards_gerados`, `focodeck_questoes_geradas`) pelo identificador do usuário autenticado (`SessaoUsuario.id`).
2. Registrar `SessaoUsuario` no `MultiProvider` de `lib/dev/main_preview.dart` para que a aba de Perfil funcione no preview local.
