# Atividade - Etapa 4: Gamificação Leve para TDAH, Testes e Entrega Final

## 1. Identificação da Atividade

- **Etapa:** 4
- **Título:** Gamificação Leve para TDAH, Recomendação Adaptativa (IA), Testes e Entrega Final (`.aab`)
- **Responsáveis:** **Raquel** e **JP**
- **Status da Etapa:** Planejada (Aguardando Etapa 3)

---

## 2. Escopo da Entrega

> *"Desenvolvimento da gamificação leve e aleatória, recurso de adaptação inteligente aos pontos fracos do estudante, bateria de testes automatizados e geração do pacote final Android App Bundle (.aab)."*

---

## 3. Diretrizes Técnicas e Pedagógicas da Etapa 4

1. **Gamificação Leve & Aleatória para TDAH:**
   - **Recompensas Aleatórias Intermitentes:** Ao concluir um bloco curto de inglês, o app sorteia mensagens de incentivo cultural em inglês ou conquistas leves ("*Word Master!*"), estimulando a motivação sem punições severas.
   - **Ofensivas Flexíveis e Dashboard Dinâmico:** Atualização em tempo real na `HomeScreen` dos minutos estudados, ofensiva (streak) e total de palavras dominadas.
2. **Adaptação Inteligente aos Pontos Fracos (IA / Recomendação):**
   - Geração e priorização inteligente de simulados e revisões focadas nos termos e estruturas em que o usuário apresentou maior dificuldade (`Rever`), atendendo ao requisito de recurso inteligente previsto na proposta.
3. **Qualidade e Empacotamento Final (`.aab`):**
   - Execução limpa de testes automatizados (`flutter test`) e geração do pacote oficial de publicação Android App Bundle (`.aab`).

---

## 4. Divisão de Responsabilidades na Etapa 4

### 👤 Raquel (Gamificação Leve, IA Adaptativa & Release Final `.aab`)
- **Mecanismo de Gamificação e Dashboard:**
  - Gerador de micro-recompensas aleatórias ao final das sessões de estudo.
  - Conexão dos indicadores da `HomeScreen` e da `TelaPerfil` às métricas reais acumuladas pelo estudante.
- **Adaptação Inteligente de Simulados (IA):**
  - Implementação do serviço/motor de recomendação que analisa o histórico de erros do aluno e monta blocos personalizados para reforçar seus pontos fracos.
- **Build de Produção Android (`.aab`):**
  - Validação com `flutter analyze` sem erros e compilação do pacote final (`flutter build appbundle`).

### 👤 JP (Bateria de Testes Automatizados)
- **Testes Unitários e de Componentes (`test/`):**
  - Substituição do `widget_test.dart` padrão por testes unitários do algoritmo SRS, serialização dos modelos (`CardIngles`, `QuestaoSimulado`, `SrsInterval`) e testes de widgets (`flutter test`).

---

## 5. Critérios de Aceitação e Checklist da Dupla

- [ ] A gamificação é percebida como leve, motivadora e sem elementos que gerem ansiedade ou culpa.
- [ ] O estudante visualiza com clareza o seu progresso no aprendizado de inglês.
- [ ] Todos os testes automatizados executam sem falhas (`flutter test`).
- [ ] O aplicativo é compilado em versão final estável para Android.
- [ ] A documentação do projeto está completa e pronta para avaliação da disciplina.
