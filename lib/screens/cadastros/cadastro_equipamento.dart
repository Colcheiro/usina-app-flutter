import 'package:flutter/material.dart';

import '../../models/equipamento.dart';
import '../../models/unidade.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroEquipamento extends StatefulWidget {
  const CadastroEquipamento({super.key});

  @override
  State<CadastroEquipamento> createState() => _CadastroEquipamentoState();
}

class _CadastroEquipamentoState extends State<CadastroEquipamento> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _equipamentoService = CrudService<Equipamento>(
    endpoint: ApiConfig.equipamentoEndpoint,
    fromJson: Equipamento.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );
  final _unidadeService = CrudService<Unidade>(
    endpoint: ApiConfig.unidadeEndpoint,
    fromJson: Unidade.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  final List<Equipamento> _equipamentos = [];
  final List<Unidade> _unidades = [];
  Unidade? _unidadeSelecionada;
  bool _carregando = false;
  bool _editando = false;
  int? _equipamentoIdEmEdicao;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    try {
      final unidades = await _unidadeService.listar();
      final equipamentos = await _equipamentoService.listar();
      if (!mounted) return;
      setState(() {
        _unidades
          ..clear()
          ..addAll(unidades);
        _equipamentos
          ..clear()
          ..addAll(equipamentos);
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
    if (!_formKey.currentState!.validate() || _unidadeSelecionada == null) return;

    final equipamento = Equipamento(
      id: _equipamentoIdEmEdicao ?? 0,
      nome: _nomeController.text.trim(),
      unidade: _unidadeSelecionada!,
    );

    try {
      if (_editando && _equipamentoIdEmEdicao != null) {
        final atualizada = await _equipamentoService.atualizar(_equipamentoIdEmEdicao!, equipamento);
        if (!mounted) return;
        setState(() {
          final index = _equipamentos.indexWhere((item) => item.id == _equipamentoIdEmEdicao);
          if (index >= 0) _equipamentos[index] = atualizada;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento atualizado com sucesso!')),
        );
      } else {
        final criada = await _equipamentoService.criar(equipamento);
        if (!mounted) return;
        setState(() => _equipamentos.add(criada));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento cadastrado com sucesso!')),
        );
      }
      _limparFormulario();
      await _carregarDados();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _excluir(Equipamento equipamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir o equipamento "${equipamento.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _equipamentoService.excluir(equipamento.id);
      if (!mounted) return;
      setState(() => _equipamentos.removeWhere((item) => item.id == equipamento.id));
      if (_equipamentoIdEmEdicao == equipamento.id) _limparFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipamento excluído com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(Equipamento equipamento) {
    setState(() {
      _editando = true;
      _equipamentoIdEmEdicao = equipamento.id;
      _nomeController.text = equipamento.nome;
      _unidadeSelecionada = equipamento.unidade;
    });
  }

  void _limparFormulario() {
    _nomeController.clear();
    _unidadeSelecionada = null;
    _editando = false;
    _equipamentoIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Equipamento'),
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
              DropdownButtonFormField<Unidade>(
                initialValue: _unidadeSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Unidade',
                  border: OutlineInputBorder(),
                ),
                items: _unidades
                    .map(
                      (unidade) => DropdownMenuItem(
                        value: unidade,
                        child: Text(unidade.nome),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => _unidadeSelecionada = valor),
                validator: (valor) => valor == null ? 'Selecione a unidade' : null,
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
              else if (_equipamentos.isEmpty)
                const Center(child: Text('Nenhum equipamento cadastrado.'))
              else
                ..._equipamentos.map(
                  (equipamento) => Card(
                    child: ListTile(
                      title: Text(equipamento.nome),
                      subtitle: Text(equipamento.unidade.nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(equipamento),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(equipamento),
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
