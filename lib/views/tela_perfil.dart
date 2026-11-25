import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/progresso_controller.dart';
import '../models/sessao_usuario.dart';
import '../repositories/flashcard_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/conquistas_dialog.dart';
import 'home_screen.dart';
import 'tela_decks_ingles.dart';

class _EditarPerfilSheet extends StatefulWidget {
  const _EditarPerfilSheet();

  @override
  State<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends State<_EditarPerfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final sessao = SessaoUsuario.of(context);
    _nome = TextEditingController(text: sessao.nome);
    _email = TextEditingController(text: sessao.email);
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessao = SessaoUsuario.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar perfil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nome completo',
                controller: _nome,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) => (value?.trim().length ?? 0) < 3
                    ? 'Informe um nome com pelo menos 3 caracteres.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'E-mail',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline),
                validator: (value) =>
                    !RegExp(
                      r'^[\w.+-]+@[\w-]+(?:\.[\w-]+)+$',
                    ).hasMatch(value?.trim() ?? '')
                    ? 'Informe um e-mail válido.'
                    : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Salvar alterações',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  try {
                    await sessao.atualizarPerfil(
                      nome: _nome.text,
                      email: _email.text,
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Não foi possível atualizar o perfil.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil atualizado com sucesso!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  void _abrirEdicao(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _EditarPerfilSheet(),
    );
  }

  void _sair(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await SessaoUsuario.of(context).logout();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível concluir a saída.'),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _inicio(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: SessaoUsuario.of(context),
      builder: (context, _) {
        final sessao = SessaoUsuario.of(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _inicio(context),
            ),
            title: const Text('Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configurações',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configurações em breve!')),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              sessao.iniciais,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.card,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _abrirEdicao(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sessao.nome,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sessao.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: .65),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _estatisticas(context, textTheme),
                      const SizedBox(height: 24),
                      _menu(context),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _sair(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sair da conta'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 3,
            backgroundColor: AppColors.card,
            indicatorColor: AppColors.highlight,
            onDestinationSelected: (index) {
              if (index == 0) {
                _inicio(context);
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const TelaDecksIngles(),
                  ),
                );
              } else if (index == 2) {
                mostrarConquistasDialog(context);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Estudos',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Conquistas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _estatisticas(BuildContext context, TextTheme textTheme) {
    final progresso = ProgressoController.of(context, listen: true);
    FlashcardRepository repo;
    try {
      repo = context.read<FlashcardRepository>();
    } on ProviderNotFoundException {
      repo = FlashcardRepository();
    }
    final dominadas = repo.contarDominados();
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context).scale(1);
        final usarWrap = constraints.maxWidth < 300 || textScaler > 1.3;

        final statsWidgets = [
          _stat(
            '🔥',
            formatarDias(progresso.ofensiva),
            progresso.ofensiva == 1 ? 'seguido' : 'seguidos',
            textTheme,
          ),
          _stat(
            '🧠',
            '$dominadas',
            dominadas == 1 ? 'palavra dominada' : 'palavras dominadas',
            textTheme,
          ),
          _stat(
            '⏱️',
            '${progresso.minutosEstudados} min',
            'estudados',
            textTheme,
          ),
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: usarWrap
              ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statsWidgets
                      .map(
                        (w) => ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: w,
                        ),
                      )
                      .toList(),
                )
              : IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var i = 0; i < statsWidgets.length; i++) ...[
                        Expanded(child: statsWidgets[i]),
                        if (i < statsWidgets.length - 1)
                          const VerticalDivider(color: AppColors.border),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _stat(
    String emoji,
    String valor,
    String titulo,
    TextTheme textTheme,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      Text(
        valor,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(titulo, textAlign: TextAlign.center, style: textTheme.bodySmall),
    ],
  );

  Widget _menu(BuildContext context) {
    final items = <({IconData icon, String title, VoidCallback onTap})>[
      (
        icon: Icons.edit_outlined,
        title: 'Editar perfil',
        onTap: () => _abrirEdicao(context),
      ),
      (
        icon: Icons.notifications_none_outlined,
        title: 'Notificações',
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Notificações'),
              content: const Text(
                'Lembretes gentis sem pressão no FocoDeck. Respire e estude no seu próprio ritmo!',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        },
      ),
      (
        icon: Icons.tune_outlined,
        title: 'Preferências',
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Preferências'),
              content: const Text(
                'Preferência padrão de blocos curtos de 5 itens sem cronômetro, ideal para foco e acessibilidade.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
      (
        icon: Icons.badge_outlined,
        title: 'Meus dados',
        onTap: () => _abrirEdicao(context),
      ),
      (
        icon: Icons.help_outline_rounded,
        title: 'Ajuda e suporte',
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ajuda e suporte'),
              content: const Text(
                'Orientações de suporte: FocoDeck foi desenhado para apoiar estudantes de inglês com acessibilidade e acolhimento. Em caso de dúvidas, consulte nossa central de ajuda.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
    ];
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: AppColors.primary),
              title: Text(items[i].title),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: items[i].onTap,
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}
