import 'package:flutter/material.dart';

class HorarioIrrigacao {
  final int hora;
  final int minuto;

  const HorarioIrrigacao._(this.hora, this.minuto);

  factory HorarioIrrigacao(int hora, int minuto) {
    assert(hora >= 0 && hora <= 23, 'Hora inválida');
    assert(minuto >= 0 && minuto <= 59, 'Minuto inválido');
    return HorarioIrrigacao._(hora, minuto);
  }

  factory HorarioIrrigacao.deTimeOfDay(TimeOfDay timeOfDay) {
    return HorarioIrrigacao._(timeOfDay.hour, timeOfDay.minute);
  }

  TimeOfDay get comoTimeOfDay => TimeOfDay(hour: hora, minute: minuto);

  int get emMinutosDoDia => hora * 60 + minuto;

  bool eDepoisDe(HorarioIrrigacao outro) =>
      emMinutosDoDia > outro.emMinutosDoDia;

  String get formatado =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is HorarioIrrigacao &&
      other.hora == hora &&
      other.minuto == minuto;

  @override
  int get hashCode => Object.hash(hora, minuto);

  @override
  String toString() => formatado;
}