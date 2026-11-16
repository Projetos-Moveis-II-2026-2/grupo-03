# FocoDeck 🎯

> **Aplicativo móvel para aprendizado de Língua Inglesa com foco em pessoas com TDAH (Transtorno do Déficit de Atenção com Hiperatividade).**

---

## 📖 Sobre o Projeto

O **FocoDeck** foi idealizado para transformar o aprendizado de inglês em uma experiência de baixo atrito cognitivo, adaptada às necessidades neuropsicológicas de estudantes com TDAH. 

Diferente de métodos tradicionais que geram paralisia de escolha, sobrecarga sensorial e ansiedade por acúmulo de tarefas, o FocoDeck estrutura o aprendizado através de:
- **Design Minimalista:** Paleta de cores neutras e contrastantes, tipografia limpa e ausência de poluição visual.
- **Micro-learning em Blocos Curtos:** Sessões de estudo de 3 a 5 minutos (5 flashcards ou 4 questões por bloco), respeitando a memória de trabalho.
- **Repetição Espaçada (SRS) Adaptativa:** Algoritmo central de revisões que cuida do agendamento automático do vocabulário, eliminando a fadiga de planejamento.
- **Reforço Ativo (Quiz e Simulados):** Validação imediata com micro-ciclos de dopamina saudável e reforço positivo.
- **Gamificação Leve:** Streaks flexíveis e incentivos aleatórios que não punem o estudante por dias de ausência.

---

## 👥 Equipe e Planejamento de Atividades

A equipe é composta por 4 integrantes (**JP, Raquel, Emily e Maria**), com a seguinte divisão de responsabilidades para as entregas e ajustes técnicos do projeto:

| Etapa / Frente | Escopo da Entrega | Status | Responsáveis |
| :---: | :--- | :---: | :---: |
| **Etapa 1** | **Estrutura Base, Autenticação e Design System:** Arquitetura móvel inicial, Design System de baixo estímulo, fluxo de login, cadastro e perfil de usuário. | Concluída (Ajustes técnicos em andamento) | **Maria e Emily** |
| **Etapa 2** | **Módulo Questões (Inglês para TDAH):** Interface de Flashcards e Quiz/Simulados em blocos curtos, e algoritmo de Repetição Espaçada (SRS). | Concluída (Unificada na branch `etapa-02`) | **JP e Raquel** |
| **Ajustes Etapas 1 e 2** | **Unificação de Branches & Correções Arquiteturais:** Merge para a `main`, injeção de dependência com `Provider`, serialização JSON (`fromJson`/`toJson`), correção de filtros de tema/SRS e persistência local. | **Em Execução** | **JP** |
| **Etapa 3** | **Conexão com Banco Remoto (Supabase REST API):** Backend e Auth no Supabase (**Emily**) + Repositórios assíncronos, sincronização do SRS e tratamento de erros de rede na UI (**Maria**). | Planejado | **Emily e Maria** |
| **Etapa 4** | **Gamificação Leve, IA Adaptativa, Testes e Build Final (.aab):** Recompensas aleatórias, métricas reais na Home, recomendação adaptativa (IA) para pontos fracos e pacote `.aab` (**Raquel**) + Testes automatizados `flutter test` (**JP**). | Planejado | **Raquel e JP** |

### Detalhamento das Atividades Atuais por Integrante:
- **JP:**
  - Unificar as branches `etapa-02` e `etapa-02-algoritmo-srs-tdah` e integrar à `main` via Pull Request.
  - Implementar injeção de dependência global (`Provider`) para manter o estado dos repositórios e da sessão entre as telas.
  - Adicionar `fromJson` e `toJson` nos modelos `CardIngles` e `QuestaoSimulado`.
  - Corrigir o repasse de temas selecionados para `TelaEstudoFlashcards` e `TelaSimuladoIngles`, e ajustar a data inicial de revisão dos novos cartões no SRS.
  - Implementar validação de credenciais no login e persistência local.
  - **(Etapa 4):** Desenvolver a bateria de testes automatizados (`flutter test` — testes unitários do algoritmo SRS, models e componentes visuais).
- **Emily (Etapa 3 - Backend & Auth):**
  - Configurar projeto e tabelas no Supabase (`decks_ingles`, `cards_vocabulario`, `questoes_simulado`, `progresso_srs_usuario`) com carga inicial de dados.
  - Integrar autenticação de usuários (Login/Cadastro/Recuperação) e expor os serviços/endpoints de consulta e gravação.
- **Maria (Etapa 3 - Consumo REST & Resiliência de UI):**
  - Refatorar `FlashcardRepository` e `QuestaoRepository` para buscar dados remotamente via API REST e sincronizar intervalos do SRS.
  - Implementar indicadores de carregamento (*loading*), cache da sessão ativa e tratamento amigável de erros de conexão.
- **Raquel (Etapa 4 - Gamificação, IA & Release):**
  - Implementar gamificação leve para TDAH (sorteio de micro-recompensas ao fim dos blocos e atualização dinâmica de ofensivas/minutos na `HomeScreen`).
  - Implementar módulo inteligente/IA para adaptar simulados focando nos vocabulários com maior taxa de erro do estudante.
  - Gerar o pacote final Android App Bundle (`.aab`).

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem & Framework:** Dart & Flutter (SDK >= 3.11.0 < 4.0.0)
- **Design System:** Material 3 Customizado (minimalista, alto contraste)
- **Gerenciamento de Estado:** `ChangeNotifier` / Padrão Observer & Singleton
- **Banco de Dados & Backend:** **Supabase** (PostgreSQL na nuvem, Supabase Auth e API REST)
- **Comunicação HTTP / REST:** `dio` / `supabase_flutter`

---

## 📂 Estrutura do Repositório

```text
├── android/               # Configurações da plataforma Android
├── ios/                   # Configurações da plataforma iOS
├── web/                   # Configurações da plataforma Web
├── windows/               # Configurações da plataforma Windows Desktop
├── lib/
│   ├── main.dart          # Ponto de entrada do aplicativo (MaterialApp & Rotas)
│   ├── models/            # Modelos de dados e gerenciadores de estado (SessaoUsuario, etc.)
│   ├── theme/             # Design System (app_colors.dart e app_theme.dart)
│   ├── views/             # Telas do app (Login, Cadastro, Home, Perfil, etc.)
│   └── widgets/           # Componentes visuais reaproveitáveis (AppButton, AppTextField, etc.)
├── documentacao/
│   ├── orientacao.md      # Estado geral, proposta de valor e planejamento de duplas
│   ├── guia-de-estilo.md  # Paleta de cores, tipografia, espaçamentos e componentes
│   └── atividades/        # Divisão detalhada de atividades por etapa
│       ├── etapa-01.md
│       ├── etapa-02.md
│       ├── etapa-03.md
│       └── etapa-04.md
├── pubspec.yaml           # Metadados e dependências do Flutter
└── README.md              # Apresentação geral do projeto
```

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versão 3.11.0 ou superior).
- Google Chrome instalado ou emulador Android configurado.

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/Projetos-Moveis-II-2026-2/grupo-03.git
   cd grupo-03
   ```

2. **Acesse a branch de trabalho:**
   ```bash
   git checkout etapa-02
   ```

3. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

4. **Execute no navegador (Chrome):**
   ```bash
   flutter run -d chrome
   ```
   *(Dica: No Chrome, abra a ferramenta do desenvolvedor `F12` e ative o modo de emulação de dispositivos móveis `Ctrl + Shift + M`).*

5. **Ou execute em dispositivo / emulador Android:**
   ```bash
   flutter run
   ```

---

## 📚 Documentação Complementar

- [Documento de Orientação Geral](documentacao/orientacao.md)
- [Guia de Estilo e Padrão Visual (Design System)](documentacao/guia-de-estilo.md)
- [Atividade - Etapa 1](documentacao/atividades/etapa-01.md)
- [Atividade - Etapa 2](documentacao/atividades/etapa-02.md)
- [Atividade - Etapa 3](documentacao/atividades/etapa-03.md)
- [Atividade - Etapa 4](documentacao/atividades/etapa-04.md)
