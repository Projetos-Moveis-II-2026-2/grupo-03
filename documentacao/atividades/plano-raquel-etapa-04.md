# Plano de Implementação — Raquel (Etapa 4)

**Frente:** Gamificação Leve, IA Adaptativa e Build Final (`.aab`)
**Fontes do requisito:** `divisao-atividades-equipe.pdf` (item 4) e `documentacao/atividades/etapa-04.md`
**Branch de trabalho:** `feature/gamificacao` (a partir da branch mais atualizada, após o merge do JP na `main`)

---

## 0. Matriz de Conformidade (requisito → entrega)

Use esta tabela para conferir se tudo o que foi pedido está coberto.

| # | Requisito (texto oficial) | Onde é atendido | Critério de "pronto" | Status |
|---|---|---|---|---|
| R1 | Sorteio de **micro-recompensas** ao concluir blocos curtos | `services/recompensa_service.dart` + telas de conclusão (Flashcards e Simulado) | Ao terminar um bloco, aparece uma recompensa sorteada; sem mensagens de punição | ☐ |
| R2 | Conectar a `HomeScreen` aos dados reais: **ofensiva** | `models/progresso_estudo.dart` + `controllers/progresso_controller.dart` | O card "🔥 X dias" reflete os dias estudados, não o texto fixo "7 dias" | ☐ |
| R3 | `HomeScreen` com dados reais: **minutos estudados** | Mesmo controller (cronômetro por bloco) | Os minutos aumentam após cada bloco concluído | ☐ |
| R4 | `HomeScreen` com dados reais: **palavras dominadas** | Cálculo a partir do `SrsInterval` dos cartões | O número muda quando um cartão atinge o critério de domínio | ☐ |
| R5 | (etapa-04.md) `TelaPerfil` também com métricas reais | `tela_perfil.dart` → `_estatisticas` | "4 dias / 320 XP" substituídos por valores reais | ☐ |
| R6 | **IA adaptativa**: simulados priorizam vocabulários com mais erros (`Rever`) | `services/recomendacao_service.dart` + `QuestaoRepository` | Uma questão ligada a uma palavra marcada "Rever" aparece antes das demais no próximo simulado | ☐ |
| R7 | `flutter analyze` **sem erros** | Projeto inteiro | Saída: `No issues found!` | ☐ |
| R8 | Gerar o **Android App Bundle (`.aab`)** | `android/app/build.gradle.kts` + `flutter build appbundle` | O arquivo `build/app/outputs/bundle/release/app-release.aab` foi gerado | ☐ |
| R9 | Conventional Commits, feitos com a própria conta | Histórico do Git | Commits `feat:`/`fix:`/`chore:` feitos com o usuário `raquelzis-sv` | ☐ |

Critérios de aceitação da etapa que dependem desta frente (`etapa-04.md`, §5):
- ☐ A gamificação é leve, motivadora e **não gera ansiedade nem culpa**.
- ☐ O estudante vê com clareza o seu progresso.
- ☐ O app compila em versão final estável para Android.

---

## 1. Ponto de partida (o que já existe no código)

| Item | Situação atual | Impacto na minha parte |
|---|---|---|
| `SrsInterval` (`lib/models/srs_interval.dart`) | Guarda `repetition`, `easeFactor`, `intervalDays` e `nextReview`. **Não conta erros.** | Para a IA, preciso de um histórico de erros por item. |
| `FlashcardController.processarAutoavaliacao` | Recebe `rever` / `bom` / `facil` e atualiza o SRS | É aqui que o "Rever" deve ser registrado como erro da palavra. |
| `SrsController.processAnswer` | Registra acerto ou erro da questão | Também deve registrar o erro da palavra ligada à questão. |
| `QuestaoSimulado` | **Não tem ligação com o cartão/palavra** (apenas `id`, `enunciado`, ...) | ⚠️ Bloqueante para a IA: falta um campo `cardId` (ver §3.1). |
| `HomeScreen` | Valores fixos: `'🔥 7 dias'`, `'3 de 5 revisões'`, `'12 flashcards'`, `'24'`, `'85%'` | Trocar todos por dados reais. |
| `TelaPerfil._estatisticas` | Valores fixos: `'4 dias'`, `'320 XP'` | Trocar por dados reais. |
| `main.dart` | Já usa `MultiProvider` com `SharedPreferences` | Registrar o novo `ProgressoController` aqui. |
| `android/app/build.gradle.kts` | `applicationId = "com.example.projeto_com_api"`, release assinado com **chave de debug** | Ajustar antes de gerar o `.aab`. |
| `AndroidManifest.xml` | `android:label="projeto_com_api"` | Renomear para `FocoDeck`. |

### Dependências com outras pessoas da equipe
- **JP:** o merge na `main` e a injeção de dependência via Provider precisam estar concluídos antes de eu começar o trabalho de base (§2). Combinar com ele a criação do campo `cardId` em `QuestaoSimulado`, já que ele cuida dos models e do `fromJson`/`toJson`.
- **Maria / Emily:** quando os repositórios passarem a ser assíncronos (Supabase), o meu `ProgressoController` deve continuar funcionando. Por isso ele só deve depender de `SharedPreferences` e das interfaces dos repositórios, e não de listas estáticas.
- **Ordem sugerida:** fazer tudo primeiro com persistência local. A sincronização remota fica com a Maria.

> ✅ **Decisão (17/11/2026): persistência local primeiro.** O progresso é salvo no `SharedPreferences` por meio de `ProgressoRepositoryLocal` (`lib/repositories/progresso_repository.dart`), que implementa a interface abstrata `ProgressoRepository` (`carregar` / `salvar`).
> **Para a Maria Luiza (Etapa 3):** basta criar `ProgressoRepositorySupabase implements ProgressoRepository` e trocar a instância em `main.dart` (linha `final progressoRepo = ProgressoRepositoryLocal(prefs: prefs);`). O `ProgressoController` e as telas não mudam. O formato dos dados é o `ProgressoEstudo.toJson()`.

---

## 2. Parte A — Base de dados de progresso (pré-requisito de R2 a R6)

### 2.1 Novo model: `lib/models/progresso_estudo.dart`
Classe pura e serializável que concentra as métricas do estudante.

```dart
class ProgressoEstudo {
  int ofensivaAtual;            // dias seguidos (com tolerância)
  int maiorOfensiva;
  DateTime? ultimoDiaEstudo;    // somente a data (sem hora)
  int segundosEstudados;        // total acumulado
  int blocosConcluidos;
  int revisoesHoje;             // para a "Meta diária"
  DateTime? dataRevisoesHoje;
  int acertosTotais;
  int respostasTotais;
  Map<String, int> errosPorCard; // cardId -> quantidade de "Rever"/erros
  List<String> conquistas;       // ids das recompensas já ganhas

  Map<String, dynamic> toJson();
  factory ProgressoEstudo.fromJson(Map<String, dynamic> json);
}
```

### 2.2 Novo controller: `lib/controllers/progresso_controller.dart`
Um `ChangeNotifier` que lê e grava o progresso no `SharedPreferences` (chave `focodeck_progresso_<email>`, para separar os dados de cada usuário).

Métodos públicos:
- `registrarBlocoConcluido({required Duration duracao, required int acertos, required int total})`
- `registrarErro(String cardId)` / `registrarAcerto(String cardId)` (o acerto reduz o contador de erros)
- Getters: `ofensiva`, `minutosEstudados`, `palavrasDominadas(FlashcardRepository)`, `taxaAcerto`, `revisoesHoje`, `metaDiaria` (5 revisões)

### 2.3 Regras de negócio (decidir e documentar)

| Métrica | Regra proposta | Justificativa (TDAH) |
|---|---|---|
| **Ofensiva flexível** | Estudou hoje → mantém. Estudou ontem **ou anteontem** → +1 ao estudar hoje. 2 ou mais dias sem estudar → recomeça em 1, **sem mensagem negativa**. | "Ofensivas flexíveis" evitam culpa por um dia perdido (`etapa-04.md`, §3.1). |
| **Minutos estudados** | Um `Stopwatch` mede cada bloco, do início até a tela de conclusão. O total é exibido em minutos (arredondado). | Medido de forma real e não estimado. |
| **Palavra dominada** | O `SrsInterval` do cartão tem `repetition >= 3` (ou `intervalDays >= 21`, escolher um critério). | Segue o próprio algoritmo SRS: após 3 acertos seguidos, a palavra já está na memória de longo prazo. |
| **Meta diária** | 5 revisões por dia (um bloco), zerando à meia-noite. | Coincide com `maxCardsPerBlock = 5`. |

### 2.4 Integração
- `main.dart`: adicionar `ChangeNotifierProvider<ProgressoController>` no `MultiProvider`.
- `FlashcardController` e `SrsController`: receber o `ProgressoController` (opcional, para não quebrar os testes do JP) e chamar `registrarErro`/`registrarAcerto` dentro de `processarAutoavaliacao`/`processAnswer`.
- `TelaEstudoFlashcards` e `TelaSimuladoIngles`: iniciar o `Stopwatch` no `initState` e chamar `registrarBlocoConcluido` quando `isFinished` passar a ser `true` (**uma única vez** por bloco; usar uma flag para evitar registro duplicado a cada rebuild).

**Commit sugerido:** `feat: adiciona modelo e controller de progresso do estudante`

> ✅ **Parte A implementada.** Regras adotadas: ofensiva com tolerância de 1 dia sem estudo e meta diária de 5 revisões. Testes em `test/progresso_controller_test.dart`.
> Pendência: o simulado ainda não registra erros por palavra porque `QuestaoSimulado` não tem `cardId`. Isso será feito na Parte D.

---

## 3. Parte B — Gamificação leve (R1)

### 3.1 Novo serviço: `lib/services/recompensa_service.dart`

```dart
class Recompensa {
  final String id;
  final String emoji;
  final String tituloIngles;   // ex.: "Word Master!"
  final String mensagemPt;     // ex.: "Você revisou 5 palavras sem pausa."
  final bool rara;             // conquista leve (menos frequente)
}

class RecompensaService {
  RecompensaService({Random? random}); // Random injetável para os testes
  Recompensa sortear({required int acertos, required int total, required ProgressoEstudo progresso});
}
```

**Lógica do sorteio (recompensa intermitente):**
1. Uma mensagem de incentivo sempre aparece (catálogo com cerca de 10 a 15 frases curtas em inglês com tradução, por exemplo *"Small steps, big wins!"* e *"Your brain loves this!"*).
2. Com cerca de 25% de chance, ou ao atingir um marco (1º bloco, 5 blocos, 10 palavras dominadas, ofensiva de 3 dias), sorteia uma **conquista leve** ainda não obtida, por exemplo *"Word Master!"*, *"Focus Champion"* ou *"Streak Starter"*.
3. Bloco com muitos erros → mensagem acolhedora (*"Mistakes help you learn!"*), **nunca** punitiva.
4. Evitar repetir a mesma mensagem duas vezes seguidas.

### 3.2 UI
- Novo widget `lib/widgets/recompensa_card.dart`: emoji grande, título em inglês, tradução e animação discreta (`AnimatedScale` ou `TweenAnimationBuilder`, sem confete piscando).
- Inserir no topo de `_construirTelaConclusao` (flashcards) e de `_construirTelaResultado` (simulado).
- Seguir `documentacao/guia-de-estilo.md` (cores de `AppColors`, sem excesso de estímulos visuais).

**Checklist anti-ansiedade:** sem contagem regressiva, sem "você perdeu a ofensiva!", sem vermelho para resultados, sem ranking.

**Commit sugerido:** `feat: implementa sorteio de micro-recompensas ao concluir blocos`

> ✅ **Parte B implementada.**
> - Os blocos recebem 8 expressões de incentivo; quando a taxa de acerto fica abaixo de 60%, recebem uma das 4 expressões acolhedoras.
> - Cada expressão vem com tradução e uma nota cultural.
> - 6 conquistas de marco são ganhas uma única vez e salvas no progresso: *First Step!*, *Flawless!*, *Never Give Up!*, *Streak Starter*, *Word Master!* e *Focus Champion*.
> - Quando não há marco novo, há 25% de chance de uma conquista surpresa (*Brain Booster*, *Curious Mind* ou *Steady Learner*).
> - A animação é discreta e respeita a opção "reduzir animações" do sistema.
> - Testes: `test/recompensa_service_test.dart` e `test/recompensa_card_test.dart`.

---

## 4. Parte C — Dashboard real (R2 a R5)

### 4.1 `lib/views/home_screen.dart`
Usar `context.watch<ProgressoController>()` e substituir:

| Texto fixo atual | Novo valor |
|---|---|
| `'🔥 7 dias'` | `'🔥 ${p.ofensiva} ${p.ofensiva == 1 ? 'dia' : 'dias'}'` |
| `'3 de 5 revisões concluídas'` + `value: 0.6` | `revisoesHoje` / `metaDiaria` (limitado a 1.0) |
| `'Você está quase lá!'` | Mensagem que muda conforme o progresso (0%, parcial ou meta batida) |
| `'12 flashcards esperando por você'` | Quantidade de cartões com `nextReview <= agora` (criar `contarCardsPendentes()` no `FlashcardRepository`) |
| `_ProgressItem('24', 'revisões')` / `('85%', 'de acertos')` | **Minutos estudados** e **palavras dominadas** (os dois indicadores pedidos), mantendo a taxa de acerto real |

Observação: como a `HomeScreen` é um `StatelessWidget`, o `watch` faz a tela se atualizar ao voltar de um bloco. Conferir que o `Navigator.push` volta para a Home sem precisar recarregar nada manualmente.

### 4.2 `lib/views/tela_perfil.dart`
- `_estatisticas`: `'4 dias'` → ofensiva real; `'320 XP'` → palavras dominadas (ou minutos); `'Nível'` → nível calculado a partir dos blocos concluídos (opcional).

**Commit sugerido:** `feat: conecta HomeScreen e Perfil as metricas reais de estudo`

> ✅ **Parte C implementada.** Na Home, a ofensiva, a meta diária, os flashcards pendentes e o bloco "Seu progresso" (minutos, palavras dominadas e % de acertos) agora usam dados reais. No Perfil, o bloco de estatísticas mostra ofensiva, palavras dominadas e minutos. Palavra dominada = `repetition >= 3` no SRS (`FlashcardRepository.repeticoesParaDominar`). O `test/widget_test.dart` foi ajustado para os novos textos (antes: "4 dias" / "320 XP").

---

## 5. Parte D — Adaptação inteligente / IA (R6)

### 5.1 Pré-requisito: ligar a questão à palavra
Adicionar `final String? cardId;` em `QuestaoSimulado` (incluindo `fromJson`/`toJson`) e preencher nos dados iniciais:
`q_1 → card_4 (Achievement)`, `q_2 → card_1 (Focus)`, `q_3 → card_2 (Breakdown)`, `q_4 → card_3 (Consistency)`, `q_5 → card_5 (Reward)`.
➡️ **Combinar com o JP** (models) e com a **Emily** (coluna `card_id` na tabela `questoes_simulado`).

### 5.2 Novo serviço: `lib/services/recomendacao_service.dart`
Motor de recomendação baseado em pontuação de fraqueza:

```
peso(questão) = 3 × errosPorCard[cardId]          // histórico de "Rever" e erros
             + 2 × (2.5 − easeFactor do cartão)  // quanto mais difícil, maior o peso
             + 1 × (está vencida no SRS ? 1 : 0)
             − 1 × (repetition do cartão >= 3 ? 1 : 0)
```

- `List<QuestaoSimulado> montarBlocoAdaptativo(int limite)`:
  1. Calcula o peso de todas as questões.
  2. Ordena da maior para a menor fraqueza.
  3. Monta o bloco com cerca de **70% de itens fracos + 30% de itens vencidos/novos**, para não frustrar o estudante com um bloco só de erros.
  4. Se não houver histórico de erros, usa o comportamento atual (`getDueQuestionsBlock`).
- O serviço deve ser **puro e testável**: recebe dados e devolve uma lista, sem acesso direto à UI.

### 5.3 Integração
- `SrsController._initBlock`: quando não houver filtro de deck, usar `RecomendacaoService.montarBlocoAdaptativo`.
- UI: no `TelaSimuladoIngles`, mostrar um selo discreto, por exemplo *"🎯 Bloco focado nas palavras que você marcou para rever"*, quando o bloco for adaptativo. Isso deixa o recurso visível para a avaliação.
- Opcional: na `HomeScreen`, um card "Revisar pontos fracos" listando as 3 palavras com mais erros.

### 5.4 Como justificar a "IA" na apresentação
Trata-se de um sistema de recomendação adaptativo (baseado em regras e pontuação), que usa o histórico individual de desempenho e o modelo SRS (SM-2) para personalizar o conteúdo. Esse recurso atende ao "requisito de recurso inteligente previsto na proposta" (`etapa-04.md`, §3.2). Uma IA generativa externa **não** é necessária.

**Commit sugerido:** `feat: adiciona recomendacao adaptativa baseada nos erros do estudante`

---

## 6. Parte E — Qualidade e Build Final (R7, R8)

### 6.1 `flutter analyze`
```bash
flutter pub get
flutter analyze
```
- Corrigir todos os *errors* e *warnings*; os *infos* devem ser zerados sempre que possível.
- Rodar também `flutter test`, para garantir que a minha parte não quebrou os testes do JP.

### 6.2 Preparação do Android
1. **Nome do app:** `AndroidManifest.xml` → `android:label="FocoDeck"`.
2. **Application ID:** trocar `com.example.projeto_com_api` por algo único, por exemplo `br.edu.focodeck.app`. Isso precisa ser alterado em `namespace` e em `applicationId` no `build.gradle.kts` e também no pacote da `MainActivity.kt`. ⚠️ Avisar a equipe, porque afeta a configuração do Supabase/Auth (deep links) da Emily.
3. **Versão:** `pubspec.yaml` → `version: 1.0.0+1` (aumentar o `+N` a cada build entregue).
4. **Ícone (opcional):** `flutter_launcher_icons`.

### 6.3 Assinatura de release
```bash
keytool -genkey -v -keystore %USERPROFILE%\focodeck-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias focodeck
```
- Criar `android/key.properties` (**não versionar**: adicionar ao `.gitignore` junto com `*.jks`):
  ```
  storePassword=...
  keyPassword=...
  keyAlias=focodeck
  storeFile=C:/Users/<usuario>/focodeck-upload.jks
  ```
- No `build.gradle.kts`, ler o `key.properties`, criar `signingConfigs { create("release") { ... } }` e usar `signingConfig = signingConfigs.getByName("release")` no `buildTypes.release`.
- Guardar a keystore e as senhas em local seguro, fora do repositório.

### 6.4 Gerar o bundle
```bash
flutter clean
flutter build appbundle --release
```
Saída esperada: `build/app/outputs/bundle/release/app-release.aab`

Validação extra (opcional): `flutter build apk --release` e instalar em um celular para um teste manual completo (login → flashcards → recompensa → Home atualizada → simulado adaptativo).

**Commits sugeridos:** `chore: configura assinatura e identidade do app para release` e `fix: corrige avisos do flutter analyze`

---

## 7. Testes da minha parte (para apoiar o JP)
Mesmo que a bateria de testes seja responsabilidade do JP, deixo pelo menos estes testes prontos:
- `test/recompensa_service_test.dart`: com `Random(seed)` fixo, o sorteio é determinístico; um bloco com erros nunca gera mensagem negativa.
- `test/progresso_controller_test.dart`: ofensiva (mesmo dia, dia seguinte, 1 dia de folga, quebra), soma de minutos e meta diária zerando no dia seguinte.
- `test/recomendacao_service_test.dart`: a questão cujo `cardId` tem mais erros vem primeiro; sem histórico, o comportamento é igual ao do SRS padrão.

---

## 8. Cronograma sugerido

| Ordem | Tarefa | Depende de |
|---|---|---|
| 1 | Parte A: model e controller de progresso | Merge do JP na `main` |
| 2 | Parte C: dashboard real (Home e Perfil) | 1 |
| 3 | Parte B: micro-recompensas | 1 |
| 4 | Parte D: IA adaptativa | 1 + campo `cardId` (JP/Emily) |
| 5 | Testes da seção 7 | 1–4 |
| 6 | Parte E: `flutter analyze` + `.aab` | **Por último**, depois que todas as frentes (JP, Emily e Maria) estiverem integradas |

---

## 9. Checklist final de entrega

- [ ] R1: Recompensa sorteada aparece no fim de cada bloco (flashcards e simulado)
- [ ] R2: Ofensiva real e flexível na Home
- [ ] R3: Minutos estudados reais na Home
- [ ] R4: Palavras dominadas reais na Home
- [ ] R5: Perfil com estatísticas reais
- [ ] R6: Simulado prioriza palavras com mais "Rever" e erros, com um selo visível
- [ ] R7: `flutter analyze` → `No issues found!`
- [ ] R8: `app-release.aab` gerado e assinado com chave de release
- [ ] R9: Commits no padrão Conventional Commits com a minha conta
- [ ] `etapa-04.md` atualizado com o status e as decisões (regra de ofensiva e critério de "palavra dominada")
- [ ] `key.properties` e `*.jks` **fora** do Git
