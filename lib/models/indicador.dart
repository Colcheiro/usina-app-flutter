class Indicador {
  const Indicador({
    this.id,
    required this.nome,
    required this.descricao,
    required this.url,
  });

  final int? id;
  final String nome;
  final String descricao;
  final String url;

  factory Indicador.fromJson(Map<String, dynamic> json) {
    final idValue = json['Id'] ?? json['id'];
    return Indicador(
      id: idValue is int ? idValue : int.tryParse('$idValue'),
      nome: (json['Nome'] ?? json['nome'] ?? '').toString(),
      descricao: (json['Descricao'] ?? json['descricao'] ?? '').toString(),
      url: (json['Url'] ?? json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) => {
    if (incluirId && id != null) 'Id': id,
    'Nome': nome,
    'Descricao': descricao,
    'Url': url,
  };

  Indicador copyWith({int? id}) =>
      Indicador(id: id ?? this.id, nome: nome, descricao: descricao, url: url);
}
