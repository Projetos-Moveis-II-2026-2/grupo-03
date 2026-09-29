# Atividade - Etapa 1: Estrutura Base, Autenticação e Design System Minimalista

## 1. Identificação da Atividade

- **Etapa:** 1
- **Título:** Estrutura Base, Autenticação e Design System Minimalista (Baixo Estímulo Cognitivo para TDAH)
- **Dupla Responsável:** **Maria** e **Emily**
- **Status da Etapa:** Concluída com Ressalva Técnica (Persistência Local Pendente)

---

## 2. Escopo da Entrega

> *"Configuração inicial da arquitetura móvel. Implementação do Design System minimalista (visando redução da carga cognitiva) e criação do fluxo de autenticação e gerenciamento de perfil com persistência de sessão local."*

---

## 3. Divisão de Responsabilidades da Dupla

### 👤 Maria (UI/UX, Design System & Fluxos de Entrada)
- Definição da paleta de cores neutras e contrastantes para evitar sobrecarga sensorial em pessoas com TDAH (`lib/theme/app_colors.dart`).
- Configuração do tema global no Material 3 (`lib/theme/app_theme.dart`).
- Criação dos componentes padronizados:
  - Botão de ação padrão com feedback limpo (`lib/widgets/app_button.dart`).
  - Campo de texto estilizado com indicador de foco e mensagens de erro (`lib/widgets/app_text_field.dart`).
- Desenvolvimento das telas de entrada com baixa fricção:
  - Tela de Login com validações de e-mail e senha (`lib/views/login_screen.dart`).
  - Tela de Cadastro com confirmação de senha e atalhos (`lib/views/tela_cadastro.dart`).

### 👤 Emily (Arquitetura Móvel, Home, Perfil & Sessão)
- Configuração inicial do projeto Flutter, árvore de diretórios e dependências (`pubspec.yaml`).
- Desenvolvimento da tela inicial (`lib/views/home_screen.dart`) com métricas de estudo (ofensiva, minutos estudados e cards informativos).
- Desenvolvimento da tela de perfil (`lib/views/tela_perfil.dart`) com avatar, dados do aluno, modal inferior para edição rápida e opção de logout.
- Implementação do gerenciador de sessão (`lib/models/sessao_usuario.dart`) utilizando o padrão Singleton e `ChangeNotifier` para propagar atualizações de dados na árvore de widgets.

---

## 4. Relatório Técnico de Conformidade da Etapa 1

### Módulos Concluídos e Validados:
1. **Arquitetura Base:** Projeto organizado de maneira modular em camadas (`models/`, `views/`, `widgets/`, `theme/`), com suporte multiplataforma e compilação estável.
2. **Design System Minimalista:** Implementado com foco em redução de carga cognitiva, alto contraste (WCAG) e áreas de toque acessíveis.
3. **Fluxos de Autenticação e Perfil:** Telas integradas com navegação funcional entre Login, Cadastro, Home e Perfil com validação de formulários.

### Relato de Pendência Técnica da Etapa 1:
- **Item do Escopo Afetado:** *"persistência de sessão local"*.
- **Diagnóstico Técnico:** A persistência da sessão do usuário foi estruturada em memória volátil (RAM) dentro da classe `SessaoUsuario` (`Map<String, String> _usuariosCadastrados`). Não houve persistência física em disco local (como `shared_preferences`, `sqflite` ou `hive`).
- **Impacto no Sistema:** Ao encerrar o ciclo de vida do processo móvel ou reiniciar o aplicativo, o token de sessão e os dados recém-cadastrados não são retidos no dispositivo, exigindo novo login.
- **Plano de Resolução Técnica:** A equipe definiu que essa persistência não será resolvida com banco local temporário para evitar redundância de código, mas sim na **Etapa 3** através da integração com o **Supabase Auth**, cuja biblioteca cliente gerencia nativamente o armazenamento seguro e persistente de tokens JWT em disco criptografado.
