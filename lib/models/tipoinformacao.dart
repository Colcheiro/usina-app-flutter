import 'unidade_medida.dart';

class TipoInformacao {
  final int id;
  final String nome;
  final UnidadeMedida unidadeMedida;

  TipoInformacao({
    required this.id,
    required this.nome,
    required this.unidadeMedida,
  });

  factory TipoInformacao.fromJson(Map<String, dynamic> json) {
    final unidadeMap = json['UnidadeMedida'];
    final unidade = unidadeMap is Map
        ? UnidadeMedida.fromJson(Map<String, dynamic>.from(unidadeMap))
        : UnidadeMedida(
            id: int.tryParse(
                  (json['UnidadeMedidaId'] ?? json['unidadeMedidaId'] ?? 0)
                      .toString(),
                ) ??
                0,
            nome: '',
            simbolo: '',
          );

    return TipoInformacao(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      nome: (json['Nome'] ?? json['nome'] ?? '').toString(),
      unidadeMedida: unidade,
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{
      'Nome': nome,
      'UnidadeMedidaId': unidadeMedida.id,
    };
    if (incluirId) {
      map['Id'] = id;
    }
    return map;
  }

  TipoInformacao copyWith({int? id, String? nome, UnidadeMedida? unidadeMedida}) {
    return TipoInformacao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
    );
  }
}