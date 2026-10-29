import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    return 'http://$host:1880';
  }

  static String get safraEndpoint => '$baseUrl/api/safras';
  static String get unidadeEndpoint => '$baseUrl/api/unidades';
  static String get unidadeMedidaEndpoint => '$baseUrl/api/unidadesmedida';
  static String get equipamentoEndpoint => '$baseUrl/api/equipamentos';
  static String get tipoInformacaoEndpoint => '$baseUrl/api/tipoinformacoes';
  static String get medicaoEndpoint => '$baseUrl/api/medicoes';
}
