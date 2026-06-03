import 'package:shared_preferences/shared_preferences.dart';
import '../../dominio/entidades/configuracao_irrigacao.dart';
import '../../dominio/repositorios/configuracao_repositorio.dart';
import '../../dominio/value_objects/nivel_umidade.dart';
import '../../dominio/value_objects/duracao_rega.dart';
import '../../dominio/value_objects/modo_irrigacao.dart';
import '../api/irrigasmart_api_client.dart';
import '../../dominio/value_objects/intervalo_rega.dart';

class ConfiguracaoRepositorioImpl implements ConfiguracaoRepositorio {
  @override
  Future<ConfiguracaoIrrigacao> buscar() async {
    final prefs = await SharedPreferences.getInstance();
    return ConfiguracaoIrrigacao(
      umidadeMinima: NivelUmidade.configuravel(
        prefs.getInt('umidade_minima') ?? 40,
      ),
      duracaoPadrao: DuracaoRega(prefs.getInt('duracao_umidade') ?? 60),
      modo: ModoIrrigacao.doCodigo(
        prefs.getString('modo_prioridade') ?? 'combinado',
      ),
      intervaloRega: IntervaloRega(prefs.getInt('intervalo_rega_min') ?? 10),
    );
  }

  @override
  Future<void> salvar(ConfiguracaoIrrigacao configuracao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('umidade_minima', configuracao.umidadeMinima.valor);
    await prefs.setInt('duracao_umidade', configuracao.duracaoPadrao.segundos);
    await prefs.setString('modo_prioridade', configuracao.modo.valor);
  }

  @override
  Future<void> salvarModo(String modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modo_prioridade', modo);
  }

  @override
  Future<void> salvarUmidadeMinima(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('umidade_minima', valor);
  }

  @override
  Future<void> salvarDuracaoPadrao(int segundos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('duracao_umidade', segundos);
  }

  @override
  Future<String?> buscarPlantaSelecionada() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString('planta_selecionada');
    if (valor == null || valor.isEmpty) return null;
    return valor;
  }

  @override
  Future<void> salvarPlantaSelecionada(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('planta_selecionada', nome);
  }

  @override
  Future<String> buscarCidade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cidade') ?? 'Cruzeiro';
  }

  @override
  Future<void> salvarCidade(String cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cidade', cidade);
  }

  @override
  Future<bool> buscarModoEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('modo_escuro') ?? false;
  }

  @override
  Future<void> salvarModoEscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modo_escuro', valor);
  }

  @override
  Future<DateTime?> buscarUltimaIrrigacao() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString('ultima_irrigacao');
    if (valor == null) return null;
    return DateTime.tryParse(valor);
  }

  @override
  Future<void> salvarUltimaIrrigacao(DateTime data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultima_irrigacao', data.toIso8601String());
  }

  Future<void> salvarWifiConfigurado(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wifi_configurado', valor);
  }

  Future<String> carregarEnderecoEsp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('endereco_esp') ?? '';
  }

  Future<void> salvarEnderecoEsp(String endereco) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('endereco_esp', endereco);
  }

  Future<String> carregarUrlApi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('url_api') ?? '';
  }

  Future<void> salvarUrlApi(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('url_api', url);
    IrrigaSmartApiClient.limparCache();
  }

  @override
  Future<int> carregarIntervaloMinutos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('intervalo_rega_min') ?? 10;
  }

  @override
  Future<void> salvarIntervaloMinutos(int minutos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('intervalo_rega_min', minutos);
  }
}
