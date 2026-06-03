import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../aplicacao/irrigacao_app_service.dart';
import '../../dominio/entidades/agendamento.dart';
import '../../dominio/value_objects/horario_irrigacao.dart';
import '../../dominio/value_objects/duracao_rega.dart';
import '../../dominio/value_objects/modo_irrigacao.dart';
import '../widgets/controle/card_horario_agendamento.dart';
import '../widgets/controle/card_duracao_rega.dart';
import '../widgets/controle/card_umidade_minima.dart';
import '../widgets/controle/opcao_modo_irrigacao.dart';

class TelaControle extends StatefulWidget {
  final IrrigacaoAppService service;
  const TelaControle({super.key, required this.service});

  @override
  State<TelaControle> createState() => _TelaControleState();
}

class _TelaControleState extends State<TelaControle> {
  final TextEditingController _umidadeController = TextEditingController();

  // Estado local para sliders responderem em tempo real
  late int _umidadeLocal;
  late int _duracaoLocal;
  late int _intervaloLocal;
  late TextEditingController _intervaloController;

  IrrigacaoAppService get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _service.addListener(_rebuild);
    _umidadeLocal = _service.configuracao.umidadeMinima.valor;
    _duracaoLocal = _service.configuracao.duracaoPadrao.segundos;
    _umidadeController.text = '$_umidadeLocal';
    _intervaloLocal = _service.configuracao.intervaloRega.minutos;
    _intervaloController = TextEditingController(text: '$_intervaloLocal');
  }

  @override
  void dispose() {
    _umidadeController.dispose();
    _service.removeListener(_rebuild);
    _intervaloController.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _adicionarAgendamento() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Escolha o horário',
    );
    if (hora == null) return;
    await _service.adicionarAgendamento(
      Agendamento.novo(
        horario: HorarioIrrigacao.deTimeOfDay(hora),
        duracao: DuracaoRega(_duracaoLocal),
      ),
    );
  }

  Future<void> _editarAgendamento(Agendamento ag) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: ag.horario.comoTimeOfDay,
      helpText: 'Editar horário',
    );
    if (hora == null) return;
    ag.horario = HorarioIrrigacao.deTimeOfDay(hora);
    await _service.atualizarAgendamento(ag);
  }

  void _finalizarEdicaoUmidade() async {
    final numero = int.tryParse(_umidadeController.text) ?? _umidadeLocal;
    final clampado = numero.clamp(10, 90);
    setState(() {
      _umidadeLocal = clampado;
      _umidadeController.text = '$clampado';
    });
    await _service.atualizarUmidadeMinima(clampado);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final config = _service.configuracao;
    final usaHorarios =
        config.modo == ModoIrrigacao.horario ||
        config.modo == ModoIrrigacao.combinado;
    final usaUmidade =
        config.modo == ModoIrrigacao.umidade ||
        config.modo == ModoIrrigacao.combinado;

    return Scaffold(
      backgroundColor: cor.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controle',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: cor.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Modo
              Text(
                'Modo de irrigação',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cor.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como o sistema decide quando irrigar:',
                        style: TextStyle(
                          fontSize: 13,
                          color: cor.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...ModoIrrigacao.values.map(
                        (modo) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OpcaoModoIrrigacao(
                            valor: modo,
                            modoAtual: config.modo,
                            aoSelecionar: (m) async {
                              await _service.atualizarModo(m);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Duração
              Text(
                'Duração da irrigação',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cor.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              CardDuracaoRega(
                valorSegundos: _duracaoLocal,
                duracaoFormatada: DuracaoRega(_duracaoLocal).formatada,
                titulo: 'Duração da irrigação',
                descricao: 'Tempo de irrigação a cada acionamento:',
                aoAlterar: (val) {
                  setState(() => _duracaoLocal = val.round());
                },
                aoFinalizar: (val) async {
                  await _service.atualizarDuracaoPadrao(val.round());
                },
              ),
              const SizedBox(height: 24),

              // Horários
              if (usaHorarios) ...[
                Text(
                  'Horários de irrigação',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (_service.agendamentos.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Nenhum horário cadastrado.\nToque em "Adicionar horário" para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: cor.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ..._service.agendamentos.map(
                  (ag) => CardHorarioAgendamento(
                    agendamento: ag,
                    aoAlternarAtivo: (val) async {
                      ag.ativo = val;
                      await _service.atualizarAgendamento(ag);
                    },
                    aoEditar: () => _editarAgendamento(ag),
                    aoRemover: () async {
                      await _service.removerAgendamento(ag.id);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _adicionarAgendamento,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar horário'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Umidade
              if (usaUmidade) ...[
                Text(
                  'Umidade do solo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                CardUmidadeMinima(
                  valor: _umidadeLocal,
                  controller: _umidadeController,
                  descricao: config.modo == ModoIrrigacao.combinado
                      ? 'Irrigar no horário apenas se a umidade estiver abaixo de:'
                      : 'Irrigar automaticamente abaixo de:',
                  aoAlterarSlider: (val) {
                    setState(() {
                      _umidadeLocal = val.round();
                      _umidadeController.text = '$_umidadeLocal';
                    });
                  },
                  aoFinalizarSlider: (val) async {
                    await _service.atualizarUmidadeMinima(val.round());
                  },
                  aoAlterarTexto: (val) {
                    final numero = int.tryParse(val);
                    if (numero == null) return;
                    setState(() => _umidadeLocal = numero.clamp(10, 90));
                  },
                  aoFinalizarEdicao: _finalizarEdicaoUmidade,
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intervalo mínimo entre regas automáticas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tempo de espera após uma rega automática antes de acionar novamente. '
                          'Evita encharcar o solo enquanto a água ainda está sendo absorvida. '
                          'Use 0 para sem restrição.',
                          style: TextStyle(
                            fontSize: 12,
                            color: cor.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _intervaloLocal.toDouble(),
                                min: 0,
                                max: 60,
                                divisions: 12,
                                activeColor: cor.primary,
                                label: _intervaloLocal == 0
                                    ? 'Sem intervalo'
                                    : '$_intervaloLocal min',
                                onChanged: (val) {
                                  setState(() {
                                    _intervaloLocal = val.round();
                                    _intervaloController.text =
                                        '${val.round()}';
                                  });
                                },
                                onChangeEnd: (val) async {
                                  await _service.atualizarIntervaloRega(
                                    val.round(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 56,
                              child: TextField(
                                controller: _intervaloController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 10,
                                  ),
                                ),
                                onEditingComplete: () async {
                                  final v =
                                      int.tryParse(_intervaloController.text) ??
                                      10;
                                  final clamp = v.clamp(0, 60);
                                  setState(() {
                                    _intervaloLocal = clamp;
                                    _intervaloController.text = '$clamp';
                                  });
                                  FocusScope.of(context).unfocus();
                                  await _service.atualizarIntervaloRega(clamp);
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'min',
                              style: TextStyle(
                                fontSize: 13,
                                color: cor.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
