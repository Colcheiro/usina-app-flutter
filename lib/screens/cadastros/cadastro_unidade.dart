import 'package:flutter/material.dart';

import '../../models/unidade.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroUnidade extends StatefulWidget {
  const CadastroUnidade({super.key});

  @override
  State<CadastroUnidade> createState() => _CadastroUnidadeState();
}

class _CadastroUnidadeState extends State<CadastroUnidade> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _service = CrudService<Unidade>(
    endpoint: ApiConfig.unidadeEndpoint,
    fromJson: Unidade.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  final List<Unidade> _unidades = [];
  bool _carregando = false;
  String? _erro;
  bool _editando = false;
  int? _unidadeIdEmEdicao;

  @override
  void initState() {
    super.initState();
    _carregarUnidades();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarUnidades() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    try {
      final itens = await _service.listar();
      if (!mounted) return;
      setState(() {
        _unidades
          ..clear()
          ..addAll(itens);
        _erro = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _erro = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final unidade = Unidade(
      id: _unidadeIdEmEdicao ?? 0,
      nome: _nomeController.text.trim(),
    );

    try {
      if (_editando && _unidadeIdEmEdicao != null) {
        final atualizada = await _service.atualizar(_unidadeIdEmEdicao!, unidade);
        if (!mounted) return;
        setState(() {
          final index = _unidades.indexWhere((item) => item.id == _unidadeIdEmEdicao);
          if (index >= 0) _unidades[index] = atualizada;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidade atualizada com sucesso!')),
        );
      } else {
        final criada = await _service.criar(unidade);
        if (!mounted) return;
        setState(() => _unidades.add(criada));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidade cadastrada com sucesso!')),
        );
      }
      _limparFormulario();
      await _carregarUnidades();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _excluir(Unidade unidade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir a unidade "${unidade.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _service.excluir(unidade.id);
      if (!mounted) return;
      setState(() => _unidades.removeWhere((item) => item.id == unidade.id));
      if (_unidadeIdEmEdicao == unidade.id) _limparFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unidade excluída com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(Unidade unidade) {
    setState(() {
      _editando = true;
      _unidadeIdEmEdicao = unidade.id;
      _nomeController.text = unidade.nome;
    });
  }

  void _limparFormulario() {
    _nomeController.clear();
    _editando = false;
    _unidadeIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Unidade'),
        actions: [
          if (_editando)
            IconButton(
              onPressed: _limparFormulario,
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar edição',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    valor == null || valor.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(_editando ? 'Atualizar' : 'Salvar'),
              ),
              const SizedBox(height: 16),
              if (_carregando)
                const Center(child: CircularProgressIndicator())
              else if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red))
              else if (_unidades.isEmpty)
                const Center(child: Text('Nenhuma unidade cadastrada.'))
              else
                ..._unidades.map(
                  (unidade) => Card(
                    child: ListTile(
                      title: Text(unidade.nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(unidade),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(unidade),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
