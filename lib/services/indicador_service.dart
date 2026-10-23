import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/indicador.dart';

class IndicadorService {
  static String get baseUrl =>
      'http://${defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1'}:1880/api/indicadores';

  final http.Client _client;

  IndicadorService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Indicador>> listar() async {
    final response = await _send(() => _client.get(Uri.parse(baseUrl)));
    final data = _decode(response);
    if (data is! List) {
      throw const FormatException(
        'A API não retornou uma lista de indicadores.',
      );
    }
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('A API retornou um indicador inválido.');
      }
      return Indicador.fromJson(item);
    }).toList();
  }

  Future<Indicador> buscarPorId(int id) async {
    final response = await _send(() => _client.get(Uri.parse('$baseUrl/$id')));
    final data = _decode(response);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('A API retornou um indicador inválido.');
    }
    return Indicador.fromJson(data);
  }

  Future<Indicador> criar(Indicador indicador) async {
    final response = await _send(
      () => _client.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(indicador.toJson()),
      ),
    );
    final data = _decode(response);
    if (data is Map<String, dynamic>) return Indicador.fromJson(data);
    return indicador;
  }

  Future<Indicador> atualizar(int id, Indicador indicador) async {
    final response = await _send(
      () => _client.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(indicador.copyWith(id: id).toJson(incluirId: true)),
      ),
    );
    if (response.body.trim().isEmpty) return indicador.copyWith(id: id);
    final data = _decode(response);
    return data is Map<String, dynamic>
        ? Indicador.fromJson(data)
        : indicador.copyWith(id: id);
  }

  Future<void> excluir(int id) async {
    await _send(() => _client.delete(Uri.parse('$baseUrl/$id')));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail = response.body.trim();
        throw Exception(
          detail.isEmpty
              ? 'A API respondeu com status ${response.statusCode}.'
              : 'A API respondeu com status ${response.statusCode}: $detail',
        );
      }
      return response;
    } on http.ClientException catch (error) {
      throw Exception('Não foi possível conectar à API. ${error.message}');
    }
  }

  dynamic _decode(http.Response response) {
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('A API retornou uma resposta inválida.');
    }
  }
}
