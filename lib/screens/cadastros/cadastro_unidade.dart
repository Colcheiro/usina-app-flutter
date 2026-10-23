import 'package:flutter/material.dart';
import '../../models/unidade.dart';

class CadastroUnidade extends StatefulWidget {
  const CadastroUnidade({super.key});

  @override
  State<CadastroUnidade> createState() => _CadastroUnidadeState();
}

class _CadastroUnidadeState extends State<CadastroUnidade> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final List<Unidade> _unidades = [];

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _unidades.add(Unidade(id: _unidades.length + 1, nome: _nomeController.text.trim()));
      _nomeController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unidade cadastrada com sucesso!')));
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
    if (confirmar == true) setState(() => _unidades.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Unidade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              validator: (valor) => valor == null || valor.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            const SizedBox(height: 16),
            ..._unidades.asMap().entries.map((entrada) => Card(child: ListTile(
              title: Text(entrada.value.nome),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _excluir(entrada.key)),
            ))),
          ]),
        ),
      ),
    );
  }
}
