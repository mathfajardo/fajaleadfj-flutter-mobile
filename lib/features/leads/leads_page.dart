import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/mensagem.dart';
import '../../models/lead.dart';
import '../auth/login_page.dart';
import 'lead_form_page.dart';
import 'widgets/lead_tile.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  List<Lead> _leads = [];
  bool _carregamento = true;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final data = await Api.get('/leads');
      if (!mounted) return;
      setState(() {
        _leads = (data['data'] as List)
            .map((l) => Lead.fromJson(l as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException && e.status == 401) {
        irParaLogin(context);
        return;
      }
      mostrarMensagem(context, 'Erro ao carregar leads', erro: true);
    } finally {
      if (mounted) setState(() => _carregamento = false);
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (mounted) irParaLogin(context);
  }

  Future<void> _abrirForm(Lead lead) async {
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LeadFormPage(lead: lead)),
    );
    if (alterou == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _pesquisa.toLowerCase();
    final filtrados = _leads
        .where(
          (l) =>
              l.nome.toLowerCase().contains(termo) ||
              l.numero.contains(termo) ||
              l.status.toLowerCase().contains(termo),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
                                Icons.person_search_outlined,
                                size: 56,
                                color: AppColors.border,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Nenhum lead encontrado',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const Divider(indent: 72),
                            itemBuilder: (_, i) => LeadTile(
                              lead: filtrados[i],
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
