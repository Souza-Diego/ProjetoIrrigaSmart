import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardCalibracao extends StatefulWidget {
  final int sensorSeco;
  final int sensorUmido;
  final int sensorRaw;
  final Future<void> Function() aoAtualizar;
  final Future<bool> Function(int seco, int umido) aoSalvar;

  const CardCalibracao({
    super.key,
    required this.sensorSeco,
    required this.sensorUmido,
    required this.sensorRaw,
    required this.aoAtualizar,
    required this.aoSalvar,
  });

  @override
  State<CardCalibracao> createState() => _CardCalibracaoState();
}

class _CardCalibracaoState extends State<CardCalibracao> {
  late TextEditingController _secoCtrl;
  late TextEditingController _umidoCtrl;
  bool _editando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _secoCtrl = TextEditingController(text: widget.sensorSeco.toString());
    _umidoCtrl = TextEditingController(text: widget.sensorUmido.toString());
  }

  @override
  void didUpdateWidget(CardCalibracao old) {
    super.didUpdateWidget(old);
    if (!_editando) {
      _secoCtrl.text = widget.sensorSeco.toString();
      _umidoCtrl.text = widget.sensorUmido.toString();
    }
  }

  @override
  void dispose() {
    _secoCtrl.dispose();
    _umidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Leitura atual',
                  style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
                ),
                Row(
                  children: [
                    Text(
                      'Raw: ${widget.sensorRaw}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: cor.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: cor.primary, size: 18),
                      onPressed: widget.aoAtualizar,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'seco=${widget.sensorSeco} / úmido=${widget.sensorUmido}',
                    style: TextStyle(fontSize: 11, color: cor.onSurfaceVariant),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _editando = !_editando),
                  child: Text(_editando ? 'Cancelar' : 'Editar'),
                ),
              ],
            ),
            if (_editando) ...[
              const SizedBox(height: 8),
              Text(
                'Referência seco (0% — sensor no ar):',
                style: TextStyle(fontSize: 12, color: cor.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _secoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '4095',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Referência úmido (100% — terra recém-regada):',
                style: TextStyle(fontSize: 12, color: cor.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _umidoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '835',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _salvando
                      ? null
                      : () async {
                          final s = int.tryParse(_secoCtrl.text) ?? 4095;
                          final u = int.tryParse(_umidoCtrl.text) ?? 835;
                          setState(() => _salvando = true);
                          final ok = await widget.aoSalvar(s, u);
                          if (!context.mounted) return;
                          setState(() {
                            _salvando = false;
                            if (ok) _editando = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Calibração salva!'
                                    : 'Falha — verifique a conexão.',
                              ),
                              backgroundColor: ok
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          );
                        },
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar calibração'),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dica: sensor no ar → anote raw como "seco". Terra recém-regada → "úmido".',
                style: TextStyle(fontSize: 11, color: cor.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
