import 'package:flutter/material.dart';

class CardStatusIrrigacao extends StatelessWidget {
  final bool irrigando;
  final bool conectado;
  final bool umidadeAbaixoDoLimite;
  final DateTime? ultimaIrrigacao;

  const CardStatusIrrigacao({
    super.key,
    required this.irrigando,
    required this.conectado,
    required this.umidadeAbaixoDoLimite,
    required this.ultimaIrrigacao,
  });

  String get _labelStatus {
    if (irrigando) return 'Irrigando agora...';
    if (!conectado) return 'IrrigaSmart desconectado';
    if (umidadeAbaixoDoLimite) return 'Umidade abaixo do limite!';
    return 'Sistema ativo';
  }

  IconData get _icone {
    if (irrigando) return Icons.water_drop;
    if (!conectado) return Icons.wifi_off;
    if (umidadeAbaixoDoLimite) return Icons.warning_amber_rounded;
    return Icons.check_circle;
  }

  String _formatarDataHora(DateTime data) {
    final hoje = DateTime.now();
    final ontem = hoje.subtract(const Duration(days: 1));
    final hora =
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    if (data.day == hoje.day && data.month == hoje.month) {
      return 'hoje às $hora';
    } else if (data.day == ontem.day && data.month == ontem.month) {
      return 'ontem às $hora';
    }
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} às $hora';
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final corIcone = !conectado
        ? cor.onSurfaceVariant
        : umidadeAbaixoDoLimite && !irrigando
            ? cor.error
            : cor.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_icone, color: corIcone),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelStatus,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: corIcone),
                ),
                Text(
                  ultimaIrrigacao != null
                      ? 'Última irrigação: ${_formatarDataHora(ultimaIrrigacao!)}'
                      : 'Última irrigação: —',
                  style: TextStyle(
                      fontSize: 12, color: cor.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}