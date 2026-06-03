import 'package:flutter/material.dart';
import '../../aplicacao/planta_app_service.dart';
import '../../dados/plantas/dados_plantas.dart';
import '../widgets/plantas/card_planta.dart';

class TelaPlantas extends StatefulWidget {
  final PlantaAppService? plantaService;
  const TelaPlantas({super.key, this.plantaService});

  @override
  State<TelaPlantas> createState() => TelaplantasState();
}

class TelaplantasState extends State<TelaPlantas> {
  late final PlantaAppService _service;
  final TextEditingController _buscaController = TextEditingController();
  String _termoBusca = '';
  String? _plantaAtiva;

  @override
  void initState() {
    super.initState();
    _service = widget.plantaService ?? PlantaAppService();
    recarregar();
  }

  void recarregar() {
    _service.buscarPlantaSelecionada().then((nome) {
      if (!mounted) return;
      setState(() => _plantaAtiva = nome);
    });
  }

  List<DadosPlanta> get _filtradas {
    if (_termoBusca.isEmpty) return listaPlantas;
    return listaPlantas
        .where(
          (p) => p.nome.toLowerCase().startsWith(_termoBusca.toLowerCase()),
        )
        .toList();
  }

  void _mostrarDialog(DadosPlanta planta) {
    final cor = Theme.of(context).colorScheme;
    final jaAtiva = planta.nome == _plantaAtiva;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(planta.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(planta.nome),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parâmetros de automação',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cor.primary,
                ),
              ),
              const SizedBox(height: 10),
              _LinhaParam(
                icone: Icons.water_drop_outlined,
                label: 'Umidade mínima',
                valor: '${planta.umidadeMinimaValor}%',
              ),
              const SizedBox(height: 6),
              _LinhaParam(
                icone: Icons.timer_outlined,
                label: 'Duração da irrigação',
                valor: planta.duracaoSugerida,
              ),
              const SizedBox(height: 6),
              _LinhaParam(
                icone: Icons.water_outlined,
                label: 'Volume estimado',
                valor: '${planta.volumePorRega} (anel irrigador ~400 ml/min)',
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: jaAtiva
                      ? cor.primaryContainer
                      : cor.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      jaAtiva ? Icons.check_circle : Icons.info_outline,
                      size: 16,
                      color: cor.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        jaAtiva
                            ? 'Esta planta já está ativa no Controle.'
                            : 'Ao aplicar, a umidade mínima será ${planta.umidadeMinimaValor}% e a duração ${planta.duracaoSugerida}. Os horários de irrigação devem ser configurados manualmente na tela Controle.',
                        style: TextStyle(
                          fontSize: 12,
                          color: jaAtiva
                              ? cor.onPrimaryContainer
                              : cor.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          if (!jaAtiva)
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _service.aplicarParametros(planta);
                if (!mounted) return;
                setState(() => _plantaAtiva = planta.nome);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Parâmetros de ${planta.nome} aplicados!'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Usar esta planta'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final filtradas = _filtradas;

    return Scaffold(
      backgroundColor: cor.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Plantas',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: cor.primary,
                ),
              ),
            ),
            if (_plantaAtiva != null && _plantaAtiva!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Card(
                  color: cor.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: cor.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Ativa: $_plantaAtiva',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cor.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _buscaController,
                onChanged: (val) => setState(() => _termoBusca = val),
                decoration: InputDecoration(
                  hintText: 'Buscar planta...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _termoBusca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaController.clear();
                            setState(() => _termoBusca = '');
                          },
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: filtradas.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma planta encontrada.',
                        style: TextStyle(color: cor.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filtradas.length + 1,
                      itemBuilder: (context, index) {
                        if (index == filtradas.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Base técnica dos parâmetros',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cor.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Os valores de umidade e irrigação foram definidos com base em referências da Embrapa e da Royal Horticultural Society (RHS). '
                                  'As durações consideram o anel irrigador 3D do projeto, com vazão aproximada de 400 ml/min. '
                                  'Esses parâmetros funcionam como uma recomendação inicial e podem variar conforme clima, tamanho do vaso, substrato e exposição solar da planta.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cor.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          );
                        }
                        final planta = filtradas[index];
                        return CardPlanta(
                          planta: planta,
                          ativa: planta.nome == _plantaAtiva,
                          aoTocar: () => _mostrarDialog(planta),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _LinhaInfo({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icone, size: 16, color: cor.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cor.onSurface,
          ),
        ),
      ],
    );
  }
}
*/

class _LinhaParam extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _LinhaParam({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 16, color: cor.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
                ),
                TextSpan(
                  text: valor,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
