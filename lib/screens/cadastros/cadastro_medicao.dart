import 'package:flutter/material.dart';

import '../../models/equipamento.dart';
import '../../models/medicao.dart';
import '../../models/safra.dart';
import '../../models/tipoinformacao.dart';
import '../../services/api_config.dart';
import '../../services/crud_service.dart';

class CadastroMedicao extends StatefulWidget {
  const CadastroMedicao({super.key});

  @override
  State<CadastroMedicao> createState() => _CadastroMedicaoState();
}

class _CadastroMedicaoState extends State<CadastroMedicao> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _medicaoService = CrudService<Medicao>(
    endpoint: ApiConfig.medicaoEndpoint,
    fromJson: Medicao.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );
  final _safraService = CrudService<Safra>(
    endpoint: ApiConfig.safraEndpoint,
    fromJson: Safra.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );
  final _equipamentoService = CrudService<Equipamento>(
    endpoint: ApiConfig.equipamentoEndpoint,
    fromJson: Equipamento.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );
  final _tipoService = CrudService<TipoInformacao>(
    endpoint: ApiConfig.tipoInformacaoEndpoint,
    fromJson: TipoInformacao.fromJson,
    toJson: (value, {bool incluirId = false}) => value.toJson(incluirId: incluirId),
  );

  final List<Safra> _safras = [];
  final List<Equipamento> _equipamentos = [];
  final List<TipoInformacao> _tipos = [];
  final List<Medicao> _medicoes = [];

  Safra? _safraSelecionada;
  Equipamento? _equipamentoSelecionado;
  TipoInformacao? _tipoSelecionado;
  DateTime? _dataSelecionada;
  bool _carregando = false;
  bool _editando = false;
  int? _medicaoIdEmEdicao;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    try {
      final safras = await _safraService.listar();
      final equipamentos = await _equipamentoService.listar();
      final tipos = await _tipoService.listar();
      final medicoes = await _medicaoService.listar();
      if (!mounted) return;
      setState(() {
        _safras
          ..clear()
          ..addAll(safras);
        _equipamentos
          ..clear()
          ..addAll(equipamentos);
        _tipos
          ..clear()
          ..addAll(tipos);
        _medicoes
          ..clear()
          ..addAll(medicoes);
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

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    setState(() => _dataSelecionada = DateTime(
          data.year,
          data.month,
          data.day,
          hora.hour,
          hora.minute,
        ));
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecione data e hora';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() ||
        _safraSelecionada == null ||
        _equipamentoSelecionado == null ||
        _tipoSelecionado == null ||
        _dataSelecionada == null) {
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor numérico válido.')),
      );
      return;
    }

    final medicao = Medicao(
      id: _medicaoIdEmEdicao ?? 0,
      safra: _safraSelecionada!,
      equipamento: _equipamentoSelecionado!,
      tipoInformacao: _tipoSelecionado!,
      valor: valor,
      data: _dataSelecionada!,
    );

    try {
      if (_editando && _medicaoIdEmEdicao != null) {
        final atualizada = await _medicaoService.atualizar(_medicaoIdEmEdicao!, medicao);
        if (!mounted) return;
        setState(() {
          final index = _medicoes.indexWhere((item) => item.id == _medicaoIdEmEdicao);
          if (index >= 0) _medicoes[index] = atualizada;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medição atualizada com sucesso!')),
        );
      } else {
        final criada = await _medicaoService.criar(medicao);
        if (!mounted) return;
        setState(() => _medicoes.add(criada));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medição cadastrada com sucesso!')),
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

  Future<void> _excluir(Medicao medicao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: const Text('Deseja realmente excluir esta medição?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _medicaoService.excluir(medicao.id);
      if (!mounted) return;
      setState(() => _medicoes.removeWhere((item) => item.id == medicao.id));
      if (_medicaoIdEmEdicao == medicao.id) _limparFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medição excluída com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _editar(Medicao medicao) {
    setState(() {
      _editando = true;
      _medicaoIdEmEdicao = medicao.id;
      _safraSelecionada = medicao.safra;
      _equipamentoSelecionado = medicao.equipamento;
      _tipoSelecionado = medicao.tipoInformacao;
      _valorController.text = medicao.valor.toString();
      _dataSelecionada = medicao.data;
    });
  }

  void _limparFormulario() {
    _valorController.clear();
    _safraSelecionada = null;
    _equipamentoSelecionado = null;
    _tipoSelecionado = null;
    _dataSelecionada = null;
    _editando = false;
    _medicaoIdEmEdicao = null;
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Medição'),
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
              DropdownButtonFormField<Safra>(
                initialValue: _safraSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Safra',
                  border: OutlineInputBorder(),
                ),
                items: _safras
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.nomeSafra)))
                    .toList(),
                onChanged: (valor) => setState(() => _safraSelecionada = valor),
                validator: (valor) => valor == null ? 'Selecione a safra' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Equipamento>(
                initialValue: _equipamentoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  border: OutlineInputBorder(),
                ),
                items: _equipamentos
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.nome)))
                    .toList(),
                onChanged: (valor) => setState(() => _equipamentoSelecionado = valor),
                validator: (valor) => valor == null ? 'Selecione o equipamento' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoInformacao>(
                initialValue: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Informação',
                  border: OutlineInputBorder(),
                ),
                items: _tipos
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.nome)))
                    .toList(),
                onChanged: (valor) => setState(() => _tipoSelecionado = valor),
                validator: (valor) => valor == null ? 'Selecione o tipo de informação' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    valor == null || double.tryParse(valor.replaceAll(',', '.')) == null
                        ? 'Informe um valor válido'
                        : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data e Hora',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatarData(_dataSelecionada)),
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
                Text(_erro!, style: const TextStyle(color: Colors.red))
              else if (_medicoes.isEmpty)
                const Center(child: Text('Nenhuma medição cadastrada.'))
              else
                ..._medicoes.map(
                  (medicao) => Card(
                    child: ListTile(
                      title: Text(
                        '${medicao.tipoInformacao.nome}: ${medicao.valor} ${medicao.tipoInformacao.unidadeMedida.simbolo}',
                      ),
                      subtitle: Text(
                        '${medicao.safra.nomeSafra} - ${medicao.equipamento.nome}\n${_formatarData(medicao.data)}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(medicao),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(medicao),
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
