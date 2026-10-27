import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/widgets/mensagem.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/login_page.dart';

class PromptPage extends StatefulWidget {
  const PromptPage({super.key});

  @override
  State<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  final _form = GlobalKey<FormState>();
  final _mensagem = TextEditingController();
  int? _id;
  bool _carregamento = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _mensagem.dispose();
    super.dispose();
  }

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

  Future<void> _carregar() async {
    try {
      final data = await Api.get('/prompt');
      final lista = data['data'] as List;
      if (!mounted || lista.isEmpty) return;
      final prompt = lista.first as Map<String, dynamic>;
      _id = prompt['id'] as int;
      _mensagem.text = prompt['mensagem']?.toString() ?? '';
    } catch (e) {
      _tratarErro(e, 'Erro ao carregar prompt');
    } finally {
      if (mounted) setState(() => _carregamento = false);
    }
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final body = {'mensagem': _mensagem.text};

    try {
      final data = _id == null
          ? await Api.post('/prompt', body)
          : await Api.put('/prompt/$_id', body);
      if (!mounted) return;
      _id ??= data['data']['id'] as int;
      mostrarMensagem(context, data['message']?.toString() ?? 'Sucesso');
    } catch (e) {
      _tratarErro(e, 'Erro na validação');
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Prompt'),
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
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mensagem,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Prompt da IA',
                          hintText: 'Digite aqui o prompt...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Atualizar prompt',
                      loading: _loading,
                      onPressed: _salvar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
