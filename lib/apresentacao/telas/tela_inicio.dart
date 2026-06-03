import 'dart:async';
import 'package:flutter/material.dart';
import '../../aplicacao/irrigacao_app_service.dart';
import '../widgets/inicio/card_clima.dart';
import '../widgets/inicio/card_umidade.dart';
import '../widgets/inicio/card_proximo_agendamento.dart';
import '../widgets/inicio/card_status_irrigacao.dart';
import '../widgets/inicio/card_modo_ativo.dart';

class TelaInicio extends StatefulWidget {
  final IrrigacaoAppService service;
  const TelaInicio({super.key, required this.service});

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
    bool _carregandoClima = false;

  IrrigacaoAppService get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _service.addListener(_rebuild);
    _service.inicializar().then((_) {
      if (mounted) setState(() {});
    });    
  }

  @override
  void dispose() {    
    _service.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _alternarIrrigacao() async {
    final sucesso = await _service.irrigarManual(!_service.irrigando);
    if (!sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'IrrigaSmart não respondeu. Verifique a conexão e tente novamente.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _atualizar() async {
    setState(() => _carregandoClima = true);
    await _service.inicializar();
    if (mounted) setState(() => _carregandoClima = false);
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    if (_service.carregando) {
      return Scaffold(
        backgroundColor: cor.surface,
        body: Center(child: CircularProgressIndicator(color: cor.primary)),
      );
    }

    final umidadeAbaixo =
        _service.conectado &&
        _service.umidadeAtual < _service.configuracao.umidadeMinima.valor;

    return Scaffold(
      backgroundColor: cor.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _atualizar,
          color: cor.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IrrigaSmart',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: cor.primary,
                          ),
                        ),
                        Text(
                          'Bem-vindo, Diego',
                          style: TextStyle(
                            fontSize: 14,
                            color: cor.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _service.conectado ? Icons.wifi : Icons.wifi_off,
                          color: _service.conectado ? cor.primary : cor.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.water_drop, color: cor.primary, size: 36),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CardClima(clima: _service.clima, carregando: _carregandoClima),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CardUmidade(
                        umidadeAtual: _service.umidadeAtual,
                        umidadeMinima: _service.configuracao.umidadeMinima,
                        conectado: _service.conectado,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CardProximoAgendamento(
                        proximoAgendamento: _service.proximoAgendamento,
                        duracaoFormatada:
                            _service.configuracao.duracaoPadrao.formatada,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CardModoAtivo(modo: _service.configuracao.modo),
                const SizedBox(height: 16),
                CardStatusIrrigacao(
                  irrigando: _service.irrigando,
                  conectado: _service.conectado,
                  umidadeAbaixoDoLimite: umidadeAbaixo,
                  ultimaIrrigacao: _service.ultimaIrrigacao,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: _service.aguardandoResposta
                      ? FilledButton.icon(
                          onPressed: null,
                          icon: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          label: const Text('Aguardando...'),
                          style: FilledButton.styleFrom(
                            disabledBackgroundColor: const Color.fromARGB(255, 175, 175, 175),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        )
                      : _service.irrigando
                      ? FilledButton.icon(
                          onPressed: _alternarIrrigacao,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Parar irrigação'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _alternarIrrigacao,
                          icon: const Icon(Icons.water_drop),
                          label: const Text('Irrigar agora'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                ),

                /*
                SizedBox(
                  width: double.infinity,                  
                  child: _service.aguardandoResposta
                      ? FilledButton.icon(
                          onPressed: null, // desabilitado durante a espera
                          icon: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          label: const Text('Aguardando...'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      : _service.irrigando
                      ? FilledButton.icon(
                          onPressed: _alternarIrrigacao,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Parar irrigação'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _alternarIrrigacao,
                          icon: const Icon(Icons.water_drop),
                          label: const Text('Irrigar agora'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                ),
                */
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Puxe para atualizar',
                    style: TextStyle(fontSize: 11, color: cor.onSurfaceVariant),
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
