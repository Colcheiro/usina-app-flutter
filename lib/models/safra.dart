class Safra {
  final int id;
  final String nomeSafra;
  final DateTime dataInicio;
  final DateTime dataFim;

  Safra({
    required this.id,
    required this.nomeSafra,
    required this.dataInicio,
    required this.dataFim,
  });

  factory Safra.fromJson(Map<String, dynamic> json) {
    return Safra(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      nomeSafra: (json['NomeSafra'] ?? json['nomeSafra'] ?? json['nome'] ?? '')
          .toString(),
      dataInicio: _parseDate(json['DataInicio'] ?? json['dataInicio']),
      dataFim: _parseDate(json['DataFim'] ?? json['dataFim']),
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{
      'NomeSafra': nomeSafra,
      'DataInicio': _formatDate(dataInicio),
      'DataFim': _formatDate(dataFim),
    };

    if (incluirId) {
      map['Id'] = id;
    }

    return map;
  }

  Safra copyWith({
    int? id,
    String? nomeSafra,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return Safra(
      id: id ?? this.id,
      nomeSafra: nomeSafra ?? this.nomeSafra,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }

  static String _formatDate(DateTime value) => value.toIso8601String().split('T').first;
}