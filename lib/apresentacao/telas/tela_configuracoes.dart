import 'package:flutter/material.dart';
import '../../aplicacao/irrigacao_app_service.dart';
import '../../infraestrutura/api/irrigasmart_api_client.dart';
import '../../infraestrutura/persistencia/configuracao_repositorio_impl.dart';
import '../../main.dart';
import 'tela_wifi_setup.dart';
import '../widgets/configuracoes/card_calibracao.dart';
import '../widgets/configuracoes/card_api_banco.dart';

class TelaConfiguracoes extends StatefulWidget {
  final IrrigacaoAppService service;
  const TelaConfiguracoes({super.key, required this.service});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  final ConfiguracaoRepositorioImpl _repo = ConfiguracaoRepositorioImpl();

  String _cidade  = 'Cruzeiro';
  String _urlApi  = '';
  bool _carregando = true;

  IrrigacaoAppService get _service => widget.service;

  // API online vem direto do cliente — getter puro
  bool get _apiOnline => IrrigaSmartApiClient.estaOnline;

  @override
  void initState() {
    super.initState();
    _service.addListener(_rebuild);
    _carregarDados();
  }

  @override
  void dispose() {
    _service.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _carregarDados() async {
    final cidade = await _repo.buscarCidade();
    final url    = await _repo.carregarUrlApi();
    if (!mounted) return;
    setState(() {
      _cidade   = cidade;
      _urlApi   = url;
      _carregando = false;
    });
    // Busca status do ESP em background para calibração
    _service.atualizarStatusEsp();
  }

  void _editarCidade() {
    final controller = TextEditingController(text: _cidade);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cidade'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ex: Cruzeiro',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final valor = controller.text.trim();
              if (valor.isEmpty) return;
              // Captura nav antes do await
              final nav = Navigator.of(ctx);
              await _repo.salvarCidade(valor);
              nav.pop();
              if (!mounted) return;
              setState(() => _cidade = valor);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sairDaRede() async {
    // Captura referências antes dos awaits
    final messenger = ScaffoldMessenger.of(context);
    final corEsquema = Theme.of(context).colorScheme;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da rede WiFi?'),
        content: const Text(
          'O IrrigaSmart vai esquecer a rede atual e entrar em modo '
          'de configuração na próxima vez que for ligado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final sucesso = await _service.resetarWifi();
    if (!mounted) return;

    messenger.showSnackBar(SnackBar(
      content: Text(sucesso
          ? 'Rede esquecida. Ligue o IrrigaSmart para reconfigurar.'
          : 'Não foi possível conectar ao IrrigaSmart.'),
      backgroundColor: sucesso ? corEsquema.primary : corEsquema.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cor      = Theme.of(context).colorScheme;
    final app      = IrrigaSmartApp.of(context);
    final modoEscuro = app?.modoEscuroAtivo ?? false;

    if (_carregando) {
      return Scaffold(
        backgroundColor: cor.surface,
        body: Center(child: CircularProgressIndicator(color: cor.primary)),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cor.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configurações',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cor.primary)),
              const SizedBox(height: 24),

              // ── Aparência ─────────────────────────────────────────
              _Titulo('Aparência'),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    modoEscuro ? Icons.dark_mode : Icons.light_mode,
                    color: cor.primary,
                  ),
                  title: const Text('Modo escuro'),
                  subtitle: Text(modoEscuro
                      ? 'Tema escuro ativado'
                      : 'Tema claro ativado'),
                  value: modoEscuro,
                  activeThumbColor: cor.primary,
                  onChanged: (_) => app?.alternarTema(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Conexão ───────────────────────────────────────────
              _Titulo('Conexão'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: _service.conectado ? cor.primary : cor.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _service.conectado
                              ? 'IrrigaSmart online'
                              : 'IrrigaSmart offline',
                          style: TextStyle(
                              fontSize: 13,
                              color: _service.conectado
                                  ? cor.primary
                                  : cor.error),
                        ),
                      ),
                      Icon(
                        _service.conectado ? Icons.wifi : Icons.wifi_off,
                        color: _service.conectado ? cor.primary : cor.error,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _service.conectado
                    ? Card(
                        key: const ValueKey('conectado'),
                        child: ListTile(
                          leading: Icon(Icons.wifi_off, color: cor.error),
                          title: const Text('Sair da rede WiFi'),
                          subtitle: const Text(
                            'IrrigaSmart entra em modo configuração no próximo início',
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(Icons.chevron_right,
                              color: cor.onSurfaceVariant),
                          onTap: _sairDaRede,
                        ),
                      )
                    : Card(
                        key: const ValueKey('desconectado'),
                        child: ListTile(
                          leading: Icon(Icons.wifi_find, color: cor.primary),
                          title: const Text('Configurar WiFi'),
                          subtitle: const Text(
                            'Conectar o IrrigaSmart a uma rede WiFi',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(Icons.chevron_right,
                              color: cor.onSurfaceVariant),
                          onTap: () async {
                            final ok = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TelaWifiSetup()),
                            );
                            if (ok == true && mounted) _carregarDados();
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // ── API e banco de dados ──────────────────────────────
              _Titulo('API e banco de dados'),
              const SizedBox(height: 8),
              CardApiBanco(
                online: _apiOnline,
                urlAtual: _urlApi,
                aoSalvar: (url) async {
                  // Captura antes do await
                  final messenger = ScaffoldMessenger.of(context);
                  final corPrimary = Theme.of(context).colorScheme.primary;
                  await _repo.salvarUrlApi(url);
                  IrrigaSmartApiClient.limparCache();
                  if (!mounted) return;
                  setState(() => _urlApi = url);
                  messenger.showSnackBar(SnackBar(
                    content: const Text('URL da API salva!'),
                    backgroundColor: corPrimary,
                  ));
                },
              ),
              const SizedBox(height: 24),

              // ── Calibração do sensor ──────────────────────────────
              _Titulo('Calibração do sensor'),
              const SizedBox(height: 8),
              CardCalibracao(
                sensorSeco:  _service.sensorSeco,
                sensorUmido: _service.sensorUmido,
                sensorRaw:   _service.sensorRaw,
                aoAtualizar: () async {
                  await _service.atualizarStatusEsp();
                  if (mounted) setState(() {});
                },
                // Wrapper para adaptar os parâmetros nomeados do service
                // aos parâmetros posicionais esperados pelo card
                aoSalvar: (seco, umido) =>
                    _service.calibrarSensor(seco: seco, umido: umido),
              ),
              const SizedBox(height: 24),

              // ── Clima ─────────────────────────────────────────────
              _Titulo('Clima'),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_city, color: cor.primary),
                  title: const Text('Cidade'),
                  subtitle: Text(_cidade),
                  trailing: Icon(Icons.edit_outlined,
                      color: cor.onSurfaceVariant),
                  onTap: _editarCidade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(texto,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant));
  }
}