import 'package:flutter/material.dart';
import '../../../dominio/entidades/agendamento.dart';

class CardProximoAgendamento extends StatelessWidget {
  final Agendamento? proximoAgendamento;
  final String duracaoFormatada;

  const CardProximoAgendamento({
    super.key,
    required this.proximoAgendamento,
    required this.duracaoFormatada,
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
            Text('Próxima irrigação',
                style: TextStyle(
                    fontSize: 12, color: cor.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              proximoAgendamento != null
                  ? proximoAgendamento!.horario.formatado
                  : '—',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cor.primary),
            ),
            const SizedBox(height: 8),
            Text(
              proximoAgendamento != null
                  ? 'Duração: $duracaoFormatada'
                  : 'Nenhum horário',
              style: TextStyle(
                  fontSize: 12, color: cor.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}