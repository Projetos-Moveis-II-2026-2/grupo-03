import 'package:flutter/material.dart';

import '../models/sessao_usuario.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    SessaoUsuario.instance.cadastrar(
      nome: _nameController.text,
      email: _emailController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta criada com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Criar sua conta',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dê o primeiro passo para um futuro maior.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'Nome completo',
                          hintText: 'Seu nome',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Informe seu nome completo.';
                            }
                            if (text.length < 3) {
                              return 'O nome deve ter pelo menos 3 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'E-mail',
                          hintText: 'seuemail@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.mail_outline),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Informe seu e-mail.';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(email)) {
                              return 'Informe um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Senha',
                          hintText: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            tooltip: _obscurePassword
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha.';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Confirmar senha',
                          hintText: '••••••••',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            tooltip: _obscureConfirmPassword
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha.';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        AppButton(text: 'Criar conta', onPressed: _submit),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'Ao se cadastrar, você concorda com nossos ',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                      children: const [
                        TextSpan(
                          text: 'Termos de Uso',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' e '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Já tem uma conta?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fazer login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
