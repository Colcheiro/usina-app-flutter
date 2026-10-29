import 'unidade.dart';

class Equipamento {
  final int id;
  final String nome;
  final Unidade unidade;

  Equipamento({
    required this.id,
    required this.nome,
    required this.unidade,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    final unidadeMap = json['Unidade'];
    final unidade = unidadeMap is Map
        ? Unidade.fromJson(Map<String, dynamic>.from(unidadeMap))
        : Unidade(
            id: int.tryParse(
                  (json['UnidadeId'] ?? json['unidadeId'] ?? 0).toString(),
                ) ??
                0,
            nome: '',
          );

    return Equipamento(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      nome: (json['Nome'] ?? json['nome'] ?? '').toString(),
      unidade: unidade,
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{
      'Nome': nome,
      'UnidadeId': unidade.id,
    };
    if (incluirId) {
      map['Id'] = id;
    }
    return map;
  }

  Equipamento copyWith({int? id, String? nome, Unidade? unidade}) {
    return Equipamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidade: unidade ?? this.unidade,
    );
  }
}