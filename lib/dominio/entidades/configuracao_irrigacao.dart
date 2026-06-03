import '../value_objects/nivel_umidade.dart';
import '../value_objects/duracao_rega.dart';
import '../value_objects/modo_irrigacao.dart';
import '../value_objects/intervalo_rega.dart';

class ConfiguracaoIrrigacao {
  NivelUmidade umidadeMinima;
  DuracaoRega  duracaoPadrao;
  ModoIrrigacao modo;
  IntervaloRega intervaloRega;

  ConfiguracaoIrrigacao({
    required this.umidadeMinima,
    required this.duracaoPadrao,
    required this.modo,
    IntervaloRega? intervaloRega,
  }) : intervaloRega = intervaloRega ?? IntervaloRega.padrao();

  factory ConfiguracaoIrrigacao.padrao() => ConfiguracaoIrrigacao(
    umidadeMinima: NivelUmidade.configuravel(40),
    duracaoPadrao: DuracaoRega.padrao(),
    modo:          ModoIrrigacao.combinado,
    intervaloRega: IntervaloRega.padrao(),
  );

  ConfiguracaoIrrigacao copyWith({
    NivelUmidade?  umidadeMinima,
    DuracaoRega?   duracaoPadrao,
    ModoIrrigacao? modo,
    IntervaloRega? intervaloRega,
  }) => ConfiguracaoIrrigacao(
    umidadeMinima: umidadeMinima ?? this.umidadeMinima,
    duracaoPadrao: duracaoPadrao ?? this.duracaoPadrao,
    modo:          modo          ?? this.modo,
    intervaloRega: intervaloRega ?? this.intervaloRega,
  );
}