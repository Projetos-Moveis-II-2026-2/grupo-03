# IMPROVE 02 — Fonética Simplificada para TDAH e Responsividade Fina

## Objetivo
Manter consistência pedagógica para TDAH nos decks gerados automaticamente e garantir conforto visual em telas pequenas ou com fontes de acessibilidade ampliadas.

## Arquivos
- `lib/services/vocabulario_api.dart`
- `lib/widgets/flashcard_widget.dart`
- `lib/views/tela_perfil.dart`

## Ações
1. Adaptar a fonética obtida em `VocabularioApi` para notação simplificada acessível (ou sinalização clara), evitando o atrito cognitivo de símbolos IPA puros.
2. Ajustar `FlashcardWidget` para adaptar a altura mínima conforme o tamanho da tela (`MediaQuery`), evitando rolagem excessiva em celulares menores.
3. Melhorar o comportamento das 3 colunas de estatísticas em `TelaPerfil` para escalas de fonte maiores (`textScaler`).
