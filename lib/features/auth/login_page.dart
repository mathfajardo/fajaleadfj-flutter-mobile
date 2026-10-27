import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/mensagem.dart';
import '../../core/widgets/primary_button.dart';
import '../home/home_page.dart';

void irParaLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Api.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (_) {
      if (!mounted) return;
      mostrarMensagem(
        context,
        'Erro de autenticação, tente novamente!',
        erro: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/logo_reduzida.png', height: 72),
                    const SizedBox(height: 40),
                    const Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Faça seu login para continuar',
                      style: TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      validator: _obrigatorio,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      validator: _obrigatorio,
                      obscureText: _ocultarSenha,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _ocultarSenha = !_ocultarSenha),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Entrar',
                      loading: _loading,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
