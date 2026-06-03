import 'package:flutter/material.dart';

class CardDuracaoRega extends StatelessWidget {
  final int valorSegundos;
  final String duracaoFormatada;
  final String titulo;
  final String descricao;
  final ValueChanged<double> aoAlterar;
  final ValueChanged<double> aoFinalizar;

  const CardDuracaoRega({
    super.key,
    required this.valorSegundos,
    required this.duracaoFormatada,
    required this.titulo,
    required this.descricao,
    required this.aoAlterar,
    required this.aoFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descricao,
              style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              duracaoFormatada,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor.primary,
              ),
            ),
            Slider(
              value: valorSegundos.toDouble(),
              min: 15,
              max: 300,
              divisions: 19,
              activeColor: cor.primary,
              label: duracaoFormatada,
              onChanged: aoAlterar,
              onChangeEnd: aoFinalizar,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['15s', '1 min', '2 min', '3 min', '4 min', '5 min']
                    .map(
                      (t) => Text(
                        t,
                        style: TextStyle(
                          fontSize: 10,
                          color: cor.onSurfaceVariant,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
