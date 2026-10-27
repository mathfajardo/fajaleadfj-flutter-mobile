import 'package:flutter/material.dart';

import 'core/api/api.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/clientes/clientes_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FajaLead',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _Inicio(),
    );
  }
}

class _Inicio extends StatefulWidget {
  const _Inicio();

  @override
  State<_Inicio> createState() => _InicioState();
}

class _InicioState extends State<_Inicio> {
  late final Future<bool> _logado = Api.verificaToken();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _logado,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Image.asset('assets/logo_reduzida.png', height: 72),
            ),
          );
        }
        return snapshot.data! ? const ClientesPage() : const LoginPage();
      },
    );
  }
}
