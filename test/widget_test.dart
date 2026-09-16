import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_com_api/main.dart';
import 'package:projeto_com_api/models/sessao_usuario.dart';
import 'package:projeto_com_api/views/tela_cadastro.dart';
import 'package:projeto_com_api/views/tela_perfil.dart';

void main() {
  setUp(() {
    SessaoUsuario.instance.cadastrar(
      nome: 'Emily Vitória',
      email: 'emily@email.com',
    );
  });

  testWidgets('FocoDeck inicializa com tela de Login e navega para Cadastro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('FocoDeck'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);

    // Garante que o botão Cadastre-se está visível na rolagem antes do toque
    await tester.ensureVisible(find.text('Cadastre-se'));
    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.text('Criar sua conta'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('TelaCadastro validação de campos vazios', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TelaCadastro()));

    // Tenta submeter formulário em branco
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu nome completo.'), findsOneWidget);
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    expect(find.text('Confirme sua senha.'), findsOneWidget);
  });

  testWidgets('TelaPerfil renderiza dados do usuário, gamificação e menus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TelaPerfil()));

    // Cabeçalho e dados do usuário
    expect(find.text('Emily Vitória'), findsOneWidget);
    expect(find.text('emily@email.com'), findsOneWidget);

    // Gamificação / Estatísticas Rápidas
    expect(find.text('4 dias'), findsOneWidget);
    expect(find.text('320 XP'), findsOneWidget);
    expect(find.text('Nível'), findsOneWidget);
    expect(find.text('Estudante'), findsOneWidget);

    // Itens de Menu
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Preferências'), findsOneWidget);
    expect(find.text('Meus dados'), findsOneWidget);
    expect(find.text('Ajuda e suporte'), findsOneWidget);

    // Botão de Logout e diálogo
    expect(find.text('Sair da conta'), findsOneWidget);
    await tester.ensureVisible(find.text('Sair da conta'));
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(find.text('Deseja realmente sair?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
  });

  testWidgets('TelaPerfil permite editar perfil e salvar alterações com sucesso', (
    WidgetTester tester,
  ) async {
    SessaoUsuario.instance.cadastrar(
      nome: 'Maria Silva',
      email: 'maria@teste.com',
    );
    await tester.pumpWidget(const MaterialApp(home: TelaPerfil()));

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('maria@teste.com'), findsOneWidget);

    // Tocar em Editar perfil
    await tester.ensureVisible(find.text('Editar perfil'));
    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();

    // Modal de edição aberto
    expect(find.text('Salvar alterações'), findsOneWidget);

    // Alterar o nome no campo
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Maria Silva'),
      'Maria Clara',
    );
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    // Perfil atualizado
    expect(find.text('Maria Clara'), findsOneWidget);
    expect(find.text('Perfil atualizado com sucesso!'), findsOneWidget);
  });
}
