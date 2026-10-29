import 'package:flutter/material.dart';

import '../../models/safra.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroSafra extends StatefulWidget {
  const CadastroSafra({super.key});

  @override
  State<CadastroSafra> createState() => _CadastroSafraState();
}

class _CadastroSafraState extends State<CadastroSafra> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _service = CrudService<Safra>(
    endpoint: ApiConfig.safraEndpoint,
    fromJson: Safra.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  DateTime? _dataInicio;
  DateTime? _dataFim;
  final List<Safra> _safras = [];
  bool _carregando = false;
  String? _erro;
  bool _editando = false;
  int? _safraIdEmEdicao;

  @override
  void initState() {
    super.initState();
    _carregarSafras();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarSafras() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    try {
      final safraList = await _service.listar();
      if (!mounted) return;
      setState(() {
        _safras
          ..clear()
          ..addAll(safraList);
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

  Future<void> _selecionarData(bool inicio) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data == null || !mounted) return;
    setState(() {
      if (inicio) {
        _dataInicio = data;
      } else {
        _dataFim = data;
      }
    });
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecione uma data';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _dataInicio == null || _dataFim == null) {
      return;
    }
    if (_dataFim!.isBefore(_dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data final não pode ser anterior à data inicial.')),
      );
      return;
    }

    final safra = Safra(
      id: _safraIdEmEdicao ?? 0,
      nomeSafra: _nomeController.text.trim(),
      dataInicio: _dataInicio!,
      dataFim: _dataFim!,
    );

    try {
      if (_editando && _safraIdEmEdicao != null) {
        final atualizada = await _service.atualizar(_safraIdEmEdicao!, safra);
        setState(() {
          final index = _safras.indexWhere((item) => item.id == _safraIdEmEdicao);
          if (index >= 0) {
            _safras[index] = atualizada;
          }
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safra atualizada com sucesso!')),
        );
      } else {
        final criada = await _service.criar(safra);
        if (!mounted) return;
        setState(() => _safras.add(criada));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safra cadastrada com sucesso!')),
        );
      }

      _limparFormulario();
      await _carregarSafras();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _excluir(Safra safra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir a safra "${safra.nomeSafra}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    try {
      await _service.excluir(safra.id);
      if (!mounted) return;
      setState(() => _safras.removeWhere((item) => item.id == safra.id));
      if (_safraIdEmEdicao == safra.id) {
        _limparFormulario();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safra excluída com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(Safra safra) {
    setState(() {
      _editando = true;
      _safraIdEmEdicao = safra.id;
      _nomeController.text = safra.nomeSafra;
      _dataInicio = safra.dataInicio;
      _dataFim = safra.dataFim;
    });
  }

  void _limparFormulario() {
    _nomeController.clear();
    _dataInicio = null;
    _dataFim = null;
    _editando = false;
    _safraIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Safra'),
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
                  labelText: 'Nome da Safra',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    valor == null || valor.trim().isEmpty ? 'Informe o nome da safra' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selecionarData(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Início',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatarData(_dataInicio)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selecionarData(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Fim',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatarData(_dataFim)),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _erro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (_safras.isEmpty)
                const Center(child: Text('Nenhuma safra cadastrada.'))
              else
                ..._safras.map(
                  (safra) => Card(
                    child: ListTile(
                      title: Text(safra.nomeSafra),
                      subtitle: Text(
                        '${_formatarData(safra.dataInicio)} a ${_formatarData(safra.dataFim)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(safra),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(safra),
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
