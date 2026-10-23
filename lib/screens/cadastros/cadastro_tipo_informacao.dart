import 'package:flutter/material.dart';
import '../../models/tipoinformacao.dart';
import '../../models/unidade_medida.dart';

class CadastroTipoInformacao extends StatefulWidget {
  const CadastroTipoInformacao({super.key});

  @override
  State<CadastroTipoInformacao> createState() => _CadastroTipoInformacaoState();
}

class _CadastroTipoInformacaoState extends State<CadastroTipoInformacao> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _unidades = [
    UnidadeMedida(id: 1, nome: 'Celsius', simbolo: '°C'),
    UnidadeMedida(id: 2, nome: 'Pressão', simbolo: 'bar'),
    UnidadeMedida(id: 3, nome: 'Rotação', simbolo: 'RPM'),
  ];
  UnidadeMedida? _unidadeSelecionada;
  final List<TipoInformacao> _tipos = [];

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _tipos.add(TipoInformacao(id: _tipos.length + 1, nome: _nomeController.text.trim(), unidadeMedida: _unidadeSelecionada!));
      _nomeController.clear();
      _unidadeSelecionada = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo de informação cadastrado com sucesso!')));
  }

  Future<void> _excluir(int indice) async {
    final confirmar = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Excluir registro'),
      content: const Text('Deseja realmente excluir este registro?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
      ],
    ));
    if (confirmar == true) setState(() => _tipos.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Cadastro de Tipo de Informação')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (valor) => valor == null || valor.trim().isEmpty ? 'Informe o nome' : null),
      const SizedBox(height: 16),
      DropdownButtonFormField<UnidadeMedida>(initialValue: _unidadeSelecionada, decoration: const InputDecoration(labelText: 'Unidade de Medida', border: OutlineInputBorder()), items: _unidades.map((unidade) => DropdownMenuItem(value: unidade, child: Text('${unidade.nome} (${unidade.simbolo})'))).toList(), onChanged: (valor) => setState(() => _unidadeSelecionada = valor), validator: (valor) => valor == null ? 'Selecione a unidade de medida' : null),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      const SizedBox(height: 16),
      ..._tipos.asMap().entries.map((entrada) => Card(child: ListTile(title: Text(entrada.value.nome), subtitle: Text(entrada.value.unidadeMedida.simbolo), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _excluir(entrada.key))))),
    ]))));
  }
}
