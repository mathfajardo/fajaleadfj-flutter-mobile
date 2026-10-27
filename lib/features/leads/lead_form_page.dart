import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/mensagem.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/lead.dart';
import '../auth/login_page.dart';

class LeadFormPage extends StatefulWidget {
  final Lead lead;

  const LeadFormPage({super.key, required this.lead});

  @override
  State<LeadFormPage> createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.lead.nome);
  late final _numero = TextEditingController(
    text: formatarNumero(widget.lead.numero),
  );
  late final _observacoes = TextEditingController(
    text: widget.lead.observacoes,
  );
  late String? _status = Lead.statusDisponiveis.contains(widget.lead.status)
      ? widget.lead.status
      : Lead.statusDisponiveis.first;
  bool _loading = false;

  @override
  void dispose() {
    _nome.dispose();
    _numero.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  void _tratarErro(Object e, String mensagem) {
    if (!mounted) return;
    if (e is ApiException && e.status == 401) {
      irParaLogin(context);
      return;
    }
    mostrarMensagem(
      context,
      e is ApiException ? e.message : mensagem,
      erro: true,
    );
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final lead = Lead(
      nome: _nome.text.trim(),
      numero: _numero.text.replaceAll(RegExp(r'\D'), ''),
      status: _status!,
      observacoes: _observacoes.text.trim(),
    );

    try {
      final data = await Api.put('/leads/${widget.lead.id}', lead.toJson());
      if (!mounted) return;
      mostrarMensagem(context, data['message']?.toString() ?? 'Sucesso');
      Navigator.pop(context, true);
    } catch (e) {
      _tratarErro(e, 'Erro na validação');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _excluir() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir lead'),
        content: const Text('Tem certeza que deseja deletar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _loading = true);
    try {
      final data = await Api.delete('/leads/${widget.lead.id}');
      if (!mounted) return;
      mostrarMensagem(
        context,
        data['message']?.toString() ?? 'Deletado com sucesso',
      );
      Navigator.pop(context, true);
    } catch (e) {
      _tratarErro(e, 'Lead não foi deletado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar lead'),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: _loading ? null : _excluir,
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nome,
              validator: _obrigatorio,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome do lead',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numero,
              validator: _obrigatorio,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [NumeroInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Número',
                helperText: 'Digite o número sem o 9 na frente',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              validator: _obrigatorio,
              onChanged: (v) => setState(() => _status = v),
              items: [
                for (final s in Lead.statusDisponiveis)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacoes,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Salvar',
              loading: _loading,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
