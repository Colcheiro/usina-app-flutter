import 'package:flutter/material.dart';

import '../../models/unidade_medida.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroUnidadeMedida extends StatefulWidget {
  const CadastroUnidadeMedida({super.key});

  @override
  State<CadastroUnidadeMedida> createState() => _CadastroUnidadeMedidaState();
}

class _CadastroUnidadeMedidaState extends State<CadastroUnidadeMedida> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _simboloController = TextEditingController();
  final _service = CrudService<UnidadeMedida>(
    endpoint: ApiConfig.unidadeMedidaEndpoint,
    fromJson: UnidadeMedida.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  final List<UnidadeMedida> _unidades = [];
  bool _carregando = false;
  String? _erro;
  bool _editando = false;
  int? _unidadeMedidaIdEmEdicao;

  @override
  void initState() {
    super.initState();
    _carregarUnidadesMedida();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _simboloController.dispose();
    super.dispose();
  }

  Future<void> _carregarUnidadesMedida() async {
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

    final unidadeMedida = UnidadeMedida(
      id: _unidadeMedidaIdEmEdicao ?? 0,
      nome: _nomeController.text.trim(),
      simbolo: _simboloController.text.trim(),
    );

    try {
      if (_editando && _unidadeMedidaIdEmEdicao != null) {
        final atualizada = await _service.atualizar(_unidadeMedidaIdEmEdicao!, unidadeMedida);
        if (!mounted) return;
        setState(() {
          final index = _unidades.indexWhere((item) => item.id == _unidadeMedidaIdEmEdicao);
          if (index >= 0) _unidades[index] = atualizada;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidade de medida atualizada com sucesso!')),
        );
      } else {
        final criada = await _service.criar(unidadeMedida);
        if (!mounted) return;
        setState(() => _unidades.add(criada));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidade de medida cadastrada com sucesso!')),
        );
      }
      _limparFormulario();
      await _carregarUnidadesMedida();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _excluir(UnidadeMedida unidade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir "${unidade.nome}"?'),
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
      if (_unidadeMedidaIdEmEdicao == unidade.id) _limparFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unidade de medida excluída com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(UnidadeMedida unidade) {
    setState(() {
      _editando = true;
      _unidadeMedidaIdEmEdicao = unidade.id;
      _nomeController.text = unidade.nome;
      _simboloController.text = unidade.simbolo;
    });
  }

  void _limparFormulario() {
    _nomeController.clear();
    _simboloController.clear();
    _editando = false;
    _unidadeMedidaIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Unidade de Medida'),
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
              TextFormField(
                controller: _simboloController,
                decoration: const InputDecoration(
                  labelText: 'Símbolo',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    valor == null || valor.trim().isEmpty ? 'Informe o símbolo' : null,
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
                const Center(child: Text('Nenhuma unidade de medida cadastrada.'))
              else
                ..._unidades.map(
                  (unidade) => Card(
                    child: ListTile(
                      title: Text('${unidade.nome} - ${unidade.simbolo}'),
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
