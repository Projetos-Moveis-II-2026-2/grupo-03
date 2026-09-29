# Atividade - Etapa 3: Conexão com Supabase e API REST de Conteúdo em Inglês

## 1. Identificação da Atividade

- **Etapa:** 3
- **Título:** Conexão com Banco Remoto (Supabase Online) e Consumo de API REST para Conteúdos de Inglês
- **Dupla Responsável:** **Maria** e **Emily**
- **Status da Etapa:** Aguardando Conclusão da Etapa 2

---

## 2. Escopo da Entrega

> *"Conexão do aplicativo móvel com o banco de dados remoto consumindo uma API REST. Compreende o carregamento dinâmico das questões, tratamento assíncrono, estruturação de requisições web e gerenciamento de erros (conexão e carregamento)."*

---

## 3. Arquitetura de Dados no Supabase (Online)

O banco de dados relacional (PostgreSQL no Supabase) conterá a base estruturada para o ensino de inglês:

1. **Tabelas do Domínio de Inglês:**
   - `decks_ingles`: Baralhos categorizados por temas (ex: *Daily Routine*, *Travel Essentials*, *Job Interview*).
   - `cards_vocabulario`: Termo em inglês, pronúncia fonética, tradução, frase de exemplo em inglês e tradução da frase.
   - `questoes_simulado`: Perguntas de múltipla escolha para reforço e fixação.
   - `progresso_srs_usuario`: Registros de histórico da repetição espaçada por usuário (palavra, intervalo atual, próximo dia de revisão e taxa de acerto).
2. **Autenticação & Segurança (Supabase Auth & RLS):**
   - Políticas de segurança para que o progresso do estudante seja privado e sincronizado entre dispositivos.

---

## 4. Divisão de Responsabilidades da Dupla

### 👤 Emily (Infraestrutura Supabase, Modelagem & Endpoints REST)
- **Configuração do Projeto no Supabase:** Criação do banco, tabelas relacionais de inglês, tipos ENUM e inserção de dados iniciais de vocabulário (seed data).
- **Desenvolvimento do Cliente de API / Supabase Client:**
  - Configuração do cliente Supabase no Flutter (`supabase_flutter` ou endpoints via `Dio`).
  - Métodos para buscar decks de inglês, listar cartões de um deck e submeter histórico de estudo do usuário.
- **Autenticação Real:** Vinculação do Login/Cadastro com o Supabase Auth, garantindo a persistência duradoura da sessão do usuário.

### 👤 Maria (Consumo Assíncrono, Repositórios & UX Resiliente)
- **Camada de Repositório (`repositories/`):**
  - Isolamento das chamadas REST das telas do aplicativo.
  - Conversão de JSON para objetos Dart `CardIngles` e `QuizQuestao`.
- **Tratamento de Conexão & Carga Cognitiva:**
  - Implementação de estados visuais leves de carregamento (*skeleton screens* ou animações discretas).
  - Tratamento de falhas de conexão de forma clara e reconexão em 1 clique ("Sem internet no momento. Tentar novamente").
- **Estratégia de Cache de Estudo:**
  - Armazenamento em memória do bloco atual para que oscilações de sinal não interrompam a sessão de estudo em andamento.

---

## 5. Critérios de Aceitação e Checklist da Dupla

- [ ] Os decks e vocabulários de inglês são alimentados dinamicamente a partir do banco online no Supabase.
- [ ] O app consome a API de forma 100% assíncrona, sem travamento de quadros na interface.
- [ ] O progresso de repetição espaçada do estudante é salvo e sincronizado na nuvem.
- [ ] Mensagens de erro de rede são amigáveis e não frustram a experiência do usuário.
