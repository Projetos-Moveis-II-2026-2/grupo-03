# Atividade - Etapa 1: Estrutura Base, Autenticação e Design System Minimalista

## 1. Identificação da Atividade

- **Etapa:** 1
- **Título:** Estrutura Base, Autenticação e Design System Minimalista (Baixo Estímulo Cognitivo para TDAH)
- **Dupla Responsável:** **Maria** e **Emily**
- **Status da Etapa:** Concluída (Pendente Persistência em Disco)

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

## 4. Diagnóstico e Revisão Técnica da Etapa 1

### O que foi entregue com sucesso:
1. **Arquitetura Base:** Projeto organizado modularmente em pastas (`models/`, `views/`, `widgets/`, `theme/`).
2. **Design System:** Implementado e aderente à proposta de redução da carga cognitiva.
3. **Autenticação e Perfil:** Telas integradas com navegação funcional entre Login, Cadastro, Home e Perfil.

### Pendência identificada:
1. **Persistência de Sessão Local em Disco:**
   - Atualmente, os dados da sessão (`SessaoUsuario`) residem unicamente em **memória RAM** (`Map<String, String> _usuariosCadastrados`).
   - Ao fechar o aplicativo ou recarregar a sessão, os dados cadastrados e o login são redefinidos.
   - **Encaminhamento:** Será resolvido definitivamente na Etapa 3 com o **Supabase Auth**, que implementa persistência de sessão segura via token JWT em disco.
