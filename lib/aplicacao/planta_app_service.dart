import '../infraestrutura/persistencia/configuracao_repositorio_impl.dart';
import '../infraestrutura/hardware/esp_http_client.dart';
import '../../dados/plantas/dados_plantas.dart';

class PlantaAppService {
  final ConfiguracaoRepositorioImpl _configuracaoRepo;
  final EspHttpClient _espClient;
  final Future<void> Function()? onParametrosAplicados;

  PlantaAppService({
    ConfiguracaoRepositorioImpl? configuracaoRepo,
    EspHttpClient? espClient,
    this.onParametrosAplicados,
  }) : _configuracaoRepo = configuracaoRepo ?? ConfiguracaoRepositorioImpl(),
       _espClient = espClient ?? EspHttpClient();

  Future<void> aplicarParametros(DadosPlanta planta) async {
    await _configuracaoRepo.salvarUmidadeMinima(planta.umidadeMinimaValor);
    await _configuracaoRepo.salvarDuracaoPadrao(planta.duracaoSegundos);
    await _configuracaoRepo.salvarPlantaSelecionada(planta.nome);

    final modo = await _configuracaoRepo.buscar();
    _espClient.atualizarConfig(
      umidadeMinima: planta.umidadeMinimaValor,
      modoPrioridade: modo.modo.valor,
      duracaoUmidade: planta.duracaoSegundos,
    );  
    
    // Notifica o service principal para recarregar
    await onParametrosAplicados?.call();
  }

  Future<String?> buscarPlantaSelecionada() async {
    return await _configuracaoRepo.buscarPlantaSelecionada();
  }
}
