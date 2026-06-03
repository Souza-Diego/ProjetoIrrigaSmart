import 'dart:async';
import 'package:flutter/material.dart';
import '../dominio/entidades/agendamento.dart';
import '../dominio/entidades/configuracao_irrigacao.dart';
import '../dominio/repositorios/agendamento_repositorio.dart';
import '../dominio/servicos/servico_agendamento.dart';
import '../dominio/value_objects/horario_irrigacao.dart';
import '../dominio/value_objects/nivel_umidade.dart';
import '../dominio/value_objects/duracao_rega.dart';
import '../dominio/value_objects/modo_irrigacao.dart';
import '../dados/dtos/status_esp_dto.dart';
import '../dados/dtos/clima_dto.dart';
import '../infraestrutura/hardware/esp_http_client.dart';
import '../infraestrutura/clima/open_weather_client.dart';
import '../infraestrutura/persistencia/agendamento_repositorio_impl.dart';
import '../infraestrutura/persistencia/configuracao_repositorio_impl.dart';
import '../infraestrutura/api/irrigasmart_api_client.dart';
import '../dominio/value_objects/intervalo_rega.dart';

class IrrigacaoAppService extends ChangeNotifier {
  final AgendamentoRepositorio _agendamentoRepo;
  final ConfiguracaoRepositorioImpl _configuracaoRepo;
  final EspHttpClient _espClient;
  final OpenWeatherClient _climaClient;
  final ServicoAgendamento _servicoAgendamento;
  final IrrigaSmartApiClient _apiClient = IrrigaSmartApiClient();

  IrrigacaoAppService({
    AgendamentoRepositorio? agendamentoRepo,
    ConfiguracaoRepositorioImpl? configuracaoRepo,
    EspHttpClient? espClient,
    OpenWeatherClient? climaClient,
  }) : _agendamentoRepo = agendamentoRepo ?? AgendamentoRepositorioImpl(),
       _configuracaoRepo = configuracaoRepo ?? ConfiguracaoRepositorioImpl(),
       _espClient = espClient ?? EspHttpClient(),
       _climaClient = climaClient ?? OpenWeatherClient(),
       _servicoAgendamento = ServicoAgendamento();

  List<Agendamento> _agendamentos = [];
  ConfiguracaoIrrigacao _configuracao = ConfiguracaoIrrigacao.padrao();
  StatusEspDto? _statusEsp;
  ClimaDto? _clima;
  bool _conectado = false;
  bool _carregando = true;
  DateTime? _ultimaIrrigacao;
  String _ultimoAgendamentoExecutado = '';

  List<Agendamento> get agendamentos =>
      _servicoAgendamento.ordenarPorHorario(_agendamentos);
  ConfiguracaoIrrigacao get configuracao => _configuracao;
  ClimaDto? get clima => _clima;
  bool get conectado => _conectado;
  bool get carregando => _carregando;
  bool get irrigando => _statusEsp?.irrigando ?? false;
  DateTime? get ultimaIrrigacao => _ultimaIrrigacao;
  int get umidadeAtual => _statusEsp?.umidadeAtual ?? 0;

  Agendamento? get proximoAgendamento =>
      _servicoAgendamento.encontrarProximo(agendamentos);

  Future<void> inicializar() async {
    _carregando = true;
    notifyListeners();

    _agendamentos = await _agendamentoRepo.buscarTodos();
    _configuracao = await _configuracaoRepo.buscar();
    _ultimaIrrigacao = await _configuracaoRepo.buscarUltimaIrrigacao();

    _carregando = false;
    notifyListeners();

    final cidade = await _configuracaoRepo.buscarCidade();
    _buscarClima(cidade);
    await atualizarStatusEsp();
  }

  Future<void> atualizarStatusEsp() async {
    if (_bloqueioPolling != null &&
        DateTime.now().isBefore(_bloqueioPolling!)) {
      return;
    }

    final statusAnterior = _statusEsp;
    final status = await _espClient.buscarStatus();

    if (status != null) {
      _falhasConsecutivas = 0;
      _conectado = true;

      final eraIrrigando = statusAnterior?.irrigando ?? false;
      final estaIrrigando = status.irrigando;
      final agora = DateTime.now();

      // Detecta início de irrigação automática (ESP disparou sem o app)
      if (estaIrrigando && !eraIrrigando && _idIrrigacaoAtual == null) {
        _inicioIrrigacaoAtual = agora;
        _apiClient
            .iniciarRegistroIrrigacao(umidadeAntes: status.umidadeAtual)
            .then((id) => _idIrrigacaoAtual = id);
      }

      // Detecta fim de irrigação (qualquer origem)
      if (!estaIrrigando && eraIrrigando && _idIrrigacaoAtual != null) {
        final duracaoReal = agora
            .difference(_inicioIrrigacaoAtual ?? agora)
            .inSeconds;
        final volume = duracaoReal * 400.0 / 60.0;
        _apiClient.finalizarRegistroIrrigacao(
          id: _idIrrigacaoAtual!,
          duracaoRealSegundos: duracaoReal,
          volumeEstimadoMl: volume,
          umidadeDepois: status.umidadeAtual,
        );
        _idIrrigacaoAtual = null;
        _inicioIrrigacaoAtual = null;
        _ultimaIrrigacao = agora;
        _configuracaoRepo.salvarUltimaIrrigacao(agora);
      }

      // Registra umidade a cada 10 minutos
      if (_ultimoRegistroUmidade == null ||
          agora.difference(_ultimoRegistroUmidade!) >=
              _intervaloRegistroUmidade) {
        _apiClient.registrarUmidade(
          status.umidadeAtual,
          _configuracao.modo.valor,
        );
        _ultimoRegistroUmidade = agora;
      }

      _statusEsp = status;
    } else {
      _falhasConsecutivas++;
      if (_falhasConsecutivas >= 3) {
        _conectado = false;
        _statusEsp = null;
      }
    }
    notifyListeners();
  }

  Future<void> _buscarClima(String cidade) async {
    _clima = await _climaClient.buscarClima(cidade);
    notifyListeners();
  }

  Future<void> recarregarClima() async {
    final cidade = await _configuracaoRepo.buscarCidade();
    await _buscarClima(cidade);
  }

  DateTime? _bloqueioPolling;
  int _falhasConsecutivas = 0;

  bool _aguardandoResposta = false;
  bool get aguardandoResposta => _aguardandoResposta;

  int? _idIrrigacaoAtual;
  DateTime? _inicioIrrigacaoAtual;
  DateTime? _ultimoRegistroUmidade;

  // Intervalo de 10 minutos entre registros de umidade
  static const Duration _intervaloRegistroUmidade = Duration(minutes: 10);

  Future<bool> irrigarManual(bool ligar) async {
    _bloqueioPolling = DateTime.now().add(const Duration(seconds: 5));
    _aguardandoResposta = true;
    notifyListeners();

    final sucesso = await _espClient.irrigar(
      ligar: ligar,
      duracaoSegundos: _configuracao.duracaoPadrao.segundos,
      manual: true,
    );

    _bloqueioPolling = null;
    _aguardandoResposta = false;

    if (sucesso && _statusEsp != null) {
      _statusEsp = StatusEspDto(
        irrigando: ligar,
        irrigacaoManual: ligar,
        umidadeAtual: _statusEsp!.umidadeAtual,
        umidadeMinima: _statusEsp!.umidadeMinima,
        modoPrioridade: _statusEsp!.modoPrioridade,
        duracaoUmidade: _statusEsp!.duracaoUmidade,
        sensorSeco: _statusEsp!.sensorSeco,
        sensorUmido: _statusEsp!.sensorUmido,
        sensorRaw: _statusEsp!.sensorRaw,
      );
      notifyListeners();
    }

    if (sucesso) {
      if (ligar) {
        _inicioIrrigacaoAtual = DateTime.now();
        final umidadeAtual = _statusEsp?.umidadeAtual ?? 0;
        _idIrrigacaoAtual = await _apiClient.iniciarRegistroIrrigacao(
          umidadeAntes: umidadeAtual,
        );
      } else {
        _ultimaIrrigacao = DateTime.now();
        await _configuracaoRepo.salvarUltimaIrrigacao(_ultimaIrrigacao!);
        notifyListeners();

        if (_idIrrigacaoAtual != null && _inicioIrrigacaoAtual != null) {
          final duracaoReal = DateTime.now()
              .difference(_inicioIrrigacaoAtual!)
              .inSeconds;
          final volume = duracaoReal * 400.0 / 60.0;
          final umidadeAtual = _statusEsp?.umidadeAtual ?? 0;
          await _apiClient.finalizarRegistroIrrigacao(
            id: _idIrrigacaoAtual!,
            duracaoRealSegundos: duracaoReal,
            volumeEstimadoMl: volume,
            umidadeDepois: umidadeAtual,
          );
          _idIrrigacaoAtual = null;
          _inicioIrrigacaoAtual = null;
        }
      }
    } else {
      await atualizarStatusEsp();
    }

    return sucesso;
  }

  Future<void> verificarAgendamentos() async {
    if (_configuracao.modo == ModoIrrigacao.umidade) return;

    final agora = HorarioIrrigacao.deTimeOfDay(TimeOfDay.now());
    final chave = agora.formatado;
    if (_ultimoAgendamentoExecutado == chave) return;

    final agendamento = _servicoAgendamento.encontrarParaAgoraExato(
      _agendamentos,
    );
    if (agendamento == null || irrigando) return;

    _ultimoAgendamentoExecutado = chave;
    bool irrigou = false;

    // Sempre usa a duração global — não a duração salva no agendamento
    final duracaoAtual = _configuracao.duracaoPadrao.segundos;

    if (_configuracao.modo == ModoIrrigacao.combinado) {
      irrigou = await _espClient.irrigarSeNecessario(duracaoAtual);
    } else {
      irrigou = await _espClient.irrigar(
        ligar: true,
        duracaoSegundos: duracaoAtual,
        manual: false,
      );
    }

    if (irrigou) {
      _ultimaIrrigacao = DateTime.now();
      await _configuracaoRepo.salvarUltimaIrrigacao(_ultimaIrrigacao!);
      notifyListeners();
    }
  }

  Future<void> adicionarAgendamento(Agendamento agendamento) async {
    await _agendamentoRepo.adicionar(agendamento);
    _agendamentos = await _agendamentoRepo.buscarTodos();
    notifyListeners();
  }

  Future<void> removerAgendamento(String id) async {
    await _agendamentoRepo.remover(id);
    _agendamentos = await _agendamentoRepo.buscarTodos();
    notifyListeners();
  }

  Future<void> atualizarAgendamento(Agendamento agendamento) async {
    await _agendamentoRepo.atualizar(agendamento);
    _agendamentos = await _agendamentoRepo.buscarTodos();
    notifyListeners();
  }

  Future<void> atualizarModo(ModoIrrigacao modo) async {
    _configuracao = _configuracao.copyWith(modo: modo);
    notifyListeners();
    await _configuracaoRepo.salvar(_configuracao);
    // Envia para o ESP em background — inclui o intervalo atual
    _espClient.atualizarConfig(
      umidadeMinima: _configuracao.umidadeMinima.valor,
      modoPrioridade: modo.valor,
      duracaoUmidade: _configuracao.duracaoPadrao.segundos,
      intervaloMinutos: _configuracao.intervaloRega.minutos,
    );
  }

  Future<void> atualizarUmidadeMinima(int valor) async {
    _configuracao = _configuracao.copyWith(
      umidadeMinima: NivelUmidade.configuravel(valor),
    );
    await _configuracaoRepo.salvar(_configuracao);
    await _configuracaoRepo.salvarPlantaSelecionada('');
    notifyListeners();

    // ESP em background — não bloqueia UI
    _espClient.atualizarConfig(
      umidadeMinima: _configuracao.umidadeMinima.valor,
      modoPrioridade: _configuracao.modo.valor,
      duracaoUmidade: _configuracao.duracaoPadrao.segundos,
      intervaloMinutos: _configuracao.intervaloRega.minutos,
    );
  }

  Future<void> atualizarDuracaoPadrao(int segundos) async {
    _configuracao = _configuracao.copyWith(
      duracaoPadrao: DuracaoRega(segundos),
    );
    await _configuracaoRepo.salvar(_configuracao);
    await _configuracaoRepo.salvarPlantaSelecionada('');
    notifyListeners();

    // ESP em background
    _espClient.atualizarConfig(
      umidadeMinima: _configuracao.umidadeMinima.valor,
      modoPrioridade: _configuracao.modo.valor,
      duracaoUmidade: _configuracao.duracaoPadrao.segundos,
      intervaloMinutos: _configuracao.intervaloRega.minutos,
    );
  }

  Future<bool> resetarWifi() async {
    final sucesso = await _espClient.resetarWifi();
    if (sucesso) {
      // Atualiza estado imediatamente sem esperar o timer
      _conectado = false;
      _statusEsp = null;
      _falhasConsecutivas = 0;
      notifyListeners();
    }
    return sucesso;
  }

  Future<void> desmarcarPlanta() async {
    await _configuracaoRepo.salvarPlantaSelecionada('');
  }

  Future<void> recarregarConfiguracao() async {
    _configuracao = await _configuracaoRepo.buscar();
    notifyListeners();
  }

  int get sensorRaw => _statusEsp?.sensorRaw ?? 0;
  int get sensorSeco => _statusEsp?.sensorSeco ?? 4095;
  int get sensorUmido => _statusEsp?.sensorUmido ?? 835;

  Future<bool> calibrarSensor({required int seco, required int umido}) async {
    return await _espClient.calibrarSensor(
      sensorSeco: seco,
      sensorUmido: umido,
    );
  }

  int get intervaloRegaMinutos => _configuracao.intervaloRega.minutos;

  Future<void> atualizarIntervaloRega(int minutos) async {
    _configuracao = _configuracao.copyWith(
      intervaloRega: IntervaloRega(minutos),
    );
    await _configuracaoRepo.salvarIntervaloMinutos(minutos);
    // Envia para o ESP em background
    _espClient.atualizarConfig(
      umidadeMinima: _configuracao.umidadeMinima.valor,
      modoPrioridade: _configuracao.modo.valor,
      duracaoUmidade: _configuracao.duracaoPadrao.segundos,
      intervaloMinutos: minutos,
    );
    notifyListeners();
  }
}
