class NivelUmidade {
  final int valor;

  static const int minimo = 0;
  static const int maximo = 100;
  static const int minimoConfiguravel = 10;
  static const int maximoConfiguravel = 90;

  const NivelUmidade._(this.valor);

  factory NivelUmidade(int valor) {
    assert(valor >= minimo && valor <= maximo,
        'Umidade deve estar entre $minimo e $maximo');
    return NivelUmidade._(valor.clamp(minimo, maximo));
  }

  factory NivelUmidade.configuravel(int valor) {
    return NivelUmidade._(
        valor.clamp(minimoConfiguravel, maximoConfiguravel));
  }

  bool estaAbaixoDe(NivelUmidade limite) => valor < limite.valor;

  String get formatado => '$valor%';

  @override
  bool operator ==(Object other) =>
      other is NivelUmidade && other.valor == valor;

  @override
  int get hashCode => valor.hashCode;

  @override
  String toString() => formatado;
}