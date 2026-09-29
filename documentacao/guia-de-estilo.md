# Guia de Estilo e Padrão Visual (Design System) - FocoDeck

Este documento define as diretrizes visuais oficiais do **FocoDeck** (cores, tipografia, espaçamentos, componentes e regras de layout). Ele serve como referência obrigatória para todas as duplas manterem a consistência visual do aplicativo nas próximas etapas.

---

## 1. Paleta de Cores Oficial

As cores do FocoDeck foram selecionadas para proporcionar **baixo estímulo sensorial e alta legibilidade**, minimizando a sobrecarga cognitiva e fadiga visual de pessoas com TDAH.

Todas as constantes estão declaradas em [`lib/theme/app_colors.dart`](file:///c:/Users/joaop/Documents/UNITINS/MOBILE%202/lib/theme/app_colors.dart).

| Identificador | Hexadecimal | Cor / Amostra | Função / Caso de Uso |
| :--- | :---: | :---: | :--- |
| `AppColors.primary` | `#6C4DFF` | 🟣 Roxo Foco | Cor principal de destaque da marca, botões de ação primária (CTA), borda de campos em foco e ícones ativos. |
| `AppColors.highlight` | `#FFD84D` | 🟡 Amarelo Alerta/Realce | Marcador de atenção suave, barras de ênfase visual, conquistas e indicadores de alerta moderado. |
| `AppColors.success` | `#39B980` | 🟢 Verde Sucesso | Feedback de acerto em quiz/simulados, confirmação de metas cumpridas e ofensiva (streak). |
| `AppColors.error` | `#E85D68` | 🔴 Vermelho Erro | Mensagens de validação de formulários, erros de conexão e sinalização de vocábulos que precisam de revisão. |
| `AppColors.background` | `#F7F7FC` | ⚪ Cinza-Gelo Suave | Cor de fundo oficial das telas (`Scaffold`). Evita o branco puro (#FFFFFF) para não cansar a visão do usuário. |
| `AppColors.card` | `#FFFFFF` | ⬜ Branco Puro | Fundo de cartões de conteúdo, flashcards, inputs e modais, criando contraste sutil com o fundo. |
| `AppColors.textPrimary` | `#20202A` | ⚫ Grafite Escuro | Cor padrão dos textos e títulos. Oferece alto contraste (WCAG AAA) sem a agressividade do preto puro (#000000). |
| `AppColors.border` | `#E4E1E6` | 🔘 Cinza Claro de Borda | Linhas divisórias, contornos sutis de cards e bordas padrão de campos de texto desabilitados ou inativos. |

---

## 2. Tipografia e Fontes

O FocoDeck utiliza o motor tipográfico do **Material 3**, baseado nas fontes nativas do sistema operacional (**Roboto** no Android/Web e **SF Pro** no iOS), garantindo carregamento instantâneo e legibilidade comprovada.

A configuração base está centralizada em [`lib/theme/app_theme.dart`](file:///c:/Users/joaop/Documents/UNITINS/MOBILE%202/lib/theme/app_theme.dart).

### 2.1. Escala Tipográfica Padronizada

| Estilo TextTheme | Peso (`FontWeight`) | Tamanho Aprox. | Aplicação no FocoDeck |
| :--- | :---: | :---: | :--- |
| `displaySmall` | `FontWeight.w800` (Extra Bold) | 36 sp | Logotipo "FocoDeck" e números grandes de impacto (ex: pontuação final do bloco). |
| `headlineSmall` | `FontWeight.bold` (Bold) | 24 sp | Títulos principais de tela (ex: "Olá, estudante! 👋", "Bons estudos começam aqui"). |
| `titleLarge` | `FontWeight.w600` (Semi Bold) | 20 sp | Títulos de seções, cabeçalhos de modais (ex: "Editar perfil") e termos de flashcards. |
| `bodyLarge` | `FontWeight.normal` (Regular) | 16 sp | Frases contextuais de apoio, enunciados de simulados e alternativas de resposta. |
| `bodyMedium` | `FontWeight.normal` (Regular) | 14 sp | Textos secundários, legendas de status, dicas de estudo e instruções de inputs. |
| `labelLarge` | `FontWeight.w600` (Semi Bold) | 14 sp | Textos internos de botões de ação (`AppButton`). |

### 2.2. Diretrizes de Texto para TDAH
- **Frases Curtas e Diretas:** Evitar parágrafos longos com mais de 3 linhas contínuas.
- **Hierarquia Visual Nítida:** Diferenciação clara entre títulos em negrito e corpos de texto regulares.
- **Espaçamento entre Linhas Confortável:** Facilitar a fixação visual da leitura rápida de vocábulos em inglês.

---

## 3. Padrão de Layout e Espaçamentos

### 3.1. Grid e Limites de Responsividade (Max Width)
Para manter a experiência focada e evitar que o conteúdo se espalhe excessivamente em telas maiores (tablets, navegadores ou celulares na horizontal):

```dart
// Padrão para telas de foco único (Login, Cadastro, Sessão de Flashcard)
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 420),
  child: ...
)

// Padrão para telas de painel/dashboard (HomeScreen)
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 960),
  child: ...
)
```

### 3.2. Espaçamentos Verticais e Horizontais (Escala de 4/8px)

| Espaçamento | Valor | Aplicação Recomendada |
| :---: | :---: | :--- |
| **Micro** | `8px` | Distância entre um título e seu subtítulo; espaçamento entre ícone e texto. |
| **Pequeno** | `12px` | Separação entre elementos agrupados ou itens de uma mesma lista. |
| **Médio** | `16px` | Espaçamento padrão entre campos de formulário (`AppTextField`). |
| **Padrão de Tela** | `24px` | Padding externo obrigatório de todas as telas (`EdgeInsets.all(24)`). |
| **Grande** | `28px` a `32px` | Separação entre grandes blocos de conteúdo da tela (ex: saudação e cards). |
| **Macro** | `40px` a `48px` | Separação entre a área do logotipo/hero e o formulário principal. |

---

## 4. Padrão de Componentes Visuais

### 4.1. Botões de Ação (`AppButton`)
- **Arquivo:** [`lib/widgets/app_button.dart`](file:///c:/Users/joaop/Documents/UNITINS/MOBILE%202/lib/widgets/app_button.dart)
- **Altura padrão:** Fixa em `52px` (área de toque confortável para dedos em telas móveis).
- **Largura padrão:** `double.infinity` (ocupa 100% da largura do contêiner).
- **Arredondamento:** `BorderRadius.circular(14)`.
- **Cores:** Fundo `AppColors.primary`, texto `AppColors.card` (branco).
- **Elevação:** `0` (Design Flat, sem sombras volumosas que poluam a tela).

### 4.2. Campos de Texto (`AppTextField`)
- **Arquivo:** [`lib/widgets/app_text_field.dart`](file:///c:/Users/joaop/Documents/UNITINS/MOBILE%202/lib/widgets/app_text_field.dart)
- **Fundo:** Preenchimento sólido branco (`AppColors.card`).
- **Padding interno:** `EdgeInsets.symmetric(horizontal: 16, vertical: 16)`.
- **Borda Inativa:** `BorderRadius.circular(14)` com linha fina de `1px` em `AppColors.border`.
- **Borda em Foco:** Linha de `2px` em `AppColors.primary` (indica claramente ao usuário com TDAH onde está o cursor).
- **Borda de Erro:** Linha de `2px` em `AppColors.error`.

### 4.3. Cartões de Conteúdo e Flashcards (`Cards`)
- **Cor de Fundo:** `AppColors.card` (#FFFFFF).
- **Arredondamento de Cantos:** `BorderRadius.circular(20)`.
- **Contorno Sutil:** Borda de `1.5px` sólida na cor `AppColors.border`.
- **Padding Interno:** `EdgeInsets.all(20)` a `EdgeInsets.all(24)`.
- **Interação:** Feedback de clique sutil com `InkWell` respeitando o mesmo `borderRadius`.

### 4.4. Modais Inferiores (`ModalBottomSheet`)
- **Arredondamento superior:** `BorderRadius.vertical(top: Radius.circular(24))`.
- **Fundo:** `AppColors.card`.
- **Ajuste de teclado:** Padding dinâmico com `MediaQuery.of(context).viewInsets.bottom`.

---

## 5. Regras de Ouro para Novas Telas (Etapas 2, 3 e 4)

1. **Nunca use cores fora da paleta oficial:** Sempre importe `app_colors.dart`. Se uma nova cor semântica for estritamente necessária, adicione-a como constante no arquivo de cores.
2. **Priorize Respiro Visual:** Deixe áreas livres ao redor dos cards de inglês. Telas congestionadas causam ansiedade e abandono por usuários neurodivergentes.
3. **Sem Animações Infinitas ou Elementos Pulsantes:** Animações devem ser restritas à transição de virada de cartão (flip) ou conclusão de bloco, sempre rápidas (200ms a 300ms).
4. **Alinhamento Centralizado em Formulários:** Formulários de estudo devem sempre ficar centralizados verticalmente ou no topo com rolagem suave (`SingleChildScrollView`).
