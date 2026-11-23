import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sessao_usuario.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RecuperacaoSenha extends StatefulWidget {
  const RecuperacaoSenha({super.key, this.etapa = EtapaRecuperacao.solicitar});
  final EtapaRecuperacao etapa;
  @override
  State<RecuperacaoSenha> createState() => _RecuperacaoSenhaState();
}

class _RecuperacaoSenhaState extends State<RecuperacaoSenha> {
  final formulario = GlobalKey<FormState>();
  final campo = TextEditingController();
  bool enviando = false;
  bool concluido = false;
  String? erro;
  bool get solicitar => widget.etapa == EtapaRecuperacao.solicitar;

  @override
  void dispose() {
    campo.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (enviando || !formulario.currentState!.validate()) return;
    setState(() {
      enviando = true;
      erro = null;
    });
    final sessao = SessaoUsuario.of(context);
    try {
      if (solicitar) {
        await sessao.solicitarRecuperacao(campo.text);
      } else {
        await sessao.redefinirSenha(campo.text);
      }
      if (mounted) setState(() => concluido = true);
    } on AuthException catch (e) {
      if (!mounted) return;
      if (solicitar &&
          {'user_not_found', 'email_not_confirmed'}.contains(e.code)) {
        setState(() => concluido = true);
      } else {
        setState(
          () => erro = switch (e.code) {
            'weak_password' => 'Escolha uma senha mais forte.',
            'same_password' => 'Escolha uma senha diferente da atual.',
            _ =>
              'Não foi possível concluir. Aguarde um momento e tente novamente.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => erro = 'Verifique sua conexão e tente novamente.');
      }
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invalida = widget.etapa == EtapaRecuperacao.invalida;
    return Scaffold(
      appBar: AppBar(title: const Text('FocoDeck')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    solicitar ? 'Recuperar senha' : 'Redefinir senha',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  if (invalida || concluido) ...[
                    Text(
                      invalida
                          ? 'O link é inválido ou expirou. Solicite outro no mesmo navegador.'
                          : solicitar
                          ? 'Se houver uma conta com esse e-mail, você receberá as instruções. Confira também a pasta de spam.'
                          : 'Senha atualizada com sucesso.',
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Continuar',
                      onPressed: () {
                        if (solicitar) {
                          Navigator.pop(context);
                        } else {
                          SessaoUsuario.of(context).concluirRecuperacao();
                        }
                      },
                    ),
                  ] else ...[
                    AppTextField(
                      label: solicitar ? 'E-mail' : 'Nova senha',
                      controller: campo,
                      keyboardType: solicitar
                          ? TextInputType.emailAddress
                          : TextInputType.visiblePassword,
                      obscureText: !solicitar,
                      validator: (v) {
                        if (solicitar) {
                          return RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(v?.trim() ?? '')
                              ? null
                              : 'Informe um e-mail válido.';
                        }
                        return (v ?? '').length >= 6
                            ? null
                            : 'Use pelo menos 6 caracteres.';
                      },
                    ),
                    if (!solicitar) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirmar nova senha',
                        obscureText: true,
                        validator: (v) =>
                            v == campo.text ? null : 'As senhas não coincidem.',
                      ),
                    ],
                    if (erro != null)
                      Text(
                        erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: enviando
                          ? 'Aguarde...'
                          : solicitar
                          ? 'Enviar instruções'
                          : 'Salvar nova senha',
                      onPressed: enviando ? null : enviar,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
