import 'package:flutter/material.dart';
import '../dominio/entidades/registro_irrigacao.dart';
import '../dominio/entidades/registro_umidade.dart';
import '../infraestrutura/api/irrigasmart_api_client.dart';


class SistemaAppService extends ChangeNotifier {
  final IrrigaSmartApiClient _apiClient;

  SistemaAppService({IrrigaSmartApiClient? apiClient})
    : _apiClient = apiClient ?? IrrigaSmartApiClient();

  List<RegistroIrrigacao> _irrigacoes = [];
  List<RegistroUmidade> _umidades = [];
  int? _umidadeMinima;
  int? _umidadeMaxima;
  bool _carregando = false;
  int _limiteIrrigacoes = 3;
  int _limiteUmidades = 3;

  List<RegistroIrrigacao> get irrigacoes => _irrigacoes;
  List<RegistroUmidade> get umidades => _umidades;
  int? get umidadeMinima => _umidadeMinima;
  int? get umidadeMaxima => _umidadeMaxima;
  bool get carregando => _carregando;
  bool get apiOnline => IrrigaSmartApiClient.estaOnline;
  int get limiteIrrigacoes => _limiteIrrigacoes;
  int get limiteUmidades => _limiteUmidades;

  void setLimiteIrrigacoes(int v) {
    _limiteIrrigacoes = v;
    carregarHistorico();
  }

  void setLimiteUmidades(int v) {
    _limiteUmidades = v;
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    _carregando = true;
    notifyListeners();
    try {
      final jsonIrr = await _apiClient.buscarIrrigacoes(_limiteIrrigacoes);
      final resultado = await _apiClient.buscarUmidadeComStats(_limiteUmidades);

      _irrigacoes = jsonIrr.map((j) => RegistroIrrigacao.fromJson(j)).toList();
      _umidades = resultado.leituras
          .map((j) => RegistroUmidade.fromJson(j))
          .toList();
      _umidadeMinima = resultado.minimo;
      _umidadeMaxima = resultado.maximo;
    } catch (e, stack) {
      debugPrint('Erro ao carregar histórico: $e\n$stack');
      _irrigacoes = [];
      _umidades = [];
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }
}
