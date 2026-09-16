import 'package:flutter/material.dart';

import '../models/sessao_usuario.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  void _abrirEdicao(BuildContext context) {
    final sessao = SessaoUsuario.instance;
    final formKey = GlobalKey<FormState>();
    final nome = TextEditingController(text: sessao.nome);
    final email = TextEditingController(text: sessao.email);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nome completo',
                  controller: nome,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => (value?.trim().length ?? 0) < 3
                      ? 'Informe um nome com pelo menos 3 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'E-mail',
                  controller: email,
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
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    sessao.atualizarPerfil(nome: nome.text, email: email.text);
                    Navigator.pop(sheetContext);
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
      ),
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
            onPressed: () {
              Navigator.pop(dialogContext);
              SessaoUsuario.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (_) => false,
              );
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
      listenable: SessaoUsuario.instance,
      builder: (context, _) {
        final sessao = SessaoUsuario.instance;
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
                      _estatisticas(textTheme),
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
              if (index == 0) _inicio(context);
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

  Widget _estatisticas(TextTheme textTheme) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          _stat('🔥', '4 dias', 'dias seguidos', textTheme),
          const VerticalDivider(color: AppColors.border),
          _stat('⭐', '320 XP', 'experiência', textTheme),
          const VerticalDivider(color: AppColors.border),
          _stat('👏', 'Nível', 'Estudante', textTheme),
        ],
      ),
    ),
  );

  Widget _stat(
    String emoji,
    String valor,
    String titulo,
    TextTheme textTheme,
  ) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        Text(
          valor,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(titulo, style: textTheme.bodySmall),
      ],
    ),
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
        onTap: () {},
      ),
      (icon: Icons.tune_outlined, title: 'Preferências', onTap: () {}),
      (
        icon: Icons.badge_outlined,
        title: 'Meus dados',
        onTap: () => _abrirEdicao(context),
      ),
      (
        icon: Icons.help_outline_rounded,
        title: 'Ajuda e suporte',
        onTap: () {},
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
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
