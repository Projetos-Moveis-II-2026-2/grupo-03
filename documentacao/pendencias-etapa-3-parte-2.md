# Etapa 3 – Parte 2: repositórios assíncronos e resiliência

## Implementado

- `FlashcardRepository` consulta `cards_vocabulario` e converte linhas com `CardIngles.fromJson`.
- `QuestaoRepository` consulta `questoes_simulado` e converte linhas com `QuestaoSimulado.fromJson`.
- Os dados embarcados continuam como fallback offline. O conteúdo remoto válido fica em cache em memória durante a sessão; falhas e respostas vazias não apagam esse cache.
- Cada repositório compartilha uma requisição em andamento, inclusive quando uma atualização explícita é solicitada. `carregar(atualizar: true)` força nova consulta quando não há requisição em andamento.
- As telas mostram carregamento inicial, mantêm o conteúdo disponível enquanto atualizam, exibem erro quando não há conteúdo e oferecem “Tentar novamente”. O retry chama o repositório com `atualizar: true`.
- Os intervalos SRS dos flashcards e das questões permanecem em `SharedPreferences`. O progresso geral de estudo também permanece local, serializado por `ProgressoRepositoryLocal`.
- Os intervalos SRS locais usam atualmente chaves gerais por tipo de conteúdo, não uma chave por conta; portanto, em um dispositivo compartilhado, contas diferentes compartilham esses intervalos até que o armazenamento seja migrado para escopo por UUID.

## Integração Supabase e autenticação

`main.dart` inicializa Supabase com `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`. `ConteudoApi` usa o mesmo `SupabaseClient`, sua URL e chave pública para PostgREST. Se há sessão Supabase ativa, o cabeçalho `Authorization` usa o access token dessa sessão; sem sessão, usa a chave pública. Login, cadastro e recuperação de senha usam Supabase Auth em `SessaoUsuario`.

Execute o app fornecendo os valores do projeto por `--dart-define=SUPABASE_URL=...` e `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. São os dados públicos de conexão do projeto; não inclua `service_role`, senhas ou tokens em código, documentação ou logs.

## Sincronização SRS remota pendente

Não foi implementada gravação ou leitura de `progresso_srs_usuario`: o repositório disponível só cita o nome da tabela e descreve os dados em termos gerais. Não há no workspace SQL/migração do schema, tipos de colunas, relacionamentos, constraint única, políticas RLS nem permissões efetivas para verificar. A autenticação real já existe; `SessaoUsuario.id` vem do UUID do usuário em `Supabase.instance.client.auth.currentSession`, e o cliente Supabase mantém o JWT de acesso.

Antes de sincronizar, o backend precisa fornecer/verificar:

1. O DDL vigente de `progresso_srs_usuario`, com colunas, tipos, chaves estrangeiras e semântica para flashcard versus questão.
2. Uma constraint única adequada ao usuário e ao identificador estável do item (incluindo tipo de item, se a tabela guardar ambos), necessária para upsert.
3. RLS habilitada e políticas de leitura, inserção e atualização que restrinjam cada linha ao UUID autenticado (`auth.uid()`), além das permissões correspondentes.
4. Confirmação de que IDs de flashcards e questões são estáveis e correspondem às chaves usadas pelo schema.
5. A regra de resolução de conflitos para não substituir uma revisão mais recente por uma cópia offline antiga.

Depois dessas confirmações, a sincronização deve manter SharedPreferences como cache offline, usar somente o usuário autenticado e tratar falhas de rede, autenticação e autorização sem apagar o progresso local. Até lá, SRS segue apenas local; a sessão Supabase existente não torna seguro inferir colunas ou políticas.

## Validação

Os testes de repositório usam uma implementação controlada de `ConteudoApi`, sem depender de um projeto Supabase real. Verificam conversão, retry, deduplicação, fallback e preservação do cache, além da persistência local de intervalos SRS.
