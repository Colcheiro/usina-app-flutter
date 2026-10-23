import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/indicador.dart';
import 'url_viewer_stub.dart'
    if (dart.library.html) 'url_viewer_web.dart'
    if (dart.library.io) 'url_viewer_native.dart'
    as viewer;

class IndicadorWebView extends StatelessWidget {
  const IndicadorWebView({super.key, required this.indicador});

  final Indicador indicador;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(indicador.url);
    final valida =
        uri != null &&
        uri.hasAuthority &&
        const {'http', 'https'}.contains(uri.scheme.toLowerCase());
    return Scaffold(
      appBar: AppBar(title: Text(indicador.nome)),
      body: !valida
          ? const Center(child: Text('A URL deste indicador é inválida.'))
          : Column(
              children: [
                if (indicador.descricao.isNotEmpty)
                  ListTile(title: Text(indicador.descricao)),
                Expanded(child: viewer.buildUrlViewer(uri)),
                if (kIsWeb)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Se o site não carregar, ele pode bloquear exibição em iframe.',
                    ),
                  ),
              ],
            ),
    );
  }
}
