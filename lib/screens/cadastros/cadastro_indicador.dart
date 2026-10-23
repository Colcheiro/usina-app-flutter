import 'package:flutter/material.dart';

import '../../models/indicador.dart';
import '../../services/indicador_service.dart';

class CadastroIndicador extends StatefulWidget {
  const CadastroIndicador({super.key});

  @override
  State<CadastroIndicador> createState() => _CadastroIndicadorState();
}

class _CadastroIndicadorState extends State<CadastroIndicador> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _urlController = TextEditingController();
  final _service = IndicadorService();
  List<Indicador> _indicadores = [];
  Indicador? _emEdicao;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final itens = await _service.listar();
      if (mounted) setState(() => _indicadores = itens);
    } catch (error) {
      if (mounted) setState(() => _erro = _mensagem(error));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _editar(Indicador indicador) {
    setState(() {
      _emEdicao = indicador;
      _nomeController.text = indicador.nome;
      _descricaoController.text = indicador.descricao;
      _urlController.text = indicador.url;
      _erro = null;
    });
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _urlController.clear();
    setState(() => _emEdicao = null);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final estavaEditando = _emEdicao != null;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final indicador = Indicador(
      id: _emEdicao?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      url: _urlController.text.trim(),
    );
    try {
      if (_emEdicao?.id == null) {
        await _service.criar(indicador);
      } else {
        await _service.atualizar(_emEdicao!.id!, indicador);
      }
      _limparFormulario();
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              estavaEditando
                  ? 'Indicador atualizado com sucesso.'
                  : 'Indicador salvo com sucesso.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _erro = _mensagem(error));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(Indicador indicador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir indicador'),
        content: Text('Deseja excluir “${indicador.nome}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || indicador.id == null) return;
    try {
      await _service.excluir(indicador.id!);
      if (_emEdicao?.id == indicador.id) _limparFormulario();
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Indicador excluído.')));
      }
    } catch (error) {
      if (mounted) setState(() => _erro = _mensagem(error));
    }
  }

  String _mensagem(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String? _validarUrl(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a URL.';
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme.toLowerCase())) {
      return 'Informe uma URL válida começando com http:// ou https://.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editando = _emEdicao != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Indicadores')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        editando ? 'Editar indicador' : 'Novo indicador',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe o nome.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe a descrição.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'URL',
                          hintText: 'https://exemplo.com',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validarUrl,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _salvando ? null : _salvar,
                            icon: _salvando
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              editando ? 'Salvar alterações' : 'Cadastrar',
                            ),
                          ),
                          if (editando)
                            TextButton(
                              onPressed: _limparFormulario,
                              child: const Text('Cancelar edição'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              MaterialBanner(
                content: Text(_erro!),
                leading: const Icon(Icons.error_outline),
                actions: [
                  TextButton(
                    onPressed: _carregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Indicadores cadastrados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_indicadores.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Nenhum indicador cadastrado.'),
              )
            else
              ..._indicadores.map(
                (indicador) => Card(
                  child: ListTile(
                    title: Text(indicador.nome),
                    subtitle: Text('${indicador.descricao}\n${indicador.url}'),
                    isThreeLine: true,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/indicador',
                      arguments: indicador,
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => _editar(indicador),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => _excluir(indicador),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
