import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../dados/dtos/status_esp_dto.dart';
import '../persistencia/configuracao_repositorio_impl.dart';

class EspHttpClient {
  static const String _mdnsUrl = 'http://irrigasmart.local';
  static String? _ipCache;

  Future<String> _resolverUrl(String rota) async {
    // Usa IP em cache se disponível
    if (_ipCache != null) return 'http://$_ipCache$rota';

    // Tenta carregar IP salvo
    final repo = ConfiguracaoRepositorioImpl();
    final ipSalvo = await repo.carregarEnderecoEsp();
    if (ipSalvo.isNotEmpty) {
      _ipCache = ipSalvo;
      return 'http://$_ipCache$rota';
    }

    // Fallback mDNS
    return '$_mdnsUrl$rota';
  }

  Future<StatusEspDto?> buscarStatus() async {
    final json = await _get('/status');
    if (json == null) return null;
    return StatusEspDto.fromJson(json);
  }

  Future<bool> irrigar({
    required bool ligar,
    required int duracaoSegundos,
    required bool manual,
  }) async {
    return await _post('/irrigar', {
      'ligar': ligar,
      'duracao': duracaoSegundos,
      'manual': manual,
    });
  }

  Future<bool> irrigarSeNecessario(int duracaoSegundos) async {
    final resposta = await _postComResposta('/irrigarsenecessario', {
      'duracao': duracaoSegundos,
    });
    return resposta?['irrigou'] ?? false;
  }

  Future<bool> atualizarConfig({
    required int umidadeMinima,
    required String modoPrioridade,
    required int duracaoUmidade,
    int intervaloMinutos = 10,
  }) async {
    return await _post('/configurar', {
      'umidadeMinima': umidadeMinima,
      'modoPrioridade': modoPrioridade,
      'duracaoUmidade': duracaoUmidade,
      'intervaloMinutos': intervaloMinutos,
    });
  }

  Future<bool> resetarWifi() async {
    return await _post('/resetarwifi', {});
  }

  Future<Map<String, dynamic>?> _get(String rota) async {
    final url = await _resolverUrl(rota);
    try {
      final resposta = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 200) {
        return jsonDecode(resposta.body);
      }
      return null;
    } catch (_) {
      // Se falhou com IP, tenta mDNS
      if (_ipCache != null) {
        _ipCache = null;
        try {
          final resposta = await http
              .get(Uri.parse('$_mdnsUrl$rota'))
              .timeout(const Duration(seconds: 3));
          if (resposta.statusCode == 200) {
            return jsonDecode(resposta.body);
          }
        } catch (_) {}
      }
      return null;
    }
  }

  Future<bool> _post(String rota, Map<String, dynamic> body) async {
    final resultado = await _postComResposta(rota, body);
    return resultado != null;
  }

  Future<Map<String, dynamic>?> _postComResposta(
    String rota,
    Map<String, dynamic> body,
  ) async {
    final url = await _resolverUrl(rota);
    try {
      final resposta = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 3));
      if (resposta.statusCode == 200) {
        return jsonDecode(resposta.body);
      }
      return null;
    } catch (_) {
      // Se falhou com IP, tenta mDNS
      if (_ipCache != null) {
        _ipCache = null;
        try {
          final resposta = await http
              .post(
                Uri.parse('$_mdnsUrl$rota'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 3));
          if (resposta.statusCode == 200) {
            return jsonDecode(resposta.body);
          }
        } catch (_) {}
      }
      return null;
    }
  }

  Future<bool> calibrarSensor({
    required int sensorSeco,
    required int sensorUmido,
  }) async {
    return await _post('/calibrar', {
      'sensorSeco': sensorSeco,
      'sensorUmido': sensorUmido,
    });
  }
}
