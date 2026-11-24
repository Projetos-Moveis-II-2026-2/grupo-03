# Plano de Correções e Melhorias — FocoDeck

> **Relatório consolidado:** [relatorio-correcoes-melhorias.md](relatorio-correcoes-melhorias.md)

Este documento centraliza a divisão em duas fases para estabilização da branch `main` após a integração das Etapas 3 e 4:

- **Fase 1 — Correções (`FIX`):** Resolução de bugs de sincronização, parsing, ciclo de vida e permissões. **Deve ser validada localmente antes de avançar para a Fase 2.**
- **Fase 2 — Melhorias (`IMPROVE`):** Evoluções de experiência para o público TDAH, responsividade fina, navegação e empacotamento final (`.aab`).

---

## Fase 1 — Correções (`FIX`)

| ID | Título | Arquivos Alvo | Especificação | Status |
| :---: | :--- | :--- | :--- | :---: |
| `fix-01` | Tolerância de tipos no `fromJson` | `card_ingles.dart`, `questao_simulado.dart` | [fix-01-models-json.md](fix-improve/fix-01-models-json.md) | Concluído |
| `fix-02` | Atualização da sessão de estudo e simulado | `tela_estudo_flashcards.dart`, `tela_simulado_ingles.dart` | [fix-02-sessao-estudo-remota.md](fix-improve/fix-02-sessao-estudo-remota.md) | Concluído |
| `fix-03` | Decks e Home reativos ao repositório | `flashcard_repository.dart`, `main.dart`, `main_preview.dart`, `tela_decks_ingles.dart`, `home_screen.dart` | [fix-03-decks-e-home-dinamicos.md](fix-improve/fix-03-decks-e-home-dinamicos.md) | Concluído |
| `fix-04` | Ciclo de vida no Perfil e permissão Android | `tela_perfil.dart`, `tela_cadastro.dart`, `AndroidManifest.xml` | [fix-04-perfil-e-android-manifest.md](fix-improve/fix-04-perfil-e-android-manifest.md) | Concluído |

---

## Fase 2 — Melhorias (`IMPROVE`)

| ID | Título | Arquivos Alvo | Especificação | Status |
| :---: | :--- | :--- | :--- | :---: |
| `improve-01` | Ações completas de navegação e menus | `home_screen.dart`, `tela_perfil.dart`, `conquistas_dialog.dart` | [improve-01-navegacao-e-menus.md](fix-improve/improve-01-navegacao-e-menus.md) | Concluído |
| `improve-02` | Fonética simplificada e responsividade TDAH | `flashcard_widget.dart`, `tela_perfil.dart` | [improve-02-tdah-fonetica-e-responsividade.md](fix-improve/improve-02-tdah-fonetica-e-responsividade.md) | Concluído |
| `improve-03` | Isolamento de cache por usuário e preview | `flashcard_repository.dart`, `questao_repository.dart`, `main.dart`, `main_preview.dart` | [improve-03-isolamento-por-usuario-e-preview.md](fix-improve/improve-03-isolamento-por-usuario-e-preview.md) | Concluído |
| `improve-04` | Configuração de release Android (`.aab`) | `build.gradle.kts`, `AndroidManifest.xml` | [improve-04-release-android-aab.md](fix-improve/improve-04-release-android-aab.md) | Concluído |
| `improve-05` | Conquistas focadas em esforço acumulado (TDAH) | `recompensa_service.dart`, `progresso_estudo.dart`, `progresso_controller.dart`, `conquistas_dialog.dart` | [improve-05-conquistas-e-reconhecimento.md](fix-improve/improve-05-conquistas-e-reconhecimento.md) | Concluído |
