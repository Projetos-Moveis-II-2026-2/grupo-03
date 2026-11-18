# Pendências de integração — Etapa 3 (Parte 2)

O app consulta as tabelas documentadas `cards_vocabulario` e `questoes_simulado`
pela API REST do Supabase. A configuração do ambiente é feita por
`SUPABASE_URL` e `SUPABASE_ANON_KEY` (`--dart-define`). Sem essas variáveis,
os repositórios preservam os dados embarcados como fallback offline e a UI
mostra uma mensagem amigável quando não houver conteúdo disponível.

## Progresso SRS remoto

A sincronização remota está pendente da integração de backend. A documentação
disponível informa o nome `progresso_srs_usuario` e descreve os dados em termos
gerais, mas não define nomes/tipos das colunas, chave única para upsert, política
RLS nem formato de autenticação. O projeto atual também usa sessão local por
e-mail, sem usuário Supabase autenticado ou JWT. O SRS continua persistido em
SharedPreferences para não perder o progresso. Não foi criada uma gravação
remota especulativa: isso poderia associar dados ao usuário errado ou conflitar
com a RLS.

Para concluir a sincronização, o backend precisa fornecer o esquema SQL real,
constraint única de usuário + cartão/questão e confirmação das políticas RLS;
a autenticação Supabase do app também precisa disponibilizar o UUID/JWT da
sessão ativa.
