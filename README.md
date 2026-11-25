# FocoDeck 🎯

> **Aplicativo móvel para aprendizado de Língua Inglesa com foco em pessoas com TDAH (Transtorno do Déficit de Atenção com Hiperatividade).**

---

## 📖 Sobre o Projeto

O **FocoDeck** foi idealizado para transformar o aprendizado de inglês em uma experiência de baixo atrito cognitivo, adaptada às necessidades neuropsicológicas de estudantes com TDAH. 

Diferente de métodos tradicionais que geram paralisia de escolha, sobrecarga sensorial e ansiedade por acúmulo de tarefas, o FocoDeck estrutura o aprendizado através de:
- **Design Minimalista:** Paleta de cores neutras e contrastantes, tipografia limpa e ausência de poluição visual.
- **Micro-learning em Blocos Curtos:** Sessões de estudo de 3 a 5 minutos (até 5 flashcards ou 5 questões por bloco), respeitando a memória de trabalho.
- **Repetição Espaçada (SRS) Adaptativa:** Algoritmo central de revisões que cuida do agendamento automático do vocabulário, eliminando a fadiga de planejamento.
- **Reforço Ativo (Quiz e Simulados):** Validação imediata com micro-ciclos de dopamina saudável e reforço positivo.
- **Gamificação Leve:** Ofensivas flexíveis e incentivos aleatórios que não punem o estudante por dias de ausência.
- **Pronúncia Acessível:** Forma aportuguesada (ex.: "FÔU-kâs") e áudio em inglês com a voz do aparelho.

---

## ✨ Como Funciona

### Estados de uma palavra

| Estado | Critério |
| :--- | :--- |
| **Nova** | Ainda não foi estudada. |
| **Aprendendo** | Já foi estudada, mas ainda não atingiu o critério de domínio. |
| **Dominada** | 3 acertos seguidos em revisões espaçadas, em dias diferentes. |

Refazer um bloco no mesmo dia vale como treino, mas não conta para o domínio. Errar ou marcar "Rever" reinicia a contagem. A Início, o Perfil, as conquistas e o resumo do bloco usam esse mesmo critério.

### De onde vem o conteúdo

| Recurso | Origem |
| :--- | :--- |
| Decks e questões principais | Supabase, com conteúdo embutido como alternativa sem internet |
| Temas sugeridos (Viagem, Trabalho, Comida, Saúde, Casa, Escola) | Listas prontas de nível iniciante, no próprio app |
| Temas digitados | APIs públicas: Datamuse (palavras), Free Dictionary (pronúncia e exemplos) e MyMemory (tradução) |
| Pronúncia escrita | Decks fixos já trazem a forma aportuguesada; nos temas digitados, ela é convertida do alfabeto fonético (IPA) |
| Áudio | Voz do aparelho (`flutter_tts`) |

### Recomendação adaptativa

Os simulados priorizam as palavras com mais erros e maior dificuldade. Essa adaptação é um **algoritmo de pontuação baseado em regras**, calculado no aparelho. O app não usa IA generativa, e a geração de decks não usa IA.

---

## 👥 Equipe e Planejamento de Atividades

A equipe é composta por 4 integrantes (**JP, Raquel, Emily e Maria**), com a seguinte divisão de responsabilidades para as entregas e ajustes técnicos do projeto:

| Etapa / Frente | Escopo da Entrega | Status | Responsáveis |
| :---: | :--- | :---: | :---: |
| **Etapa 1** | **Estrutura Base, Autenticação e Design System:** Arquitetura móvel inicial, Design System de baixo estímulo, fluxo de login, cadastro e perfil de usuário. | Concluída | **Maria e Emily** |
| **Etapa 2** | **Módulo Questões (Inglês para TDAH):** Interface de Flashcards e Quiz/Simulados em blocos curtos, e algoritmo de Repetição Espaçada (SRS). | Concluída | **JP e Raquel** |
| **Ajustes Etapas 1 e 2** | **Unificação de Branches & Correções Arquiteturais:** Injeção de dependência com `Provider`, serialização JSON, correção de filtros de tema/SRS e persistência local. | Concluída | **JP** |
| **Etapa 3** | **Conexão com Banco Remoto (Supabase REST API):** Backend e Auth no Supabase (**Emily**) + Repositórios assíncronos e tratamento de erros de rede na UI (**Maria**). | Concluída, exceto a sincronização remota do SRS | **Emily e Maria** |
| **Etapa 4** | **Gamificação Leve, Recomendação Adaptativa, Testes e Build Final:** Recompensas aleatórias, métricas reais na Início, recomendação para pontos fracos e pacote `.aab` (**Raquel**) + Testes automatizados (**JP**). | Em andamento (falta o `.aab`) | **Raquel e JP** |
| **Ajustes da avaliação** | **Melhorias nas telas:** Critério de palavra dominada, contadores unificados, navegação simplificada, pronúncia, áudio e palavras por tema. | Concluída (ver pendências) | **Grupo** |

### Pendências conhecidas

- Gerar e testar o pacote `.aab` assinado.
- Trocar o nome exibido no Android de `projeto_com_api` para `FocoDeck`.
- Sincronizar o progresso e o SRS com o Supabase: hoje ficam **somente no aparelho**, separados por conta, e se perdem ao reinstalar o app. Detalhes em [pendências da Etapa 3](documentacao/pendencias-etapa-3-parte-2.md).
- Sem internet, as palavras dos decks embutidos fora de "Foco & Produtividade" não entram nos contadores.
- Temas digitados dependem de APIs gratuitas, que têm limite de uso e podem trazer traduções imprecisas.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem & Framework:** Dart & Flutter (SDK >= 3.11.0 < 4.0.0)
- **Design System:** Material 3 Customizado (minimalista, alto contraste)
- **Gerenciamento de Estado:** `Provider` com `ChangeNotifier`
- **Banco de Dados & Backend:** **Supabase** (PostgreSQL na nuvem, Supabase Auth e API REST)
- **Comunicação HTTP / REST:** `dio` / `supabase_flutter`
- **Persistência Local:** `shared_preferences`
- **Áudio:** `flutter_tts`
- **APIs de vocabulário:** Datamuse, Free Dictionary e MyMemory

---

## 📂 Estrutura do Repositório

```text
├── android/               # Configurações da plataforma Android
├── ios/                   # Configurações da plataforma iOS
├── web/                   # Configurações da plataforma Web
├── windows/               # Configurações da plataforma Windows Desktop
├── linux/ e macos/        # Configurações das demais plataformas desktop
├── lib/
│   ├── main.dart          # Ponto de entrada do aplicativo
│   ├── controllers/       # Sessão de flashcards, simulado (SRS) e progresso
│   ├── dev/               # Entrada de teste local, sem Supabase
│   ├── models/            # Modelos de dados, intervalos SRS e sessão do usuário
│   ├── repositories/      # Acesso aos dados remotos e locais
│   ├── services/          # APIs, temas prontos, pronúncia, áudio, recompensas e recomendação
│   ├── theme/             # Design System (app_colors.dart e app_theme.dart)
│   ├── views/             # Telas do app (Login, Início, Estudos, Simulado, Perfil, etc.)
│   └── widgets/           # Componentes visuais reaproveitáveis
├── test/                  # Testes automatizados
├── documentacao/
│   ├── orientacao.md      # Estado geral, proposta de valor e planejamento de duplas
│   ├── guia-de-estilo.md  # Paleta de cores, tipografia, espaçamentos e componentes
│   ├── fix-improve/       # Detalhe das correções e melhorias
│   ├── pendencias-etapa-3-parte-2.md
│   ├── relatorio-correcoes-melhorias.md
│   └── atividades/        # Divisão detalhada de atividades por etapa
│       ├── etapa-01.md
│       ├── etapa-02.md
│       ├── etapa-03.md
│       ├── etapa-04.md
│       └── plano-raquel-etapa-04.md
├── pubspec.yaml           # Metadados e dependências do Flutter
└── README.md              # Apresentação geral do projeto
```

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versão 3.11.0 ou superior).
- Google Chrome instalado ou emulador/aparelho Android configurado (exige o Android SDK).
- URL e chave pública (*publishable*) do projeto Supabase, com o grupo.
- **Somente para Windows Desktop:** `nuget.exe`, exigido pelo `flutter_tts` (`winget install Microsoft.NuGet`).

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/Projetos-Moveis-II-2026-2/grupo-03.git
   cd grupo-03
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Crie um arquivo `.env` na raiz do projeto:**
   ```env
   SUPABASE_URL=https://seu-projeto.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sua-chave-publica
   ```
   O `.env` não é versionado. Nunca use a chave `service_role` no aplicativo.

4. **Execute no navegador (Chrome):**
   ```bash
   flutter run -d chrome --dart-define-from-file=.env
   ```
   *(Dica: No Chrome, abra a ferramenta do desenvolvedor `F12` e ative o modo de emulação de dispositivos móveis `Ctrl + Shift + M`).*

5. **Ou execute em dispositivo / emulador Android:**
   ```bash
   flutter run --dart-define-from-file=.env
   ```

No VS Code, a configuração **FocoDeck** (`F5`) já usa o `.env`.

**Sem as chaves do Supabase**, dá para testar o app sem login (perfil e conteúdo remoto não funcionam):
```bash
flutter run -d chrome -t lib/dev/main_preview.dart
```

---

## ✅ Testes

```bash
flutter analyze
flutter test
```

## 📦 Build Android (`.aab`)

1. Crie `android/key.properties` com os dados da chave de assinatura (não versionar). Sem ele, o build usa a assinatura de debug, que não serve para publicação.
2. Gere o pacote:
   ```bash
   flutter build appbundle --dart-define-from-file=.env
   ```

---

## 📚 Documentação Complementar

- [Documento de Orientação Geral](documentacao/orientacao.md)
- [Guia de Estilo e Padrão Visual (Design System)](documentacao/guia-de-estilo.md)
- [Atividade - Etapa 1](documentacao/atividades/etapa-01.md)
- [Atividade - Etapa 2](documentacao/atividades/etapa-02.md)
- [Atividade - Etapa 3](documentacao/atividades/etapa-03.md)
- [Atividade - Etapa 4](documentacao/atividades/etapa-04.md)
- [Plano da Etapa 4](documentacao/atividades/plano-raquel-etapa-04.md)
- [Pendências da Etapa 3](documentacao/pendencias-etapa-3-parte-2.md)
- [Relatório de Correções e Melhorias](documentacao/relatorio-correcoes-melhorias.md)
