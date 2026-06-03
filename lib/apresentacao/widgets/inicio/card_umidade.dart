import 'package:flutter/material.dart';
import '../../../dominio/value_objects/nivel_umidade.dart';

class CardUmidade extends StatelessWidget {
  final int umidadeAtual;
  final NivelUmidade umidadeMinima;
  final bool conectado;

  const CardUmidade({
    super.key,
    required this.umidadeAtual,
    required this.umidadeMinima,
    required this.conectado,
  });

  bool get _abaixoDoLimite =>
      conectado && umidadeAtual < umidadeMinima.valor;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Umidade do solo',
                style: TextStyle(
                    fontSize: 12, color: cor.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              conectado ? '$umidadeAtual%' : '—',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _abaixoDoLimite ? cor.error : cor.primary,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: conectado ? umidadeAtual / 100 : 0,
              backgroundColor: cor.surfaceContainerHighest,
              color: _abaixoDoLimite ? cor.error : cor.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text('Limite: ${umidadeMinima.formatado}',
                style: TextStyle(
                    fontSize: 11, color: cor.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}