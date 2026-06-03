enum ModoIrrigacao {
  horario,
  umidade,
  combinado;

  String get valor {
    switch (this) {
      case ModoIrrigacao.horario:
        return 'horario';
      case ModoIrrigacao.umidade:
        return 'umidade';
      case ModoIrrigacao.combinado:
        return 'combinado';
    }
  }

  static ModoIrrigacao doCodigo(String codigo) {
    return ModoIrrigacao.values.firstWhere(
      (m) => m.valor == codigo,
      orElse: () => ModoIrrigacao.combinado,
    );
  }

  String get rotulo {
    switch (this) {
      case ModoIrrigacao.horario:
        return 'Horário';
      case ModoIrrigacao.umidade:
        return 'Umidade';
      case ModoIrrigacao.combinado:
        return 'Combinado';
    }
  }
}