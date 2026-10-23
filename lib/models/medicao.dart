import 'safra.dart';
import 'equipamento.dart';
import 'tipoinformacao.dart';

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
}