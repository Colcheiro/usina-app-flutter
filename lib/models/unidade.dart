class Unidade {
  final int id;
  final String nome;

  Unidade({
    required this.id,
    required this.nome,
  });

  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      nome: (json['Nome'] ?? json['nome'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{'Nome': nome};
    if (incluirId) {
      map['Id'] = id;
    }
    return map;
  }

  Unidade copyWith({int? id, String? nome}) {
    return Unidade(id: id ?? this.id, nome: nome ?? this.nome);
  }
}