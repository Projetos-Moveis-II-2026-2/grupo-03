import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A tipografia e o fundo são herdados do AppTheme do aplicativo.
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, estudante! 👋',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vamos manter o foco hoje?',
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.card,
                          semanticLabel: 'Perfil',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _AdaptivePair(
                    first: _HomeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔥 7 dias',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sequência de estudos',
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    second: _HomeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meta diária', style: textTheme.titleLarge),
                          const SizedBox(height: 12),
                          const Text('3 de 5 revisões concluídas'),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.success,
                            backgroundColor: AppColors.border,
                            semanticsLabel: 'Meta diária',
                            semanticsValue: '60%',
                          ),
                          const SizedBox(height: 12),
                          const Text('Você está quase lá!'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.style_outlined,
                                size: 40,
                                color: AppColors.highlight,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Revisão de hoje',
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColors.card,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '12 flashcards esperando por você',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.card,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: AppButton(
                            text: 'Começar agora',
                            onPressed: () {
                              // A revisão será implementada em outra etapa.
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Continuar estudando',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _AdaptivePair(
                    first: _StudyCard(
                      title: 'Flashcards',
                      subtitle: 'Revise seus conteúdos',
                      icon: Icons.style_outlined,
                      accent: AppColors.primary,
                    ),
                    second: _StudyCard(
                      title: 'Simulados',
                      subtitle: 'Teste seus conhecimentos',
                      icon: Icons.quiz_outlined,
                      accent: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Seu progresso',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _HomeCard(
                    child: Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      children: [
                        _ProgressItem(value: '24', label: 'revisões'),
                        _ProgressItem(value: '85%', label: 'de acertos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.highlight,
        elevation: 0,
        onDestinationSelected: (_) {
          // A navegação será integrada quando as telas estiverem disponíveis.
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Estudos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _AdaptivePair extends StatelessWidget {
  const _AdaptivePair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(children: [first, const SizedBox(height: 16), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 32),
          const SizedBox(height: 16),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: textTheme.bodyLarge),
      ],
    );
  }
}
