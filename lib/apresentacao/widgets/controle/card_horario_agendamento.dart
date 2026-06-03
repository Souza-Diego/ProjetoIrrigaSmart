import 'package:flutter/material.dart';
import '../../../dominio/entidades/agendamento.dart';

class CardHorarioAgendamento extends StatelessWidget {
  final Agendamento agendamento;
  final ValueChanged<bool> aoAlternarAtivo;
  final VoidCallback aoEditar;
  final VoidCallback aoRemover;

  const CardHorarioAgendamento({
    super.key,
    required this.agendamento,
    required this.aoAlternarAtivo,
    required this.aoEditar,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.schedule, color: cor.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                agendamento.horario.formatado,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cor.onSurface,
                ),
              ),
            ),
            Switch(
              value: agendamento.ativo,
              activeThumbColor: cor.primary,
              onChanged: aoAlternarAtivo,
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: cor.primary, size: 20),
              onPressed: aoEditar,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: cor.error, size: 20),
              onPressed: aoRemover,
            ),
          ],
        ),
      ),
    );
  }
}
