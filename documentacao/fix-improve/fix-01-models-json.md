# FIX 01 — Tolerância de Tipos no `fromJson`

## Problema
`CardIngles.fromJson` e `QuestaoSimulado.fromJson` utilizam casts diretos (`as String`, `as int`) que podem lançar exceção de tipo caso o banco remoto retorne campos numéricos ou listas genéricas.

## Arquivos
- `lib/models/card_ingles.dart`
- `lib/models/questao_simulado.dart`

## Ações
1. Em `CardIngles.fromJson`, converter `termo`, `fonetica`, `traducao`, `exemploIngles`, `traducaoExemplo` e `categoria` com `?.toString() ?? ''`.
2. Em `QuestaoSimulado.fromJson`, converter `enunciado` e `explicacao` com `?.toString() ?? ''`, mapear `opcoes`/`alternativas` com `.map((e) => e.toString()).toList()` e interpretar `indiceCorreto` aceitando `num` ou `String`.
3. Adicionar testes unitários validando a desserialização tolerante.
