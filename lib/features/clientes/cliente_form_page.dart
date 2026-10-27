import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/mensagem.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/cliente.dart';
import '../auth/login_page.dart';

class ClienteFormPage extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.cliente?.nome);
  late final _numero = TextEditingController(
    text: widget.cliente == null
        ? null
        : formatarNumero(widget.cliente!.numero),
  );
  late final _plano = TextEditingController(text: widget.cliente?.plano);
  late final _mensalidade = TextEditingController(
    text: widget.cliente?.mensalidade.toStringAsFixed(2).replaceAll('.', ','),
  );
  late final _observacoes = TextEditingController(
    text: widget.cliente?.observacoes,
  );
  late bool _ativo = widget.cliente?.ativo ?? true;
  bool _loading = false;

  bool get _editando => widget.cliente != null;

  @override
  void dispose() {
    _nome.dispose();
    _numero.dispose();
    _plano.dispose();
    _mensalidade.dispose();
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

    final cliente = Cliente(
      nome: _nome.text.trim(),
      numero: _numero.text.replaceAll(RegExp(r'\D'), ''),
      plano: _plano.text.trim(),
      mensalidade: parseValor(_mensalidade.text),
      observacoes: _observacoes.text.trim(),
      ativo: _ativo,
    );

    try {
      final data = _editando
          ? await Api.put('/clientes/${widget.cliente!.id}', cliente.toJson())
          : await Api.post('/clientes', cliente.toJson()..remove('ativo'));
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
        title: const Text('Excluir cliente'),
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
      final data = await Api.delete('/clientes/${widget.cliente!.id}');
      if (!mounted) return;
      mostrarMensagem(
        context,
        data['message']?.toString() ?? 'Deletado com sucesso',
      );
      Navigator.pop(context, true);
    } catch (e) {
      _tratarErro(e, 'Cliente não foi deletado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Novo cliente'),
        actions: [
          if (_editando)
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
                labelText: 'Nome do cliente',
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
            TextFormField(
              controller: _plano,
              validator: _obrigatorio,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Plano',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mensalidade,
              validator: _obrigatorio,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Mensalidade',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.payments_outlined),
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
            if (_editando) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cliente ativo'),
                value: _ativo,
                onChanged: (v) => setState(() => _ativo = v),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _editando ? 'Salvar' : 'Cadastrar',
              loading: _loading,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
