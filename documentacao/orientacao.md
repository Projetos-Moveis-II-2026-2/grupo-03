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

## 2. Equipe e Organização das Entregas

A equipe é composta por 4 integrantes (**JP, Raquel, Emily e Maria**). Após a conclusão da base das Etapas 1 e 2, o plano de ação final para cobrir todas as exigências da avaliação foi reorganizado da seguinte forma:

| Responsável | Frente de Trabalho | Escopo Detalhado | Status |
| :---: | :--- | :--- | :---: |
| **JP** | **Unificação de Branches, Correção das Pendências (Etapas 1 e 2) & Testes (Etapa 4)** | Merge das branches (`etapa-02` e `etapa-02-algoritmo-srs-tdah`) na `main` via PR; Injeção de dependência global com `Provider`; Serialização JSON (`fromJson`/`toJson`) em `CardIngles` e `QuestaoSimulado`; Correção do filtro de temas nos Flashcards/Simulado e data inicial do SRS; Validação de login e persistência local; Registro formal de escopo; Bateria de testes automatizados (`flutter test`) na Etapa 4. | Em Execução |
| **Emily** | **Etapa 3 (Parte 1): Backend Supabase, Auth & Endpoints REST** | Criação e configuração do projeto no Supabase (`decks_ingles`, `cards_vocabulario`, `questoes_simulado`, `progresso_srs_usuario`); Inserção de vocabulários iniciais (seed); Integração do Login/Cadastro com Supabase Auth e configuração do cliente REST/Supabase. | Planejado |
| **Maria** | **Etapa 3 (Parte 2): Repositórios Assíncronos & Tratamento de Erros** | Adaptação de `FlashcardRepository` e `QuestaoRepository` para consumo assíncrono da API REST; Sincronização do histórico SRS na nuvem; Estados visuais de carregamento (*loading*) e tratamento amigável de falhas de conexão nas telas. | Planejado |
| **Raquel** | **Etapa 4: Gamificação Leve, IA Adaptativa & Build (.aab)** | Mecanismo de recompensas aleatórias e dashboard real na Home (ofensiva, minutos e palavras dominadas); Recurso de IA/recomendação adaptativa focada nos pontos fracos do aluno nos simulados; Geração do pacote `.aab` (Android App Bundle). | Planejado |

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
