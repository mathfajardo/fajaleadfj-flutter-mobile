import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/mensagem.dart';
import '../auth/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<int> _totais = [0, 0, 0, 0];
  bool _carregamento = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final respostas = await Future.wait([
        Api.get('/leadsMes'),
        Api.get('/clientesMes'),
        Api.get('/clientesTotal'),
        Api.get('/clientesAtivosTotal'),
      ]);
      if (!mounted) return;
      setState(() {
        _totais = respostas.map((r) => r['data']['total'] as int).toList();
      });
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException && e.status == 401) {
        irParaLogin(context);
        return;
      }
      mostrarMensagem(context, 'Erro ao carregar dashboard', erro: true);
    } finally {
      if (mounted) setState(() => _carregamento = false);
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (mounted) irParaLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
          : RefreshIndicator(
              onRefresh: _carregar,
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _Card(
                    titulo: 'Leads no mês',
                    total: _totais[0],
                    icone: Icons.people_outline,
                    cor: const Color(0xFF3B82F6),
                  ),
                  _Card(
                    titulo: 'Clientes no mês',
                    total: _totais[1],
                    icone: Icons.work_outline,
                    cor: const Color(0xFF22C55E),
                  ),
                  _Card(
                    titulo: 'Clientes no total',
                    total: _totais[2],
                    icone: Icons.badge_outlined,
                    cor: const Color(0xFFA855F7),
                  ),
                  _Card(
                    titulo: 'Clientes ativos no total',
                    total: _totais[3],
                    icone: Icons.check_circle_outline,
                    cor: const Color(0xFFF97316),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  final String titulo;
  final int total;
  final IconData icone;
  final Color cor;

  const _Card({
    required this.titulo,
    required this.total,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const Spacer(),
          Text(
            '$total',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
