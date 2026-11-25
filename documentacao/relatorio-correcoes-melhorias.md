# Relatório Técnico de Correções e Melhorias — FocoDeck

**Branch base:** `main` (`e52de9e`)  
**Plano detalhado:** [fix-improve.md](fix-improve.md)

---

## 1. Resumo Executivo

Após a integração das Etapas 3 e 4 na branch `main`, foi realizada uma auditoria técnica no código-fonte, nos fluxos de estudo e na configuração Android. As ações foram divididas em duas fases:

1. **Fase 1 — Correções (`FIX`):** estabilização de parsing JSON, sincronização da UI com dados remotos, ciclo de vida de controladores e permissões Android (**implementada e validada localmente**).
2. **Fase 2 — Melhorias (`IMPROVE`):** evolução de navegação, acessibilidade/fonética para TDAH, isolamento de cache por usuário e preparação de build `.aab` (**planejada, aguardando aprovação da Fase 1**).

---

## 2. Fase 1 — Correções Executadas (`FIX`)

### `fix-01` — Tolerância de Tipos no `fromJson`
- **Problema identificado:** `CardIngles.fromJson` e `QuestaoSimulado.fromJson` utilizavam casts diretos (`as String`, `as int`), sujeitos a falhas quando colunas da API retornavam valores numéricos ou listas genéricas.
- **Alteração aplicada:** conversão segura com `?.toString() ?? ''` nos campos textuais, mapeamento de listas com `.map((e) => e.toString()).toList()` e leitura de `indiceCorreto` aceitando `num` ou `String`.
- **Arquivos:** `lib/models/card_ingles.dart`, `lib/models/questao_simulado.dart`.

### `fix-02` — Atualização da Sessão de Estudo e Simulado com Carga Remota
- **Problema identificado:** como os repositórios iniciam com os 5 itens embarcados em cache, `TelaEstudoFlashcards` e `TelaSimuladoIngles` marcavam `_controllerInicializado = true` no `initState` e ignoravam os dados recém-chegados do servidor (inclusive após clicar em *"Tentar novamente"*). Além disso, o fallback de `TelaSimuladoIngles` não aplicava `_filtrarQuestoes`.
- **Alteração aplicada:** descarte seguro do controller anterior em `_inicializarController`, reinicialização automática do bloco quando a resposta remota chega antes de o usuário iniciar respostas (ou em atualização explícita) e aplicação consistente de `_filtrarQuestoes` no fallback.
- **Arquivos:** `lib/views/tela_estudo_flashcards.dart`, `lib/views/tela_simulado_ingles.dart`.

### `fix-03` — Decks e Home Reativos ao Repositório
- **Problema identificado:** `TelaDecksIngles` exibia baralhos padrão estáticos em vez das categorias vindas do repositório remoto, provocando falso aviso de *"Sem conexão"* quando os IDs/categorias divergiam. Na `HomeScreen`, os contadores não eram atualizados após a carga remota porque `FlashcardRepository` não notificava ouvintes nem era carregado na inicialização.
- **Alteração aplicada:**
  - `FlashcardRepository` passou a estender `ChangeNotifier`, expondo `hasRemoteData` e notificando ouvintes em `carregar()`, `saveInterval()` e `adicionarGerados()`.
  - `main.dart` e `lib/dev/main_preview.dart` passaram a usar `ChangeNotifierProvider<FlashcardRepository>`.
  - `TelaDecksIngles` passou a carregar o repositório no `initState` e agrupar dinamicamente as categorias remotas (preservando o gerador automático, os decks gerados e o fallback offline).
  - `HomeScreen` passou a disparar `carregar()` silenciosamente após o primeiro frame e reagir às atualizações do repositório.
- **Arquivos:** `lib/repositories/flashcard_repository.dart`, `lib/main.dart`, `lib/dev/main_preview.dart`, `lib/views/tela_decks_ingles.dart`, `lib/views/home_screen.dart`.

### `fix-04` — Ciclo de Vida no Perfil, Cadastro e Permissão Android
- **Problema identificado:** `TextEditingController`s criados em `TelaPerfil._abrirEdicao` não eram descartados; o `Navigator.pushReplacement` em `TelaCadastro._submit` concorria com a troca automática de `home` no `Consumer<SessaoUsuario>`; e o `AndroidManifest.xml` não declarava permissão de internet para builds de produção.
- **Alteração aplicada:** extração de `_EditarPerfilSheet` (`StatefulWidget` com `dispose()` dos controladores), ajuste da navegação pós-cadastro conforme `Navigator.canPop(context)` e inclusão de `<uses-permission android:name="android.permission.INTERNET"/>`.
- **Arquivos:** `lib/views/tela_perfil.dart`, `lib/views/tela_cadastro.dart`, `android/app/src/main/AndroidManifest.xml`.

### Validação da Fase 1
- **Análise estática (`flutter analyze`):** `No issues found!`
- **Testes automatizados (`flutter test`):** 69/69 testes passando.
- **Execução local com backend conteinerizado:** validada com PostgreSQL, PostgREST e GoTrue Auth via `lib/main.dart`.

---

## 3. Fase 2 — Melhorias Executadas (`IMPROVE`)

- **`improve-01` — Navegação e Menus Completos:** ativação dos botões *Estudos* e *Conquistas* na `NavigationBar` (`HomeScreen` e `TelaPerfil` via `lib/widgets/conquistas_dialog.dart`), correção do plural `1 dia seguido` e diálogos informativos nos itens *Notificações*, *Preferências* e *Ajuda e suporte* em `lib/views/tela_perfil.dart`.
- **`improve-02` — Fonética Simplificada e Responsividade TDAH:** `FlashcardWidget.formatarFoneticaAcessivel` converte fonética IPA (`/…/` ou `[…]`) para leitura simplificada em português mantendo fonéticas já adaptadas; altura mínima do `FlashcardWidget` adaptativa (`240.0` a `340.0` conforme altura da tela); estatísticas do Perfil responsivas com `LayoutBuilder` + `Wrap` para larguras estreitas ou escalas de fonte ampliadas.
- **`improve-03` — Isolamento de Cache por Usuário e Preview:** `FlashcardRepository` e `QuestaoRepository` segmentam chaves de `SharedPreferences` por UUID do usuário (`definirUsuario`), conectados ao `SessaoUsuario` no `main.dart` via `ProxyProvider`; `lib/dev/main_preview.dart` atualizado com `SessaoUsuario`.
- **`improve-04` — Configuração de Release Android (`.aab`):** `android:label="FocoDeck"` em `AndroidManifest.xml`, `applicationId = "br.edu.focodeck.app"` e suporte condicional a `android/key.properties` em `android/app/build.gradle.kts`.
- **`improve-05` — Sistema de Conquistas Focado em Reconhecimento Positivo (TDAH):** adição dos marcos permanentes de esforço acumulado (`word_collector`, `consistent_mind`, `deep_focus`), registro permanente das conquistas surpresa e das expressões culturais em inglês (`ProgressoEstudo.expressoesAprendidas`), progresso visual até os próximos marcos em `conquistas_dialog.dart` e destaque secundário para a ofensiva.
