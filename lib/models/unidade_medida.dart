class UnidadeMedida {
  final int id;
  final String nome;
  final String simbolo;

  UnidadeMedida({
    required this.id,
    required this.nome,
    required this.simbolo,
  });

  factory UnidadeMedida.fromJson(Map<String, dynamic> json) {
    return UnidadeMedida(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      nome: (json['Nome'] ?? json['nome'] ?? '').toString(),
      simbolo: (json['Simbolo'] ?? json['simbolo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{
      'Nome': nome,
      'Simbolo': simbolo,
    };
    if (incluirId) {
      map['Id'] = id;
    }
    return map;
  }

  UnidadeMedida copyWith({int? id, String? nome, String? simbolo}) {
    return UnidadeMedida(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      simbolo: simbolo ?? this.simbolo,
    );
  }
}