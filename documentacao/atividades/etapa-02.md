# Atividade - Etapa 2: Módulo Questões (Inglês com Foco em TDAH)

## 1. Identificação da Atividade

- **Etapa:** 2
- **Título:** Módulo Questões: Ferramentas de Estudo Dinâmico de Inglês (Flashcards & Simulados) em Blocos Curtos e Algoritmo de Revisão Espaçada (SRS)
- **Dupla Responsável:** **JP** e **Raquel**
- **Status da Etapa:** **Em Desenvolvimento (Frente de UI/UX Concluída; Frente de Algoritmo em Andamento)**

---

## 2. Escopo da Entrega

> *"Módulo Questões: Desenvolvimento da lógica e interface das ferramentas de estudo dinâmico (Flashcards/Simulados). Foco na navegação intuitiva em blocos curtos e criação do algoritmo central de fluxo das revisões (espinha dorsal do suporte às funções executivas)."*

---

## 3. Diretrizes de Aprendizado de Inglês para Pessoas com TDAH

1. **Estudo em Blocos Curtos (Micro-learning):**
   - Sessões limitadas a 3 a 5 cartões/questões por bloco para respeitar os limites da memória de trabalho e evitar fadiga mental rápida.
2. **Algoritmo de Revisão Espaçada (SRS) Adaptativo:**
   - Suporte direto às funções executivas, automatizando o agendamento de revisão para evitar fadiga de decisão e sobrecarga cognitiva.
   - Vocabulários com autoavaliação de erro/revisão reaparecem dinamicamente no mesmo bloco para consolidação ativa imediata.
   - Vocábulos dominados recebem ampliação progressiva de intervalo de revisão.
3. **Reforço Ativo com Quiz e Simulados:**
   - Fixação do vocabulário através de associação direta com feedback visual imediato (verde/vermelho) e breve contextualização didática.
   - Ausência de temporizadores regressivos para evitar ansiedade de desempenho.

---

## 4. Divisão de Responsabilidades e Status de Execução

### 👤 JP (UI/UX, Navegação em Blocos Curtos & Interfaces de Estudo) — Status: CONCLUÍDO
- **Tela de Seleção de Baralhos de Inglês (`lib/views/tela_decks_ingles.dart`):**
  - Categorias temáticas práticas (*Foco & Produtividade*, *Daily Routine*, *Travel Essentials*) em blocos curtos.
- **Componente Visual de Flashcard Interativo (`lib/widgets/flashcard_widget.dart`):**
  - Animação suave de virada 3D (flip de 280ms) entre frente e verso com perspectiva espacial.
  - Exibição de pronúncia adaptada ao português brasileiro com sílaba tônica em caixa alta e ícone sonoro (`card_ingles.dart`).
  - Botão de virada de cartão explícito no verso e botões de autoavaliação (*Rever*, *Bom*, *Fácil*).
- **Interface de Quiz / Simulado Rápido (`lib/views/tela_simulado_ingles.dart`):**
  - 5 questões de múltipla escolha com feedback de validação em tempo real e explicações didáticas.
  - Tela de resultado exibindo total de acertos e taxa percentual de aproveitamento.
- **Fluxo de Navegação e Conclusão (`lib/views/tela_estudo_flashcards.dart`):**
  - Barra de progresso minimalista, conclusão de bloco com métricas de estudo e redirecionamento para escolha de novo tema.
  - Conexão de todas as rotas a partir da tela principal (`lib/views/home_screen.dart`).

### 👤 Raquel (Algoritmo SRS, Modelagem de Dados & Gerenciador do Fluxo) — Status: EM ANDAMENTO
- **Modelagem das Entidades de Domínio:**
  - Estruturação dos parâmetros de cálculo de facilidade e agendamento da repetição espaçada.
- **Implementação do Algoritmo Central de Revisão Espaçada (SRS):**
  - Regra de cálculo de intervalos de revisão com base no desempenho do estudante.
  - Fila dinâmica de reapresentação de cartões dentro e fora da sessão.
- **Gerenciador de Estado do Estudo (Controller):**
  - Desacoplamento da lógica de negócio das telas visuais, preparando a integração com o Supabase da Etapa 3.

---

## 5. Critérios de Aceitação e Checklist da Dupla

- [x] O usuário consegue navegar entre baralhos temáticos de inglês em blocos curtos.
- [x] O componente visual de Flashcard possui animação de flip 3D suave e suporte a pronúncia figurada brasileira com entonação tônica.
- [x] O verso do cartão disponibiliza botões de autoavaliação e botão acessível para retorno da face.
- [x] A tela de simulado valida a alternativa escolhida de forma imediata e exibe explicação clara.
- [x] O fluxo da sessão conclui com métricas objetivas e opção para selecionar outro tema.
- [ ] O algoritmo de repetição espaçada recalcula o próximo ciclo de revisão da palavra avaliada (Raquel).
- [ ] A fila inteligente gerencia dinamicamente os cards pendentes do dia (Raquel).
