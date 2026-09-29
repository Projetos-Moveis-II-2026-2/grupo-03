# Documento de Orientação Geral do Projeto: FocoDeck

## 1. Visão Geral e Proposta de Valor

O **FocoDeck** é um aplicativo móvel voltado exclusivamente para o **aprendizado da Língua Inglesa**, projetado especificamente para atender às necessidades neuropsicológicas de **pessoas com TDAH (Transtorno do Déficit de Atenção com Hiperatividade)**.

### Pilares Fundamentais:
1. **Foco Exclusivo em Inglês:** O domínio do conteúdo é 100% centrado em vocabulário, estruturas essenciais, expressões cotidianas e compreensão em língua inglesa (níveis iniciante a intermediário).
2. **Design Minimalista & Baixa Carga Cognitiva:** Interface limpa, com poucos estímulos visuais concorrentes, tipografia acessível, cores confortáveis e sem anúncios ou poluição que dispersem a atenção.
3. **Suporte às Funções Executivas (TDAH):** Apoio estrutural contra a procrastinação, paralisia de decisão e fadiga mental, dividindo os estudos em **blocos curtos de 3 a 5 minutos**.
4. **Metodologia de Repetição Espaçada (SRS):** Algoritmo inteligente que reapresenta palavras e estruturas no momento exato antes do esquecimento, consolidando a memória de longo prazo.
5. **Reforço de Aprendizado Ativo (Quiz & Simulados):** Prática ativa com feedback imediato, gerando micro-ciclos de recompensa dopaminérgica saudável sem sobrecarga.

---

## 2. Equipe e Organização das Entregas em Dupla

A equipe é composta por 4 integrantes organizados em duplas fixas que alternam as etapas de entrega semanais:

- **Dupla A:** Maria e Emily
- **Dupla B:** JP e Raquel

| Etapa | Foco da Entrega | Status | Responsáveis (Dupla) |
| :---: | :--- | :---: | :---: |
| **Etapa 1** | **Estrutura Base, Autenticação e Design System:** Arquitetura móvel, design system minimalista (baixo estímulo), autenticação, perfil e sessão. | Concluída (Pendente Persistência em Disco) | **Maria e Emily** |
| **Etapa 2** | **Módulo Questões (Inglês para TDAH):** Lógica e interface de Flashcards e Quiz/Simulados de inglês em blocos curtos, e algoritmo de Repetição Espaçada (SRS). | **Em Desenvolvimento (Etapa Atual)** | **JP e Raquel** |
| **Etapa 3** | **Conexão com Banco Remoto (Supabase REST API):** Sincronização dinâmica de decks de vocabulário em inglês, histórico de revisões e tratamento assíncrono. | Aguardando Etapa 2 | **Maria e Emily** |
| **Etapa 4** | **Gamificação Leve para TDAH, Testes e Entrega Final:** Reforço positivo aleatório, streaks sem punição desmotivadora, testes e build de produção. | Aguardando Etapa 3 | **JP e Raquel** |

### Divisão da Etapa 2 (Atual):
- **JP:** UI/UX, Telas de Estudo em Blocos Curtos, Decks, Flashcard Interativo (Flip) e Interface de Quiz/Simulado.
- **Raquel:** Algoritmo Central de Repetição Espaçada (SRS), Modelagem de Dados, Controller de Fluxo e Fila Dinâmica.

> O padrão completo de cores, fontes, botões, inputs e layouts está catalogado e documentado em:
> 👉 `documentacao/guia-de-estilo.md`

---

## 3. Definição do Backend e Banco de Dados (Supabase)

Para persistência de dados online e entrega de conteúdo dinâmico de inglês:
- **Catálogo de Conteúdo de Inglês:** Tabelas de tópicos (`decks_ingles`), cartões (`cards_vocabulario`) e questões (`questoes_simulado`).
- **Autenticação:** Supabase Auth com persistência de token segura em disco.
- **Armazenamento de Progresso SRS:** Registro do nível de facilidade de cada palavra em inglês por usuário.
- **Segurança (RLS):** Isolamento dos dados de estudo de cada estudante.

---

## 4. Diretrizes de Git e Versionamento em Dupla

1. **Branch Principal:** `main`.
2. **Branch da Etapa Atual:** `etapa-02`.
3. **Branches de Feature da Etapa 2:**
   - `etapa-02/flashcards-ingles`
   - `etapa-02/algoritmo-srs-tdah`
   - `etapa-02/quiz-simulado`
4. **Revisão de Código em Par:** Todo código da etapa passa por Pull Request revisado e testado pela dupla antes de ser integrado.
