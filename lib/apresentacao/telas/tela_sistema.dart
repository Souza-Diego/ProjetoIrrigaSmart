import 'package:flutter/material.dart';
import '../../aplicacao/sistema_app_service.dart';
import '../../dominio/entidades/registro_irrigacao.dart';
import '../../dominio/entidades/registro_umidade.dart';

class TelaSistema extends StatefulWidget {
  const TelaSistema({super.key});

  @override
  State<TelaSistema> createState() => _TelaSistemaState();
}

class _TelaSistemaState extends State<TelaSistema> {
  late final SistemaAppService _service;

  @override
  void initState() {
    super.initState();
    _service = SistemaAppService();
    _service.addListener(_rebuild);
    _service.carregarHistorico();
  }

  @override
  void dispose() {
    _service.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cor.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _service.carregarHistorico,
          color: cor.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: cor.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Irrigações ────────────────────────────────────
                _Titulo('Registro de irrigações'),
                const SizedBox(height: 8),
                if (_service.carregando)
                  Center(child: CircularProgressIndicator(color: cor.primary))
                else if (!_service.apiOnline)
                  _CardVazio(
                    'Banco de dados desconectado.\nConfigure a URL em Configurações.',
                  )
                else if (_service.irrigacoes.isEmpty)
                  _CardVazio('Nenhuma irrigação registrada ainda.')
                else ...[
                  ..._service.irrigacoes.map(
                    (r) => _CardIrrigacao(registro: r),
                  ),
                  const SizedBox(height: 4),
                  _SeletorRegistros(
                    label: 'Exibindo',
                    valor: _service.limiteIrrigacoes,
                    aoAlterar: _service.setLimiteIrrigacoes,
                  ),
                ],
                const SizedBox(height: 24),

                // ── Umidade ───────────────────────────────────────
                _Titulo('Leituras de umidade'),
                const SizedBox(height: 8),
                if (!_service.carregando) ...[
                  if (!_service.apiOnline)
                    _CardVazio('Banco de dados desconectado.')
                  else if (_service.umidades.isEmpty)
                    _CardVazio('Nenhuma leitura registrada ainda.')
                  else ...[
                    if (_service.umidadeMinima != null &&
                        _service.umidadeMaxima != null)
                      Card(
                        color: cor.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatUmidade(
                                label: 'Mínima',
                                valor: '${_service.umidadeMinima}%',
                                icone: Icons.arrow_downward,
                                cor: cor,
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: cor.primary.withValues(alpha: 0.3),
                              ),
                              _StatUmidade(
                                label: 'Máxima',
                                valor: '${_service.umidadeMaxima}%',
                                icone: Icons.arrow_upward,
                                cor: cor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ..._service.umidades.map((r) => _CardUmidade(registro: r)),
                    const SizedBox(height: 4),
                    _SeletorRegistros(
                      label: 'Exibindo',
                      valor: _service.limiteUmidades,
                      aoAlterar: _service.setLimiteUmidades,
                    ),
                  ],
                ],
                const SizedBox(height: 24),

                // ── Guia rápido ───────────────────────────────────
                _Titulo('Guia rápido'),
                const SizedBox(height: 8),
                _CardGuia(
                  titulo: 'Como o sensor funciona',
                  icone: Icons.sensors,
                  passos: [
                    'Insira o sensor na terra do vaso onde a planta está.',
                    'Ele mede automaticamente a umidade do solo a cada 5 segundos.',
                    'Quando a umidade cair abaixo do limite configurado, o sistema rega automaticamente (modos Umidade e Combinado).',
                    'Para melhores resultados, deixe o sensor a pelo menos 2 cm de profundidade na terra.',
                  ],
                ),
                const SizedBox(height: 8),
                _CardGuia(
                  titulo: 'Como usar a bomba',
                  icone: Icons.water_drop,
                  passos: [
                    'Coloque a bomba dentro do reservatório de água.',
                    'Encaixe a mangueira na saída da bomba e direcione a ponta para o vaso.',
                    'A bomba é alimentada por pilhas — certifique-se de que estão instaladas.',
                    'O sistema liga e desliga a bomba automaticamente conforme as configurações do app.',
                    'Para testar, use o botão "Irrigar agora" na tela Início.',
                  ],
                ),
                const SizedBox(height: 8),
                _CardGuia(
                  titulo: 'Seleção de planta no app',
                  icone: Icons.local_florist_outlined,
                  passos: [
                    'Na tela Plantas, toque na planta que você está cultivando.',
                    'Selecione "Usar esta planta" — o app ajusta automaticamente a umidade mínima e o tempo de rega.',
                    'Você pode ajustar esses valores manualmente na tela Controle.',
                    'Os horários de rega precisam ser configurados por você na tela Controle.',
                  ],
                ),
                const SizedBox(height: 8),
                _CardGuia(
                  titulo: 'Configuração inicial',
                  icone: Icons.settings,
                  passos: [
                    'Ligue o IrrigaSmart — o LED pisca 6 vezes indicando modo Bluetooth ativo.',
                    'No app, vá em Configurações → Configurar WiFi.',
                    'O app encontra o IrrigaSmart via Bluetooth. Informe o nome e a senha da sua rede WiFi.',
                    'Aguarde o reinício — quando o LED ficar aceso constantemente, o sistema está conectado.',
                    'Configure os modos e horários na tela Controle.',
                  ],
                ),
                const SizedBox(height: 24),

                // ── Sobre ─────────────────────────────────────────
                _Titulo('Sobre'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: cor.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IrrigaSmart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: cor.primary,
                                  ),
                                ),
                                Text(
                                  'Versão 1.0.0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cor.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Protótipo de sistema de irrigação inteligente '
                          'para plantas. Combina sensor de umidade do solo, '
                          'automação via app mobile e registro de dados em nuvem.',
                          style: TextStyle(
                            fontSize: 13,
                            color: cor.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _LinhaInfo('Instituição', 'FATEC Cruzeiro'),
                        _LinhaInfo('Destinado ao', 'Evento Acelera 2026/1'),
                        _LinhaInfo(
                          'Disciplinas',
                          'Sistemas Operacionais II, Dispositivos Móveis e Programação Web',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Equipe de desenvolvimento',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _LinhaInfo('', 'Diego Pereira de Souza'),
                        _LinhaInfo('', 'Mariana Aparecida Gomes Soares'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CardVazio extends StatelessWidget {
  final String mensagem;
  const _CardVazio(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIrrigacao extends StatelessWidget {
  final RegistroIrrigacao registro;
  const _CardIrrigacao({required this.registro});

  String _fmt(DateTime ts) =>
      '${ts.day.toString().padLeft(2, '0')}/'
      '${ts.month.toString().padLeft(2, '0')} '
      '${ts.hour.toString().padLeft(2, '0')}:'
      '${ts.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: registro.finalizado ? cor.primary : cor.tertiary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    registro.timestampFim != null
                        ? '${_fmt(registro.timestampInicio)} → ${_fmt(registro.timestampFim!)}'
                        : _fmt(registro.timestampInicio),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cor.onSurface,
                    ),
                  ),
                ),
                if (!registro.finalizado)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cor.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Em andamento',
                      style: TextStyle(fontSize: 11, color: cor.tertiary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _Detalhe('Duração', registro.duracaoFormatada, cor),
                if (registro.volumeEstimadoMl != null)
                  _Detalhe(
                    'Volume',
                    '${registro.volumeEstimadoMl!.toStringAsFixed(0)} ml',
                    cor,
                  ),
                if (registro.umidadeAntes != null)
                  _Detalhe('Antes', '${registro.umidadeAntes}%', cor),
                if (registro.umidadeDepois != null)
                  _Detalhe('Depois', '${registro.umidadeDepois}%', cor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Detalhe extends StatelessWidget {
  final String label;
  final String valor;
  final ColorScheme cor;
  const _Detalhe(this.label, this.valor, this.cor);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(fontSize: 12, color: cor.onSurfaceVariant),
          ),
          TextSpan(
            text: valor,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardUmidade extends StatelessWidget {
  final RegistroUmidade registro;
  const _CardUmidade({required this.registro});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final ts = registro.timestamp;
    final hora =
        '${ts.day.toString().padLeft(2, '0')}/'
        '${ts.month.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.sensors, color: cor.primary, size: 18),
            const SizedBox(width: 10),
            Text(
              hora,
              style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              '${registro.valorPercentual}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatUmidade extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icone;
  final ColorScheme cor;
  const _StatUmidade({
    required this.label,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: cor.primary, size: 16),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: cor.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: cor.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SeletorRegistros extends StatelessWidget {
  final String label;
  final int valor;
  final ValueChanged<int> aoAlterar;
  const _SeletorRegistros({
    required this.label,
    required this.valor,
    required this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$label $valor registros',
          style: TextStyle(fontSize: 12, color: cor.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: valor,
          isDense: true,
          underline: const SizedBox(),
          items: [3, 5, 10, 20]
              .map(
                (n) => DropdownMenuItem(
                  value: n,
                  child: Text('$n', style: TextStyle(color: cor.primary)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) aoAlterar(v);
          },
        ),
      ],
    );
  }
}

class _CardGuia extends StatefulWidget {
  final String titulo;
  final IconData icone;
  final List<String> passos;
  const _CardGuia({
    required this.titulo,
    required this.icone,
    required this.passos,
  });

  @override
  State<_CardGuia> createState() => _CardGuiaState();
}

class _CardGuiaState extends State<_CardGuia> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(widget.icone, color: cor.primary),
            title: Text(
              widget.titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              _expandido ? Icons.expand_less : Icons.expand_more,
              color: cor.onSurfaceVariant,
            ),
            onTap: () => setState(() => _expandido = !_expandido),
          ),
          if (_expandido)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.passos.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: cor.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: cor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: cor.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _LinhaInfo(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: label.isEmpty
          ? Text(
              '• $valor',
              style: TextStyle(fontSize: 13, color: cor.onSurfaceVariant),
            )
          : RichText(
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
                      fontWeight: FontWeight.w500,
                      color: cor.onSurface,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
