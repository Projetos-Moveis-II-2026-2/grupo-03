# FIX 04 — Ciclo de Vida no Perfil, Cadastro e Permissão Android

## Problema
- Em `TelaPerfil._abrirEdicao`, os `TextEditingController`s `nome` e `email` são criados dentro do método e nunca descartados (`dispose()`).
- Em `TelaCadastro._submit`, quando `autenticado == true`, o `Navigator.pushReplacement` concorre com a troca automática de `home` via `Consumer<SessaoUsuario>` e `ValueKey` no `main.dart`.
- O `AndroidManifest.xml` não declara `<uses-permission android:name="android.permission.INTERNET"/>`, bloqueando requisições de rede em builds Android de produção.

## Arquivos
- `lib/views/tela_perfil.dart`
- `lib/views/tela_cadastro.dart`
- `android/app/src/main/AndroidManifest.xml`

## Ações
1. Extrair o modal de edição de `TelaPerfil` para `_EditarPerfilSheet extends StatefulWidget` com `dispose()` adequado dos controladores.
2. Em `TelaCadastro._submit`, evitar `Navigator.pushReplacement` redundante quando o app já estiver sob o fluxo reativo do `Consumer<SessaoUsuario>`, mantendo compatibilidade para testes isolados.
3. Adicionar `<uses-permission android:name="android.permission.INTERNET"/>` no `AndroidManifest.xml`.
