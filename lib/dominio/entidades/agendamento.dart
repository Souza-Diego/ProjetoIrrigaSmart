import 'dart:convert';
import '../value_objects/horario_irrigacao.dart';
import '../value_objects/duracao_rega.dart';

class Agendamento {
  final String id;
  HorarioIrrigacao horario;
  DuracaoRega duracao;
  bool ativo;

  Agendamento({
    required this.id,
    required this.horario,
    required this.duracao,
    this.ativo = true,
  });

  factory Agendamento.novo({
    required HorarioIrrigacao horario,
    required DuracaoRega duracao,
  }) {
    return Agendamento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      horario: horario,
      duracao: duracao,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hora': horario.hora,
        'minuto': horario.minuto,
        'duracaoSegundos': duracao.segundos,
        'ativo': ativo,
      };

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      horario: HorarioIrrigacao(json['hora'], json['minuto']),
      duracao: DuracaoRega(json['duracaoSegundos']),
      ativo: json['ativo'],
    );
  }

  static String listaParaJson(List<Agendamento> lista) =>
      jsonEncode(lista.map((a) => a.toJson()).toList());

  static List<Agendamento> listaDeJson(String json) {
    final lista = jsonDecode(json) as List;
    return lista.map((item) => Agendamento.fromJson(item)).toList();
  }
}