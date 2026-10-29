import 'package:flutter/material.dart';

import '../../models/tipoinformacao.dart';
import '../../models/unidade_medida.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroTipoInformacao extends StatefulWidget {
  const CadastroTipoInformacao({super.key});

  @override
  State<CadastroTipoInformacao> createState() => _CadastroTipoInformacaoState();
}

class _CadastroTipoInformacaoState extends State<CadastroTipoInformacao> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoService = CrudService<TipoInformacao>(
    endpoint: ApiConfig.tipoInformacaoEndpoint,
    fromJson: TipoInformacao.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );
  final _unidadeService = CrudService<UnidadeMedida>(
    endpoint: ApiConfig.unidadeMedidaEndpoint,
    fromJson: UnidadeMedida.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  final List<TipoInformacao> _tipos = [];
  final List<UnidadeMedida> _unidades = [];
  UnidadeMedida? _unidadeSelecionada;
  bool _carregando = false;
  bool _editando = false;
  int? _tipoIdEmEdicao;
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
      final tipos = await _tipoService.listar();
      if (!mounted) return;
      setState(() {
        _unidades
          ..clear()
          ..addAll(unidades);
        _tipos
          ..clear()
          ..addAll(tipos);
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

    final tipo = TipoInformacao(
      id: _tipoIdEmEdicao ?? 0,
      nome: _nomeController.text.trim(),
      unidadeMedida: _unidadeSelecionada!,
    );

    try {
      if (_editando && _tipoIdEmEdicao != null) {
        final atualizado = await _tipoService.atualizar(_tipoIdEmEdicao!, tipo);
        if (!mounted) return;
        setState(() {
          final index = _tipos.indexWhere((item) => item.id == _tipoIdEmEdicao);
          if (index >= 0) _tipos[index] = atualizado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de informação atualizado com sucesso!')),
        );
      } else {
        final criado = await _tipoService.criar(tipo);
        if (!mounted) return;
        setState(() => _tipos.add(criado));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de informação cadastrado com sucesso!')),
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

  Future<void> _excluir(TipoInformacao tipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja realmente excluir o tipo de informação "${tipo.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _tipoService.excluir(tipo.id);
      if (!mounted) return;
      setState(() => _tipos.removeWhere((item) => item.id == tipo.id));
      if (_tipoIdEmEdicao == tipo.id) _limparFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de informação excluído com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(TipoInformacao tipo) {
    setState(() {
      _editando = true;
      _tipoIdEmEdicao = tipo.id;
      _nomeController.text = tipo.nome;
      _unidadeSelecionada = tipo.unidadeMedida;
    });
  }

  void _limparFormulario() {
    _nomeController.clear();
    _unidadeSelecionada = null;
    _editando = false;
    _tipoIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Tipo de Informação'),
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
              DropdownButtonFormField<UnidadeMedida>(
                initialValue: _unidadeSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Unidade de Medida',
                  border: OutlineInputBorder(),
                ),
                items: _unidades
                    .map(
                      (unidade) => DropdownMenuItem(
                        value: unidade,
                        child: Text('${unidade.nome} (${unidade.simbolo})'),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => _unidadeSelecionada = valor),
                validator: (valor) =>
                    valor == null ? 'Selecione a unidade de medida' : null,
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
              else if (_tipos.isEmpty)
                const Center(child: Text('Nenhum tipo de informação cadastrado.'))
              else
                ..._tipos.map(
                  (tipo) => Card(
                    child: ListTile(
                      title: Text(tipo.nome),
                      subtitle: Text(tipo.unidadeMedida.simbolo),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(tipo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(tipo),
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
