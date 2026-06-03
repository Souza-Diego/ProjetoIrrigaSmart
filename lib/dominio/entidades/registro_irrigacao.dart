class RegistroIrrigacao {
  final int id;
  final DateTime timestampInicio;
  final DateTime? timestampFim;
  final int? duracaoRealSegundos;
  final double? volumeEstimadoMl;
  final int? umidadeAntes;
  final int? umidadeDepois;

  const RegistroIrrigacao({
    required this.id,
    required this.timestampInicio,
    this.timestampFim,
    this.duracaoRealSegundos,
    this.volumeEstimadoMl,
    this.umidadeAntes,
    this.umidadeDepois,
  });

  bool get finalizado => timestampFim != null;

  String get duracaoFormatada {
    if (duracaoRealSegundos == null) return 'em andamento...';
    if (duracaoRealSegundos! < 60) return '${duracaoRealSegundos}s';
    final min = duracaoRealSegundos! ~/ 60;
    final seg = duracaoRealSegundos! % 60;
    return seg == 0 ? '${min}min' : '${min}min ${seg}s';
  }

  factory RegistroIrrigacao.fromJson(Map<String, dynamic> json) {
    return RegistroIrrigacao(
      id: _toInt(json['id']),
      timestampInicio: _toDateTime(json['timestamp_inicio']),
      timestampFim: json['timestamp_fim'] != null
          ? _toDateTime(json['timestamp_fim'])
          : null,
      duracaoRealSegundos: json['duracao_real_segundos'] != null
          ? _toInt(json['duracao_real_segundos'])
          : null,
      volumeEstimadoMl: json['volume_estimado_ml'] != null
          ? _toDouble(json['volume_estimado_ml'])
          : null,
      umidadeAntes: json['umidade_antes'] != null
          ? _toInt(json['umidade_antes'])
          : null,
      umidadeDepois: json['umidade_depois'] != null
          ? _toInt(json['umidade_depois'])
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic v) {
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
