import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardUmidadeMinima extends StatelessWidget {
  final int valor;
  final TextEditingController controller;
  final String descricao;
  final ValueChanged<double> aoAlterarSlider;
  final ValueChanged<double> aoFinalizarSlider;
  final ValueChanged<String> aoAlterarTexto;
  final VoidCallback aoFinalizarEdicao;

  const CardUmidadeMinima({
    super.key,
    required this.valor,
    required this.controller,
    required this.descricao,
    required this.aoAlterarSlider,
    required this.aoFinalizarSlider,
    required this.aoAlterarTexto,
    required this.aoFinalizarEdicao,
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
            Text(descricao,
                style: TextStyle(
                    fontSize: 13, color: cor.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: valor.toDouble(),
                    min: 10,
                    max: 90,
                    divisions: 16,
                    activeColor: cor.primary,
                    label: '$valor%',
                    onChanged: aoAlterarSlider,
                    onChangeEnd: aoFinalizarSlider,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      suffixText: '%',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                    ),
                    onChanged: aoAlterarTexto,
                    onEditingComplete: aoFinalizarEdicao,
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