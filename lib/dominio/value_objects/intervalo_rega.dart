class IntervaloRega {
  final int minutos;

  static const int minimoMinutos = 0;
  static const int maximoMinutos = 60;

  const IntervaloRega._(this.minutos);

  factory IntervaloRega(int minutos) {
    return IntervaloRega._(minutos.clamp(minimoMinutos, maximoMinutos));
  }

  factory IntervaloRega.padrao() => const IntervaloRega._(10);
  factory IntervaloRega.semIntervalo() => const IntervaloRega._(0);

  bool get semRestricao => minutos == 0;

  String get descricao {
    if (semRestricao) return 'Sem intervalo mínimo';
    if (minutos == 1) return '1 minuto';
    return '$minutos minutos';
  }

  @override
  bool operator ==(Object other) =>
      other is IntervaloRega && other.minutos == minutos;

  @override
  int get hashCode => minutos.hashCode;
}
