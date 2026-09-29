# Atividade - Etapa 4: Gamificação Leve para TDAH, Testes e Entrega Final

## 1. Identificação da Atividade

- **Etapa:** 4
- **Título:** Gamificação Leve e Aleatória Adaptada para TDAH, Bateria de Testes e Entrega Final
- **Dupla Responsável:** **JP** e **Raquel**
- **Status da Etapa:** Aguardando Conclusão da Etapa 3

---

## 2. Escopo da Entrega

> *"Desenvolvimento da gamificação leve e aleatória, Testes e Entrega Final"*

---

## 3. Diretriz de Gamificação Leve & Aleatória para TDAH

O FocoDeck adota um modelo de **gamificação leve, acolhedora e aleatória**:
- **Recompensas Aleatórias Intermitentes:** Ao concluir um bloco curto de inglês (5 cards), o app sorteia ocasionalmente uma mensagem divertida de incentivo cultural em inglês ou um pequeno badge ("*Word Master!*"). Esse padrão intermitente estimula a dopamina de forma positiva sem sobrecarregar.
- **Ofensivas Flexíveis (Streak com Margem):** O estudante celebra seus dias de estudo de inglês sem ser punido desproporcionalmente por lapsos de rotina.
- **Celebração do Vocabulário Conquistado:** Métricas visuais claras e simples de palavras dominadas (ex: "25 novas palavras integradas à sua memória de longo prazo este mês").

---

## 4. Divisão de Responsabilidades da Dupla

### 👤 Raquel (Gamificação Leve & Experiência de Sucesso)
- **Mecanismo de Recompensas Aleatórias:**
  - Gerador de micro-estímulos e mensagens motivacionais contextuais em inglês.
  - Animações sutis e micro-recompensas visuais que respeitam o minimalismo e não geram dispersão.
- **Dashboard de Progresso em Inglês:**
  - Atualização dos dados na tela principal (`HomeScreen`): minutos focados, blocos concluídos e palavras revisadas.
  - Seção de marcos e conquistas no perfil do aluno.

### 👤 JP (Testes Automatizados, Performance & Build de Produção)
- **Bateria de Testes Unitários:**
  - Testes do algoritmo de repetição espaçada (SRS) de vocabulário.
  - Testes de regras de pontuação e transição de blocos de quiz.
  - Teste dos modelos de dados do Supabase.
- **Testes de Widgets e Interface:**
  - Teste de renderização e acessibilidade visual dos botões, inputs e cards de inglês.
- **Preparação da Entrega Final:**
  - Resolução de advertências de análise estática (`flutter analyze`).
  - Geração de pacote compilado para Android (APK).
  - Atualização do `README.md` com guia de execução, credenciais de teste e arquitetura documentada.

---

## 5. Critérios de Aceitação e Checklist da Dupla

- [ ] A gamificação é percebida como leve, motivadora e sem elementos que gerem ansiedade ou culpa.
- [ ] O estudante visualiza com clareza o seu progresso no aprendizado de inglês.
- [ ] Todos os testes automatizados executam sem falhas (`flutter test`).
- [ ] O aplicativo é compilado em versão final estável para Android.
- [ ] A documentação do projeto está completa e pronta para avaliação da disciplina.
