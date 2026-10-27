import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/mensagem.dart';
import '../../models/cliente.dart';
import '../auth/login_page.dart';
import 'cliente_form_page.dart';
import 'widgets/cliente_tile.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  List<Cliente> _clientes = [];
  bool _carregamento = true;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final data = await Api.get('/clientes');
      if (!mounted) return;
      setState(() {
        _clientes = (data['data'] as List)
            .map((c) => Cliente.fromJson(c as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException && e.status == 401) {
        irParaLogin(context);
        return;
      }
      mostrarMensagem(context, 'Erro ao carregar clientes', erro: true);
    } finally {
      if (mounted) setState(() => _carregamento = false);
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (mounted) irParaLogin(context);
  }

  Future<void> _abrirForm([Cliente? cliente]) async {
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
    if (alterou == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _pesquisa.toLowerCase();
    final filtrados = _clientes
        .where(
          (c) =>
              c.nome.toLowerCase().contains(termo) ||
              c.numero.contains(termo) ||
              c.plano.toLowerCase().contains(termo),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo cliente',
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.add),
      ),
      body: _carregamento
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (v) => setState(() => _pesquisa = v),
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregar,
                    child: filtrados.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 64),
                              Icon(
                                Icons.people_outline,
                                size: 56,
                                color: AppColors.border,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Nenhum cliente encontrado',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const Divider(indent: 72),
                            itemBuilder: (_, i) => ClienteTile(
                              cliente: filtrados[i],
                              onTap: () => _abrirForm(filtrados[i]),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
