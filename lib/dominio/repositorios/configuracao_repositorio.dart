import '../entidades/configuracao_irrigacao.dart';

abstract class ConfiguracaoRepositorio {
  Future<ConfiguracaoIrrigacao> buscar();
  Future<void> salvar(ConfiguracaoIrrigacao configuracao);
  Future<void> salvarModo(String modo);
  Future<void> salvarUmidadeMinima(int valor);
  Future<void> salvarDuracaoPadrao(int segundos);
  Future<String?> buscarPlantaSelecionada();
  Future<void> salvarPlantaSelecionada(String nome);
  Future<String> buscarCidade();
  Future<void> salvarCidade(String cidade);
  Future<bool> buscarModoEscuro();
  Future<void> salvarModoEscuro(bool valor);
  Future<DateTime?> buscarUltimaIrrigacao();
  Future<void> salvarUltimaIrrigacao(DateTime data);
  Future<int> carregarIntervaloMinutos();
  Future<void> salvarIntervaloMinutos(int minutos);
}
