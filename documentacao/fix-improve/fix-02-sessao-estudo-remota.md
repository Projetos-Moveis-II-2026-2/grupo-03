# FIX 02 — Atualização da Sessão de Estudo e Simulado com Carga Remota

## Problema
`FlashcardRepository` e `QuestaoRepository` iniciam com os 5 itens embarcados em cache. Na primeira abertura de `TelaEstudoFlashcards` e `TelaSimuladoIngles`, `initState` marca `_controllerInicializado = true` com o conteúdo local, e a checagem `if (!_controllerInicializado)` impede atualizar o bloco ativo quando a resposta do Supabase chega (ou ao clicar em "Tentar novamente"). Além disso, o fallback de `TelaSimuladoIngles` não aplica `_filtrarQuestoes` quando `widget.questoes` está preenchido.

## Arquivos
- `lib/views/tela_estudo_flashcards.dart`
- `lib/views/tela_simulado_ingles.dart`

## Ações
1. Em `_inicializarController`, descartar a instância anterior de `_controller` quando `_controllerInicializado` já for `true`, resetando o cronômetro e o estado do bloco.
2. Quando `carregar(atualizar: atualizar)` retornar dados remotos válidos e o usuário ainda não tiver respondido nenhum item no bloco atual (ou quando `atualizar == true`), reinicializar o controller com os itens filtrados do servidor.
3. No `catch` de `TelaSimuladoIngles._carregarQuestoes`, aplicar `_filtrarQuestoes(cache)` antes de inicializar o fallback.
