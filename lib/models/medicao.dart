import 'equipamento.dart';
import 'safra.dart';
import 'tipoinformacao.dart';
import 'unidade.dart';
import 'unidade_medida.dart';

class Medicao {
  final int id;
  final Safra safra;
  final Equipamento equipamento;
  final TipoInformacao tipoInformacao;
  final double valor;
  final DateTime data;

  Medicao({
    required this.id,
    required this.safra,
    required this.equipamento,
    required this.tipoInformacao,
    required this.valor,
    required this.data,
  });

  factory Medicao.fromJson(Map<String, dynamic> json) {
    final safraMap = json['Safra'];
    final equipamentoMap = json['Equipamento'];
    final tipoMap = json['TipoInformacao'];

    return Medicao(
      id: int.tryParse((json['Id'] ?? json['id'] ?? 0).toString()) ?? 0,
      safra: safraMap is Map
          ? Safra.fromJson(Map<String, dynamic>.from(safraMap))
          : Safra(
              id: int.tryParse((json['SafraId'] ?? json['safraId'] ?? 0).toString()) ?? 0,
              nomeSafra: '',
              dataInicio: DateTime.now(),
              dataFim: DateTime.now(),
            ),
      equipamento: equipamentoMap is Map
          ? Equipamento.fromJson(Map<String, dynamic>.from(equipamentoMap))
          : Equipamento(
              id: int.tryParse((json['EquipamentoId'] ?? json['equipamentoId'] ?? 0).toString()) ?? 0,
              nome: '',
              unidade: Unidade(id: 0, nome: ''),
            ),
      tipoInformacao: tipoMap is Map
          ? TipoInformacao.fromJson(Map<String, dynamic>.from(tipoMap))
          : TipoInformacao(
              id: int.tryParse((json['TipoInformacaoId'] ?? json['tipoInformacaoId'] ?? 0).toString()) ?? 0,
              nome: '',
              unidadeMedida: UnidadeMedida(id: 0, nome: '', simbolo: ''),
            ),
      valor: double.tryParse((json['Valor'] ?? json['valor'] ?? 0).toString()) ?? 0,
      data: _parseDate(json['Data'] ?? json['data']),
    );
  }

  Map<String, dynamic> toJson({bool incluirId = false}) {
    final map = <String, dynamic>{
      'SafraId': safra.id,
      'EquipamentoId': equipamento.id,
      'TipoInformacaoId': tipoInformacao.id,
      'Valor': valor,
      'Data': data.toIso8601String(),
    };
    if (incluirId) {
      map['Id'] = id;
    }
    return map;
  }

  Medicao copyWith({
    int? id,
    Safra? safra,
    Equipamento? equipamento,
    TipoInformacao? tipoInformacao,
    double? valor,
    DateTime? data,
  }) {
    return Medicao(
      id: id ?? this.id,
      safra: safra ?? this.safra,
      equipamento: equipamento ?? this.equipamento,
      tipoInformacao: tipoInformacao ?? this.tipoInformacao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }
}
