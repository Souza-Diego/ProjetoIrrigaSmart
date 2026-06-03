class StatusEspDto {
  final bool irrigando;
  final bool irrigacaoManual;
  final int umidadeAtual;
  final int umidadeMinima;
  final String modoPrioridade;
  final int duracaoUmidade;
  final int sensorSeco;
  final int sensorUmido;
  final int sensorRaw;

  const StatusEspDto({
    required this.irrigando,
    required this.irrigacaoManual,
    required this.umidadeAtual,
    required this.umidadeMinima,
    required this.modoPrioridade,
    required this.duracaoUmidade,
    this.sensorSeco = 4095,
    this.sensorUmido = 835,
    this.sensorRaw = 0,
  });

  factory StatusEspDto.fromJson(Map<String, dynamic> json) {
    return StatusEspDto(
      irrigando: json['irrigando'] ?? false,
      irrigacaoManual: json['irrigacaoManual'] ?? false,
      umidadeAtual: json['umidadeAtual'] ?? 0,
      umidadeMinima: json['umidadeMinima'] ?? 40,
      modoPrioridade: json['modoPrioridade'] ?? 'combinado',
      duracaoUmidade: json['duracaoUmidade'] ?? 120,
      sensorSeco: json['sensorSeco'] ?? 4095,
      sensorUmido: json['sensorUmido'] ?? 835,
      sensorRaw: json['sensorRaw'] ?? 0,
    );
  }
}
