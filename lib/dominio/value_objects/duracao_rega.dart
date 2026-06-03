class DuracaoRega {
  final int segundos;

  static const int minimoSegundos = 15;
  static const int maximoSegundos = 300;
  static const int passoSegundos = 15;
  static const int divisoes = (maximoSegundos - minimoSegundos) ~/ passoSegundos;

  const DuracaoRega._(this.segundos);

  factory DuracaoRega(int segundos) {
    final arredondado = (segundos / passoSegundos).round() * passoSegundos;
    return DuracaoRega._(arredondado.clamp(minimoSegundos, maximoSegundos));
  }

  factory DuracaoRega.padrao() => const DuracaoRega._(60);

  String get formatada {
    if (segundos < 60) return '${segundos}s';
    final min = segundos ~/ 60;
    final seg = segundos % 60;
    return seg == 0 ? '$min min' : '$min min ${seg}s';
  }

  int get volumeEstimadoMlAnel => (segundos * 400 / 60).round();

  @override
  bool operator ==(Object other) =>
      other is DuracaoRega && other.segundos == segundos;

  @override
  int get hashCode => segundos.hashCode;

  @override
  String toString() => formatada;
}