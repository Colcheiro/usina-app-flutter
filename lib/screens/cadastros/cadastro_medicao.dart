import 'package:flutter/material.dart';
import '../../models/equipamento.dart';
import '../../models/medicao.dart';
import '../../models/safra.dart';
import '../../models/tipoinformacao.dart';
import '../../models/unidade.dart';
import '../../models/unidade_medida.dart';

class CadastroMedicao extends StatefulWidget {
  const CadastroMedicao({super.key});

  @override
  State<CadastroMedicao> createState() => _CadastroMedicaoState();
}

class _CadastroMedicaoState extends State<CadastroMedicao> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _safras = [
    Safra(id: 1, nomeSafra: 'Safra 2025', dataInicio: DateTime(2025, 1, 1), dataFim: DateTime(2025, 12, 31)),
    Safra(id: 2, nomeSafra: 'Safra 2026', dataInicio: DateTime(2026, 1, 1), dataFim: DateTime(2026, 12, 31)),
  ];
  final _equipamentos = [
    Equipamento(id: 1, nome: 'Caldeira', unidade: Unidade(id: 1, nome: 'Unidade 1')),
    Equipamento(id: 2, nome: 'Turbina', unidade: Unidade(id: 2, nome: 'Unidade 2')),
  ];
  final _tipos = [
    TipoInformacao(id: 1, nome: 'Temperatura', unidadeMedida: UnidadeMedida(id: 1, nome: 'Celsius', simbolo: '°C')),
    TipoInformacao(id: 2, nome: 'Pressão', unidadeMedida: UnidadeMedida(id: 2, nome: 'Pressão', simbolo: 'bar')),
    TipoInformacao(id: 3, nome: 'Rotação', unidadeMedida: UnidadeMedida(id: 3, nome: 'Rotação', simbolo: 'RPM')),
  ];
  Safra? _safraSelecionada;
  Equipamento? _equipamentoSelecionado;
  TipoInformacao? _tipoSelecionado;
  DateTime? _dataSelecionada;
  final List<Medicao> _medicoes = [];

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (data == null || !mounted) return;
    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (hora != null) setState(() => _dataSelecionada = DateTime(data.year, data.month, data.day, hora.hour, hora.minute));
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecione data e hora';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  void _salvar() {
    if (!_formKey.currentState!.validate() || _dataSelecionada == null) return;
    setState(() {
      _medicoes.add(Medicao(id: _medicoes.length + 1, safra: _safraSelecionada!, equipamento: _equipamentoSelecionado!, tipoInformacao: _tipoSelecionado!, valor: double.parse(_valorController.text.replaceAll(',', '.')), data: _dataSelecionada!));
      _valorController.clear();
      _safraSelecionada = null;
      _equipamentoSelecionado = null;
      _tipoSelecionado = null;
      _dataSelecionada = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medição cadastrada com sucesso!')));
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
    if (confirmar == true) setState(() => _medicoes.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Cadastro de Medição')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DropdownButtonFormField<Safra>(initialValue: _safraSelecionada, decoration: const InputDecoration(labelText: 'Safra', border: OutlineInputBorder()), items: _safras.map((item) => DropdownMenuItem(value: item, child: Text(item.nomeSafra))).toList(), onChanged: (valor) => setState(() => _safraSelecionada = valor), validator: (valor) => valor == null ? 'Selecione a safra' : null),
      const SizedBox(height: 16),
      DropdownButtonFormField<Equipamento>(initialValue: _equipamentoSelecionado, decoration: const InputDecoration(labelText: 'Equipamento', border: OutlineInputBorder()), items: _equipamentos.map((item) => DropdownMenuItem(value: item, child: Text(item.nome))).toList(), onChanged: (valor) => setState(() => _equipamentoSelecionado = valor), validator: (valor) => valor == null ? 'Selecione o equipamento' : null),
      const SizedBox(height: 16),
      DropdownButtonFormField<TipoInformacao>(initialValue: _tipoSelecionado, decoration: const InputDecoration(labelText: 'Tipo de Informação', border: OutlineInputBorder()), items: _tipos.map((item) => DropdownMenuItem(value: item, child: Text(item.nome))).toList(), onChanged: (valor) => setState(() => _tipoSelecionado = valor), validator: (valor) => valor == null ? 'Selecione o tipo de informação' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _valorController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor', border: OutlineInputBorder()), validator: (valor) => valor == null || double.tryParse(valor.replaceAll(',', '.')) == null ? 'Informe um valor válido' : null),
      const SizedBox(height: 16),
      InkWell(onTap: _selecionarData, child: InputDecorator(decoration: const InputDecoration(labelText: 'Data e Hora', border: OutlineInputBorder()), child: Text(_formatarData(_dataSelecionada)))),
      if (_dataSelecionada == null) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Informe a data e hora', style: TextStyle(color: Colors.red))),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      const SizedBox(height: 16),
      ..._medicoes.asMap().entries.map((entrada) => Card(child: ListTile(title: Text('${entrada.value.tipoInformacao.nome}: ${entrada.value.valor} ${entrada.value.tipoInformacao.unidadeMedida.simbolo}'), subtitle: Text('${entrada.value.safra.nomeSafra} - ${entrada.value.equipamento.nome}\n${_formatarData(entrada.value.data)}'), isThreeLine: true, trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _excluir(entrada.key))))),
    ]))));
  }
}
