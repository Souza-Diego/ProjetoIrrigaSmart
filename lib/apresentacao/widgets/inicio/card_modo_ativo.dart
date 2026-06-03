import 'package:flutter/material.dart';
import '../../../dominio/value_objects/modo_irrigacao.dart';

class CardModoAtivo extends StatelessWidget {
  final ModoIrrigacao modo;

  const CardModoAtivo({super.key, required this.modo});

  IconData get _icone {
    switch (modo) {
      case ModoIrrigacao.horario:
        return Icons.schedule;
      case ModoIrrigacao.umidade:
        return Icons.water_drop_outlined;
      case ModoIrrigacao.combinado:
        return Icons.tune;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      color: cor.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(_icone, color: cor.primary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modo de irrigação',
                    style: TextStyle(
                        fontSize: 11,
                        color: cor.onSurfaceVariant)),
                Text(modo.rotulo,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cor.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}