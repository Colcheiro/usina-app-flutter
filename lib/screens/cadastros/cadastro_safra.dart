import 'package:flutter/material.dart';
import '../../models/safra.dart';

class CadastroSafra extends StatefulWidget {
  const CadastroSafra({super.key});

  @override
  State<CadastroSafra> createState() => _CadastroSafraState();
}

class _CadastroSafraState extends State<CadastroSafra> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final List<Safra> _safras = [];

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(bool inicio) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() {
        if (inicio) {
          _dataInicio = data;
        } else {
          _dataFim = data;
        }
      });
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecione uma data';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _salvar() {
    if (!_formKey.currentState!.validate() || _dataInicio == null || _dataFim == null) return;
    setState(() {
      _safras.add(Safra(
        id: _safras.length + 1,
        nomeSafra: _nomeController.text.trim(),
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
      ));
      _nomeController.clear();
      _dataInicio = null;
      _dataFim = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safra cadastrada com sucesso!')),
    );
  }

  Future<void> _excluir(int indice) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: const Text('Deseja realmente excluir este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true) setState(() => _safras.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Safra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Safra', border: OutlineInputBorder()),
              validator: (valor) => valor == null || valor.trim().isEmpty ? 'Informe o nome da safra' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selecionarData(true),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Data de Início', border: OutlineInputBorder()),
                child: Text(_formatarData(_dataInicio)),
              ),
            ),
            if (_dataInicio == null) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Informe a data de início', style: TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selecionarData(false),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Data de Fim', border: OutlineInputBorder()),
                child: Text(_formatarData(_dataFim)),
              ),
            ),
            if (_dataFim == null) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Informe a data de fim', style: TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            const SizedBox(height: 16),
            ..._safras.asMap().entries.map((entrada) {
              final safra = entrada.value;
              return Card(child: ListTile(
                title: Text(safra.nomeSafra),
                subtitle: Text('${_formatarData(safra.dataInicio)} a ${_formatarData(safra.dataFim)}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _excluir(entrada.key)),
              ));
            }),
          ]),
        ),
      ),
    );
  }
}
