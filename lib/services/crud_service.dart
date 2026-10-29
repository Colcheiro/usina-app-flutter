import 'dart:convert';

import 'package:http/http.dart' as http;

class CrudService<T> {
  CrudService({
    required this.endpoint,
    required this.fromJson,
    required this.toJson,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String endpoint;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value, {bool incluirId}) toJson;
  final http.Client _client;

  Future<List<T>> listar() async {
    final response = await _send(() => _client.get(Uri.parse(endpoint)));
    final data = _decode(response);
    if (data is! List && data is! Map) {
      throw const FormatException('A API não retornou uma lista de registros.');
    }

    final lista = data is List ? data : _extrairLista(data);
    return lista.map((item) {
      if (item is! Map<String, dynamic>) {
        final map = item is Map ? Map<String, dynamic>.from(item) : null;
        if (map == null) {
          throw const FormatException('A API retornou um registro inválido.');
        }
        return fromJson(map);
      }
      return fromJson(item);
    }).toList();
  }

  Future<T> criar(T item) async {
    final response = await _send(
      () => _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(toJson(item, incluirId: false)),
      ),
    );
    final data = _decode(response);
    if (data is Map<String, dynamic>) {
      return fromJson(data);
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      return fromJson(Map<String, dynamic>.from(data.first));
    }
    return item;
  }

  Future<T> atualizar(int id, T item) async {
    final response = await _send(
      () => _client.put(
        Uri.parse('$endpoint/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(toJson(item, incluirId: true)),
      ),
    );
    final data = _decode(response);
    if (data is Map<String, dynamic>) {
      return fromJson(data);
    }
    return item;
  }

  Future<void> excluir(int id) async {
    await _send(() => _client.delete(Uri.parse('$endpoint/$id')));
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
    } on Exception {
      rethrow;
    }
  }

  List<dynamic> _extrairLista(Map<String, dynamic> data) {
    const chaves = ['data', 'items', 'result', 'registros', 'dados', 'valor'];
    for (final chave in chaves) {
      final value = data[chave];
      if (value is List) {
        return value;
      }
      if (value is Map && value.containsKey('data') && value['data'] is List) {
        return value['data'];
      }
    }

    for (final value in data.values) {
      if (value is List) {
        return value;
      }
    }

    throw const FormatException('A API não retornou uma lista de registros.');
  }

  dynamic _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('A API retornou uma resposta inválida.');
    }
  }
}
