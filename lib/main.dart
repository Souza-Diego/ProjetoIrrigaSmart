import 'dart:async';
import 'package:flutter/material.dart';
import 'aplicacao/irrigacao_app_service.dart';
import 'aplicacao/planta_app_service.dart';
import 'infraestrutura/persistencia/configuracao_repositorio_impl.dart';
import 'apresentacao/telas/tela_inicio.dart';
import 'apresentacao/telas/tela_controle.dart';
import 'apresentacao/telas/tela_plantas.dart';
import 'apresentacao/telas/tela_configuracoes.dart';
import 'apresentacao/telas/tela_sistema.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = ConfiguracaoRepositorioImpl();
  final modoEscuro = await repo.buscarModoEscuro();
  runApp(IrrigaSmartApp(modoEscuroInicial: modoEscuro));
}

class IrrigaSmartApp extends StatefulWidget {
  final bool modoEscuroInicial;
  const IrrigaSmartApp({super.key, required this.modoEscuroInicial});

  static IrrigaSmartAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<IrrigaSmartAppState>();

  @override
  State<IrrigaSmartApp> createState() => IrrigaSmartAppState();
}

class IrrigaSmartAppState extends State<IrrigaSmartApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.modoEscuroInicial ? ThemeMode.dark : ThemeMode.light;
  }

  void alternarTema() async {
    final novoModo = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setState(() => _themeMode = novoModo);
    await ConfiguracaoRepositorioImpl().salvarModoEscuro(
      novoModo == ThemeMode.dark,
    );
  }

  bool get modoEscuroAtivo => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IrrigaSmart',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _telaSelecionada = 0;
  late final IrrigacaoAppService _service;
  late final PlantaAppService _plantaService;
  late final List<Widget> _telas;
  final GlobalKey<TelaplantasState> _plantasKey = GlobalKey();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _service = IrrigacaoAppService();
    _plantaService = PlantaAppService(
      onParametrosAplicados: () => _service.recarregarConfiguracao(),
    );
    _telas = [
      TelaInicio(service: _service),
      TelaControle(service: _service),
      TelaPlantas(key: _plantasKey, plantaService: _plantaService),
      TelaConfiguracoes(service: _service),
      const TelaSistema(),
    ];
    _service.inicializar();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _service.atualizarStatusEsp();
      _service.verificarAgendamentos();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_telaSelecionada],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _telaSelecionada,
        onDestinationSelected: (index) {
          setState(() => _telaSelecionada = index);
          if (index == 2) {
            _plantasKey.currentState?.recarregar();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Controle',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Plantas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config.',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Sistema',
          ),
        ],
      ),
    );
  }
}
