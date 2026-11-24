# IMPROVE 05 — Sistema de Conquistas e Reconhecimento Positivo (TDAH)

## Objetivo
Reforçar o modelo motivacional do FocoDeck com foco principal em **premiar e registrar permanentemente o que já foi conquistado**, mantendo a ofensiva apenas como indicador secundário e flexível — evitando frustração ou sensação de perda de esforço caso o estudante perca dias de sequência.

## Arquivos
- `lib/services/recompensa_service.dart`
- `lib/models/progresso_estudo.dart`
- `lib/controllers/progresso_controller.dart`
- `lib/widgets/conquistas_dialog.dart`

## Ações
1. **Progresso visual até o próximo marco:** exibir no diálogo de Conquistas quanto falta para cada marco ainda não desbloqueado (ex.: `3 de 5 palavras dominadas para Word Master!`).
2. **Marcos progressivos de esforço acumulado (nunca perdidos):** adicionar marcos de médio e longo prazo baseados em volume total (ex.: 25 e 50 blocos concluídos, 15 e 30 palavras dominadas, 60 e 180 minutos focados), valorizando o histórico permanente acima da ofensiva diária.
3. **Registro das conquistas surpresa e expressões aprendidas:** salvar no progresso do aluno as conquistas surpresa obtidas e uma coleção das expressões culturais em inglês sorteadas, permitindo revisitá-las como reforço positivo.
4. **Destaque secundário para ofensiva:** priorizar visualmente conquistas permanentes, palavras dominadas e blocos concluídos antes da contagem de dias seguidos, reforçando que pausas não apagam o aprendizado.
5. **Preparação para nuvem:** garantir serialização completa desses registros em `ProgressoEstudo.toJson`/`fromJson` para sincronização futura via `ProgressoRepositorySupabase`.
