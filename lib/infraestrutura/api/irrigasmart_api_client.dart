import 'dart:convert';
import 'package:http/http.dart' as http;
import '../persistencia/configuracao_repositorio_impl.dart';

class IrrigaSmartApiClient {
  static String? _urlCache;

  // Circuit breaker
  static int _falhasConsecutivas = 0;
  static DateTime? _bloqueadoAte;
  static bool _confirmadoOnline = false;
  static const int _maxFalhas = 3;
  static const Duration _tempoBloqueio = Duration(minutes: 2);

  static bool get _estaBloqueado {
    if (_bloqueadoAte == null) return false;
    if (DateTime.now().isAfter(_bloqueadoAte!)) {
      // Bloqueio expirou — reseta para tentar novamente
      _bloqueadoAte = null;
      _falhasConsecutivas = 0;
      _confirmadoOnline = false;
      return false;
    }
    return true;
  }

  // true apenas após confirmação real de sucesso
  static bool get estaOnline => _confirmadoOnline && !_estaBloqueado;

  static void _registrarSucesso() {
    _falhasConsecutivas = 0;
    _bloqueadoAte = null;
    _confirmadoOnline = true;
  }

  static void _registrarFalha() {
    _confirmadoOnline = false;
    _falhasConsecutivas++;
    if (_falhasConsecutivas >= _maxFalhas) {
      _bloqueadoAte = DateTime.now().add(_tempoBloqueio);
    }
  }

  static void limparCache() {
    _urlCache = null;
    _confirmadoOnline = false;
    _falhasConsecutivas = 0;
    _bloqueadoAte = null;
  }

  Future<String> _getUrl() async {
    if (_urlCache != null) return _urlCache!;
    final repo = ConfiguracaoRepositorioImpl();
    _urlCache = await repo.carregarUrlApi();
    return _urlCache ?? '';
  }

  Future<bool> _post(String rota, Map<String, dynamic> body) async {
    if (_estaBloqueado) return false;
    final url = await _getUrl();
    if (url.isEmpty) return false;
    try {
      final resposta = await http
          .post(
            Uri.parse('$url$rota'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 201 || resposta.statusCode == 200) {
        _registrarSucesso();
        return true;
      }
      _registrarFalha();
      return false;
    } catch (_) {
      _registrarFalha();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _get(String rota) async {
    if (_estaBloqueado) return [];
    final url = await _getUrl();
    if (url.isEmpty) return [];
    try {
      final resposta = await http
          .get(Uri.parse('$url$rota'))
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 200) {
        _registrarSucesso(); // GET bem-sucedido também confirma online
        final lista = jsonDecode(resposta.body);
        if (lista is List) {
          return lista.whereType<Map<String, dynamic>>().toList();
        }
        return [];
      }
      _registrarFalha();
      return [];
    } catch (_) {
      _registrarFalha();
      return [];
    }
  }

  Future<bool> registrarIrrigacao({
    required int duracaoSegundos,
    required double volumeEstimadoMl,
    required String modo,
    required int umidadeAntes,
    int? umidadeDepois,
    String origem = 'app',
  }) => _post('/irrigacoes', {
    'duracao_segundos': duracaoSegundos,
    'volume_estimado_ml': volumeEstimadoMl,
    'modo': modo,
    'umidade_antes': umidadeAntes,
    'umidade_depois': umidadeDepois,
    'origem': origem,
  });

  Future<bool> registrarUmidade(int valor, String modo) =>
      _post('/umidade', {'valor': valor, 'modo': modo});  

  Future<List<Map<String, dynamic>>> buscarIrrigacoes([int limite = 3]) =>
      _get('/irrigacoes?limit=$limite');

  Future<List<Map<String, dynamic>>> buscarUmidade() => _get('/umidade');

  Future<({List<Map<String, dynamic>> leituras, int? minimo, int? maximo})>
  buscarUmidadeComStats(int limite) async {
    if (_estaBloqueado) {
      return (leituras: <Map<String, dynamic>>[], minimo: null, maximo: null);
    }
    final url = await _getUrl();
    if (url.isEmpty) {
      return (leituras: <Map<String, dynamic>>[], minimo: null, maximo: null);
    }
    try {
      final resposta = await http
          .get(Uri.parse('$url/umidade?limit=$limite'))
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 200) {
        _registrarSucesso();
        final body = jsonDecode(resposta.body);
        final lista = (body['leituras'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
        final stats = body['stats'] as Map<String, dynamic>? ?? {};
        return (
          leituras: lista,
          minimo: stats['minimo'] != null
              ? (stats['minimo'] as num).toInt()
              : null,
          maximo: stats['maximo'] != null
              ? (stats['maximo'] as num).toInt()
              : null,
        );
      }
      _registrarFalha();
      return (leituras: <Map<String, dynamic>>[], minimo: null, maximo: null);
    } catch (_) {
      _registrarFalha();
      return (leituras: <Map<String, dynamic>>[], minimo: null, maximo: null);
    }
  }

  Future<int?> iniciarRegistroIrrigacao({required int umidadeAntes}) async {
    if (_estaBloqueado) return null;
    final url = await _getUrl();
    if (url.isEmpty) return null;
    try {
      final resposta = await http
          .post(
            Uri.parse('$url/irrigacoes/iniciar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'umidade_antes': umidadeAntes}),
          )
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 201) {
        _registrarSucesso();
        final json = jsonDecode(resposta.body);
        return json['id'] as int?;
      }
      _registrarFalha();
      return null;
    } catch (_) {
      _registrarFalha();
      return null;
    }
  }

  Future<bool> finalizarRegistroIrrigacao({
    required int id,
    required int duracaoRealSegundos,
    required double volumeEstimadoMl,
    required int umidadeDepois,
  }) async {
    if (_estaBloqueado) return false;
    final url = await _getUrl();
    if (url.isEmpty) return false;
    try {
      final resposta = await http
          .patch(
            Uri.parse('$url/irrigacoes/$id/finalizar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'duracao_real_segundos': duracaoRealSegundos,
              'volume_estimado_ml': volumeEstimadoMl,
              'umidade_depois': umidadeDepois,
            }),
          )
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 200) {
        _registrarSucesso();
        return true;
      }
      _registrarFalha();
      return false;
    } catch (_) {
      _registrarFalha();
      return false;
    }
  }
}
