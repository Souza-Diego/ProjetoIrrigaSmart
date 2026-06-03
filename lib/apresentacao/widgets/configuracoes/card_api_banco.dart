import 'package:flutter/material.dart';

class CardApiBanco extends StatefulWidget {
  final bool online;
  final String urlAtual;
  final Future<void> Function(String url) aoSalvar;

  const CardApiBanco({
    super.key,
    required this.online,
    required this.urlAtual,
    required this.aoSalvar,
  });

  @override
  State<CardApiBanco> createState() => _CardApiBancoState();
}

class _CardApiBancoState extends State<CardApiBanco> {
  bool _editando = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.urlAtual);
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.online ? cor.primary : cor.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.online
                        ? 'Banco de dados conectado'
                        : 'Banco de dados desconectado',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.online ? cor.primary : cor.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _editando ? Icons.close : Icons.edit_outlined,
                    color: cor.primary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _editando = !_editando),
                ),
              ],
            ),
            if (!_editando && widget.urlAtual.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.urlAtual,
                style: TextStyle(fontSize: 11, color: cor.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (_editando) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL da API',
                  hintText: 'https://abc123.ngrok-free.app',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final url = _ctrl.text.trim();
                    if (url.isEmpty) return;
                    await widget.aoSalvar(url);
                    if (!context.mounted) return;
                    setState(() => _editando = false);
                  },
                  child: const Text('Salvar URL'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
