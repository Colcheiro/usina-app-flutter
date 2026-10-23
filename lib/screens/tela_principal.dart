import 'package:flutter/material.dart';
import '../models/indicador.dart';
import '../services/indicador_service.dart';
import 'cadastros/cadastro_indicador.dart';
import 'cadastros/cadastro_equipamento.dart';
import 'cadastros/cadastro_medicao.dart';
import 'cadastros/cadastro_safra.dart';
import 'cadastros/cadastro_tipo_informacao.dart';
import 'cadastros/cadastro_unidade.dart';
import 'cadastros/cadastro_unidade_medida.dart';
import 'cadastros/cadastro_usuario.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  bool cadastroAberto = false;
  bool indicadoresAbertos = false;
  final _indicadorService = IndicadorService();
  List<Indicador> _indicadores = [];
  String? _erroIndicadores;

  @override
  void initState() {
    super.initState();
    _carregarIndicadores();
  }

  Future<void> _carregarIndicadores() async {
    try {
      final itens = await _indicadorService.listar();
      if (mounted) {
        setState(() {
          _indicadores = itens;
          _erroIndicadores = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _erroIndicadores = error.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        );
      }
    }
  }

  Widget montarMenu() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          child: Text('Menu Principal', style: TextStyle(fontSize: 22)),
        ),

        const ListTile(leading: Icon(Icons.home), title: Text('Início')),

        ListTile(
          leading: const Icon(Icons.app_registration),
          title: const Text('Cadastro'),
          trailing: Icon(
            cadastroAberto ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              cadastroAberto = !cadastroAberto;
            });
          },
        ),

        if (cadastroAberto) ...[
          _itemCadastro('Usuário', const CadastroUsuarioPage()),
          _itemCadastro('Safras', const CadastroSafra()),
          _itemCadastro('Unidades', const CadastroUnidade()),
          _itemCadastro('Equipamentos', const CadastroEquipamento()),
          _itemCadastro('Medições', const CadastroMedicao()),
          _itemCadastro('Unidades de Medida', const CadastroUnidadeMedida()),
          _itemCadastro('Tipos de Informação', const CadastroTipoInformacao()),
          _itemCadastro('Indicadores', const CadastroIndicador()),
        ],
        ListTile(
          leading: const Icon(Icons.insert_chart_outlined),
          title: const Text('Indicadores'),
          trailing: Icon(
            indicadoresAbertos ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() => indicadoresAbertos = !indicadoresAbertos);
            if (_indicadores.isEmpty) _carregarIndicadores();
          },
        ),
        if (indicadoresAbertos) ...[
          if (_erroIndicadores != null)
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(_erroIndicadores!),
              onTap: _carregarIndicadores,
            )
          else if (_indicadores.isEmpty)
            const ListTile(
              leading: Icon(Icons.hourglass_empty),
              title: Text('Nenhum indicador disponível'),
            )
          else
            ..._indicadores.map(
              (indicador) => ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                leading: const Icon(Icons.chevron_right),
                title: Text(indicador.nome),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/indicador',
                    arguments: indicador,
                  ).then((_) => _carregarIndicadores());
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _itemCadastro(String titulo, Widget tela) {
    return ListTile(
      leading: const Icon(Icons.chevron_right),
      title: Text(titulo),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => tela),
        ).then((_) => _carregarIndicadores());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usina App')),

      drawer: Drawer(child: montarMenu()),

      body: const Center(child: Text('Tela Principal')),
    );
  }
}
