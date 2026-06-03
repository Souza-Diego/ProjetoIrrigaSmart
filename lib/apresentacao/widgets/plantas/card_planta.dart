import 'package:flutter/material.dart';
import '../../../dados/plantas/dados_plantas.dart';

class CardPlanta extends StatelessWidget {
  final DadosPlanta planta;
  final bool ativa;
  final VoidCallback aoTocar;

  const CardPlanta({
    super.key,
    required this.planta,
    required this.ativa,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: ativa ? cor.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: planta.cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    planta.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            planta.nome,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ativa ? cor.primary : cor.onSurface,
                            ),
                          ),
                        ),
                        if (ativa)
                          Icon(
                            Icons.check_circle,
                            color: cor.primary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      planta.descricao,
                      style: TextStyle(
                        fontSize: 12,
                        color: cor.onSurfaceVariant,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tags de irrigação
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _TagPlanta(
                          icone: Icons.water_drop_outlined,
                          texto: 'Umidade: ${planta.umidadeIdeal}',
                          cor: planta.cor,
                        ),
                        _TagPlanta(
                          icone: Icons.schedule_outlined,
                          texto: 'Regar: ${planta.frequencia}',
                          cor: planta.cor,
                        ),
                        _TagPlanta(
                          icone: Icons.timer_outlined,
                          texto: 'Duração: ${planta.duracaoSugerida}',
                          cor: planta.cor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Tags de ambiente
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _TagPlanta(
                          icone: Icons.wb_sunny_outlined,
                          texto: 'Sol: ${planta.exposicaoSolar}',
                          cor: cor.onSurfaceVariant,
                        ),
                        _TagPlanta(
                          icone: planta.ambienteIdeal.contains('Interno')
                              ? Icons.home_outlined
                              : Icons.park_outlined,
                          texto: 'Ambiente: ${planta.ambienteIdeal}',
                          cor: cor.onSurfaceVariant,
                        ),
                        _TagPlanta(
                          icone: Icons.water_outlined,
                          texto: 'Excesso: ${planta.sensibilidadeExcesso}',
                          cor: _corSensibilidade(
                            planta.sensibilidadeExcesso,
                            cor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _corSensibilidade(String sensibilidade, ColorScheme cor) {
    switch (sensibilidade) {
      case 'Alta':
        return cor.error;
      case 'Média':
        return const Color(0xFFBA7517);
      default:
        return cor.primary;
    }
  }
}

class _TagPlanta extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color cor;

  const _TagPlanta({
    required this.icone,
    required this.texto,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 11, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              color: cor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
