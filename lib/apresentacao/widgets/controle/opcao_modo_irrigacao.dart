import 'package:flutter/material.dart';
import '../../../dominio/value_objects/modo_irrigacao.dart';

class OpcaoModoIrrigacao extends StatelessWidget {
  final ModoIrrigacao valor;
  final ModoIrrigacao modoAtual;
  final Future<void> Function(ModoIrrigacao) aoSelecionar;

  const OpcaoModoIrrigacao({
    super.key,
    required this.valor,
    required this.modoAtual,
    required this.aoSelecionar,
  });

  bool get _selecionado => valor == modoAtual;

  String get _descricao {
    switch (valor) {
      case ModoIrrigacao.horario:
        return 'Irriga nos horários definidos, independente da umidade.';
      case ModoIrrigacao.umidade:
        return 'Irriga sempre que a umidade do solo cair abaixo do limite definido.';
      case ModoIrrigacao.combinado:
        return 'Irriga nos horários definidos, mas só se a umidade estiver abaixo do limite.';
    }
  }

  IconData get _icone {
    switch (valor) {
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

    return GestureDetector(
      onTap: () => aoSelecionar(valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selecionado
              ? cor.primaryContainer
              : cor.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selecionado ? cor.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(_icone,
                color: _selecionado
                    ? cor.primary
                    : cor.onSurfaceVariant,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valor.rotulo,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selecionado
                            ? cor.primary
                            : cor.onSurface),
                  ),
                  Text(
                    _descricao,
                    style: TextStyle(
                        fontSize: 12,
                        color: _selecionado
                            ? cor.onPrimaryContainer
                            : cor.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (_selecionado)
              Icon(Icons.check_circle,
                  color: cor.primary, size: 20),
          ],
        ),
      ),
    );
  }
}