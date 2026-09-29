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

## 👥 Equipe e Entregas por Etapa

O projeto é desenvolvido em ciclos semanais por uma equipe de 4 integrantes organizados em duplas:

| Etapa | Escopo da Entrega | Status | Responsáveis (Dupla) |
| :---: | :--- | :---: | :---: |
| **Etapa 1** | **Estrutura Base, Autenticação e Design System:** Arquitetura móvel inicial, Design System de baixo estímulo, fluxo de login, cadastro e perfil de usuário. | Concluída com Ressalva Técnica (Persistência em disco pendente, postergada para o Supabase Auth na Etapa 3) | **Maria e Emily** |
| **Etapa 2** | **Módulo Questões (Inglês para TDAH):** Lógica e interface de Flashcards e Quiz/Simulados em blocos curtos, e algoritmo de Repetição Espaçada (SRS). | **Em Desenvolvimento** (UI/UX do JP concluída; Algoritmo SRS da Raquel em andamento) | **JP e Raquel** |
| **Etapa 3** | **Conexão com Banco Remoto (Supabase REST API):** Sincronização dinâmica de decks de vocabulário em inglês, histórico de revisões e tratamento assíncrono. | Aguardando Etapa 2 | **Maria e Emily** |
| **Etapa 4** | **Gamificação Leve para TDAH, Testes e Entrega Final:** Reforço positivo aleatório, testes automatizados e build final para Android (APK). | Aguardando Etapa 3 | **JP e Raquel** |

### Divisão de Papéis na Etapa Atual (Etapa 2):
- **JP (UI/UX & Apresentação):** Telas de estudo em blocos curtos, seleção de temas/decks, componente visual de Flashcard (flip 3D, fonética brasileira e autoavaliação), interface de Quiz/Simulado e navegação geral — **Concluído**.
- **Raquel (Lógica & Algoritmo):** Algoritmo central de Repetição Espaçada (SRS), modelagem das entidades de repetição, controller de fluxo de sessão e fila dinâmica — **Em andamento**.

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
