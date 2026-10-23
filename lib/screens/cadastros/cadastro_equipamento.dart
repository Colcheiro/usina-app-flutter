import 'package:flutter/material.dart';
import '../../models/equipamento.dart';
import '../../models/unidade.dart';

class CadastroEquipamento extends StatefulWidget {
  const CadastroEquipamento({super.key});

  @override
  State<CadastroEquipamento> createState() => _CadastroEquipamentoState();
}

class _CadastroEquipamentoState extends State<CadastroEquipamento> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _unidades = [
    Unidade(id: 1, nome: 'Unidade 1'),
    Unidade(id: 2, nome: 'Unidade 2'),
    Unidade(id: 3, nome: 'Unidade 3'),
  ];
  Unidade? _unidadeSelecionada;
  final List<Equipamento> _equipamentos = [];

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _equipamentos.add(Equipamento(id: _equipamentos.length + 1, nome: _nomeController.text.trim(), unidade: _unidadeSelecionada!));
      _nomeController.clear();
      _unidadeSelecionada = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipamento cadastrado com sucesso!')));
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
    if (confirmar == true) setState(() => _equipamentos.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Equipamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (valor) => valor == null || valor.trim().isEmpty ? 'Informe o nome' : null),
            const SizedBox(height: 16),
            DropdownButtonFormField<Unidade>(
              initialValue: _unidadeSelecionada,
              decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
              items: _unidades.map((unidade) => DropdownMenuItem(value: unidade, child: Text(unidade.nome))).toList(),
              onChanged: (valor) => setState(() => _unidadeSelecionada = valor),
              validator: (valor) => valor == null ? 'Selecione a unidade' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            const SizedBox(height: 16),
            ..._equipamentos.asMap().entries.map((entrada) => Card(child: ListTile(
              title: Text(entrada.value.nome),
              subtitle: Text(entrada.value.unidade.nome),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _excluir(entrada.key)),
            ))),
          ]),
        ),
      ),
    );
  }
}
