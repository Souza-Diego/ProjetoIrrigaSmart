class ClimaDto {
  final double temperatura;
  final String condicao;
  final String cidade;
  final String icone;

  const ClimaDto({
    required this.temperatura,
    required this.condicao,
    required this.cidade,
    required this.icone,
  });

  factory ClimaDto.fromJson(Map<String, dynamic> json) {
    return ClimaDto(
      temperatura: (json['main']['temp'] as num).toDouble(),
      condicao: json['weather'][0]['description'],
      cidade: json['name'],
      icone: json['weather'][0]['icon'],
    );
  }
}