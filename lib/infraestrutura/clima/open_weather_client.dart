import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../dados/dtos/clima_dto.dart';

class OpenWeatherClient {
  static const String _apiKey = '399f4500af8332d52fe01b78efa8cbeb';

  Future<ClimaDto?> buscarClima(String cidade) async {
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$cidade'
        '&appid=$_apiKey'
        '&units=metric'
        '&lang=pt_br',
      );
      final resposta = await http
          .get(url)
          .timeout(const Duration(seconds: 5));
      if (resposta.statusCode == 200) {
        return ClimaDto.fromJson(jsonDecode(resposta.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}