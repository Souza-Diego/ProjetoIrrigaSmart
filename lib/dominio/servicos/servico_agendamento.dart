import 'package:flutter/material.dart';
import '../entidades/agendamento.dart';
import '../value_objects/horario_irrigacao.dart';

class ServicoAgendamento {
  // Retorna o próximo agendamento ativo após o horário atual
  Agendamento? encontrarProximo(List<Agendamento> agendamentos) {
    final ativos = agendamentos.where((a) => a.ativo).toList();
    if (ativos.isEmpty) return null;

    final agora = HorarioIrrigacao.deTimeOfDay(TimeOfDay.now());

    final ordenados = List<Agendamento>.from(ativos)
      ..sort((a, b) => a.horario.emMinutosDoDia
          .compareTo(b.horario.emMinutosDoDia));

    // Procura o próximo após agora
    for (final ag in ordenados) {
      if (ag.horario.eDepoisDe(agora)) return ag;
    }

    // Se não achou, retorna o primeiro do dia seguinte
    return ordenados.first;
  }

  // Verifica se algum agendamento ativo bate com o horário atual
  Agendamento? encontrarParaAgoraExato(List<Agendamento> agendamentos) {
    final agora = HorarioIrrigacao.deTimeOfDay(TimeOfDay.now());
    return agendamentos
        .where((a) => a.ativo)
        .where((a) =>
            a.horario.hora == agora.hora &&
            a.horario.minuto == agora.minuto)
        .firstOrNull;
  }

  // Ordena agendamentos por horário
  List<Agendamento> ordenarPorHorario(List<Agendamento> agendamentos) {
    final copia = List<Agendamento>.from(agendamentos);
    copia.sort((a, b) => a.horario.emMinutosDoDia
        .compareTo(b.horario.emMinutosDoDia));
    return copia;
  }
}