import 'package:flutter/material.dart';
import 'screens/tela_principal.dart';
import 'screens/indicador_webview.dart';
import 'models/indicador.dart';

void main() {
  runApp(const UsinaApp());
}

class UsinaApp extends StatelessWidget {
  const UsinaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Usina App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
      onGenerateRoute: (settings) {
        if (settings.name == '/indicador') {
          final indicador = settings.arguments;
          if (indicador is Indicador) {
            return MaterialPageRoute<void>(
              builder: (_) => IndicadorWebView(indicador: indicador),
            );
          }
        }
        return null;
      },
    );
  }
}
