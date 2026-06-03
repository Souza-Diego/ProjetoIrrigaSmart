import 'package:flutter/material.dart';
import '../../../dados/dtos/clima_dto.dart';

class CardClima extends StatelessWidget {
  final ClimaDto? clima;
  final bool carregando;

  const CardClima({super.key, required this.clima, required this.carregando});

  IconData _iconeClima(String icone) {
    if (icone.startsWith('01')) {
      return Icons.wb_sunny;
    }
    if (icone.startsWith('02') ||
        icone.startsWith('03') ||
        icone.startsWith('04')) {
      return Icons.cloud;
    }
    if (icone.startsWith('09') || icone.startsWith('10')) {
      return Icons.grain;
    }
    if (icone.startsWith('11')) {
      return Icons.thunderstorm;
    }
    if (icone.startsWith('13')) {
      return Icons.ac_unit;
    }
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      color: cor.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: carregando
            ? Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cor.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Carregando clima...',
                    style: TextStyle(color: cor.onPrimaryContainer),
                  ),
                ],
              )
            : clima == null
            ? Row(
                children: [
                  Icon(Icons.cloud_off, color: cor.primary, size: 36),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clima indisponível',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cor.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Verifique sua conexão',
                        style: TextStyle(
                          fontSize: 13,
                          color: cor.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(_iconeClima(clima!.icone), color: cor.primary, size: 40),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${clima!.temperatura.toStringAsFixed(1)}°C — ${clima!.condicao}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cor.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        clima!.cidade,
                        style: TextStyle(
                          fontSize: 13,
                          color: cor.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
