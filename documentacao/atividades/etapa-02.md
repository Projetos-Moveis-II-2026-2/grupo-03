# Atividade - Etapa 2: Módulo Questões (Inglês com Foco em TDAH)

## 1. Identificação da Atividade

- **Etapa:** 2
- **Título:** Módulo Questões: Ferramentas de Estudo Dinâmico de Inglês (Flashcards & Simulados) em Blocos Curtos e Algoritmo de Revisão Espaçada (SRS)
- **Dupla Responsável:** **JP** e **Raquel**
- **Status da Etapa:** **Em Desenvolvimento (Etapa Atual da Dupla)**

---

## 2. Escopo da Entrega

> *"Módulo Questões: Desenvolvimento da lógica e interface das ferramentas de estudo dinâmico (Flashcards/Simulados). Foco na navegação intuitiva em blocos curtos e criação do algoritmo central de fluxo das revisões (espinha dorsal do suporte às funções executivas)."*

---

## 3. Diretrizes de Aprendizado de Inglês para Pessoas com TDAH

1. **Estudo em Blocos Curtos (Micro-learning):**
   - Sessões intencionalmente curtas (máximo de 5 flashcards ou 4 questões de quiz por bloco).
   - Evita a sobrecarga da memória de trabalho e impede a fadiga cognitiva rápida comum no TDAH.
2. **Algoritmo de Revisão Espaçada (SRS) Adaptativo:**
   - Atua como a **espinha dorsal das funções executivas**, retirando do estudante a necessidade de planejar o que deve revisar no dia.
   - Vocabulários em inglês com maior índice de erro reaparecem ainda dentro do mesmo bloco para fixação ativa por repetição imediata.
   - Vocábulos consolidados têm seu espaçamento aumentado (ex: 1 dia, 3 dias, 7 dias).
   - **Mecanismo anti-ansiedade:** Não gera pilhas punitivas de dezenas de cards acumulados caso o estudante passe dias sem abrir o app.
3. **Reforço Ativo com Quiz e Simulados:**
   - Fixação do vocabulário através de associação direta (palavra em inglês -> contexto/imagem/frase em português -> escolha de alternativa).
   - Feedback instantâneo (reforço positivo imediato para ativação dopaminérgica).

---

## 4. Divisão de Responsabilidades da Dupla

### 👤 Raquel (UI/UX, Navegação em Blocos Curtos & Interfaces de Estudo)
- **Tela de Seleção de Baralhos de Inglês:**
  - Categorias temáticas práticas (ex: *Daily Routine*, *Travel Essentials*, *Work & Tech*, *Common Phrasal Verbs*).
  - Indicador visual limpo da quantidade de blocos curtos disponíveis no dia.
- **Componente Visual de Flashcard Interativo:**
  - Animação de virada rápida (flip de 250ms) entre frente (termo em inglês + pronúncia fonética + frase contextual) e verso (tradução + dica visual).
  - Botões de autoavaliação com toque amplo e cores acessíveis (*Preciso rever*, *Entendi*, *Fácil*).
- **Interface de Quiz / Simulado Rápido:**
  - Layout focado em uma única pergunta por vez, com alternativas em botões confortáveis e sem contadores regressivos estressantes.
- **Tela de Conclusão do Bloco:**
  - Resumo de palavras aprendidas/revisadas no bloco (ex: "🎉 Você dominou 5 novas palavras!").

### 👤 JP (Algoritmo SRS, Modelagem de Dados & Gerenciador do Fluxo)
- **Modelagem das Entidades de Inglês:**
  - `CardIngles`: Id, termo em inglês, tradução, frase de exemplo, nível de dificuldade, data da última revisão, intervalo de repetição (dias) e fator de facilidade (Ease Factor).
  - `QuizQuestao`: Id, enunciado, opções de resposta, índice correto e explicação didática rápida.
  - `BlocoEstudo`: Estrutura controladora dos itens ativos na sessão atual.
- **Implementação do Algoritmo Central de Revisão Espaçada (SRS):**
  - Cálculo de agendamento baseado na resposta do usuário (*Difícil*, *Bom*, *Fácil*).
  - Reordenação dinâmica da fila da sessão (cards que o usuário errou voltam ao fim do bloco atual para fixação imediata).
- **Gerenciador de Estado do Estudo (Controller):**
  - Controle de avanço de questão/card, cálculo de acertos e sinalização de término de bloco.
  - Preparação para exportação e sincronização com o Supabase na Etapa 3.

---

## 5. Critérios de Aceitação e Checklist da Dupla

- [ ] O usuário consegue estudar vocabulário de inglês em blocos limitados (máximo de 5 a 7 itens por vez).
- [ ] A interação com os flashcards é fluida, sem distrações e com tipografia legível.
- [ ] O simulado/quiz de inglês valida a alternativa escolhida e exibe explicação imediata.
- [ ] O algoritmo de repetição espaçada recalcula o próximo ciclo de revisão da palavra avaliada.
- [ ] O design segue à risca o padrão minimalista aprovado na Etapa 1.
