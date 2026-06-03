import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../infraestrutura/persistencia/configuracao_repositorio_impl.dart';

class TelaWifiSetup extends StatefulWidget {
  const TelaWifiSetup({super.key});

  @override
  State<TelaWifiSetup> createState() => _TelaWifiSetupState();
}

class _TelaWifiSetupState extends State<TelaWifiSetup> {
  static const String serviceUuid = '12345678-1234-1234-1234-123456789abc';
  static const String characteristicUuid =
      'abcdef01-1234-1234-1234-123456789abc';

  final _ssidController = TextEditingController();
  final _senhaController = TextEditingController();
  // Único repositório necessário — substitui StorageService antigo
  final _repo = ConfiguracaoRepositorioImpl();

  bool _escaneando = false;
  bool _enviando = false;
  bool _senhaVisivel = false;
  bool _dispositivoEncontrado = false;
  String _status = '';

  BluetoothDevice? _dispositivo;
  BluetoothCharacteristic? _caracteristica;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _pedirPermissoesEIniciar();
  }

  Future<void> _pedirPermissoesEIniciar() async {
    setState(() => _status = 'Verificando permissões...');

    final permissoes = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final algumaNegada = permissoes.values.any(
      (s) => s.isDenied || s.isPermanentlyDenied,
    );

    if (algumaNegada) {
      if (!mounted) return;
      setState(
        () => _status =
            'Permissões de Bluetooth negadas.\n'
            'Vá em Configurações do celular e permita o Bluetooth '
            'e localização para este app.',
      );
      return;
    }

    _iniciarScan();
  }

  Future<void> _iniciarScan() async {
    setState(() {
      _escaneando = true;
      _dispositivoEncontrado = false;
      _caracteristica = null;
      _dispositivo = null;
      _status = 'Procurando IrrigaSmart...';
    });

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    try {
      final bluetoothAtivo =
          await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;

      if (!bluetoothAtivo) {
        if (!mounted) return;
        setState(() {
          _escaneando = false;
          _status = 'Bluetooth desativado. Ative e tente novamente.';
        });
        return;
      }

      // 1. Listener configurado ANTES do startScan
      _scanSubscription = FlutterBluePlus.onScanResults.listen((resultados) {
        debugPrint('BLE recebeu ${resultados.length} resultado(s)');
        for (final r in resultados) {
          final nome = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          debugPrint('BLE: "$nome" | ${r.device.remoteId}');
          if (nome == 'IrrigaSmart') {
            FlutterBluePlus.stopScan();
            if (!mounted) return;
            setState(() {
              _dispositivo = r.device;
              _status = 'IrrigaSmart encontrado! Conectando...';
            });
            _conectar(r.device);
            break;
          }
        }
      });

      debugPrint('BLE: iniciando scan...');

      // 2. await startScan com timeout — listener já está ativo
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      debugPrint('BLE: scan encerrado');

      // 3. Verifica resultado após os 15s
      if (!_dispositivoEncontrado && mounted) {
        setState(() {
          _escaneando = false;
          _status =
              'IrrigaSmart não encontrado.\n'
              'Verifique se está ligado e com o LED piscando.';
        });
      }
    } catch (e) {
      debugPrint('BLE erro: $e');
      if (!mounted) return;
      setState(() {
        _escaneando = false;
        _status = 'Erro no Bluetooth: $e';
      });
    }
  }

  Future<void> _conectar(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      if (!mounted) return;
      setState(() => _status = 'Conectado! Preparando configuração...');

      final servicos = await device.discoverServices();
      for (final servico in servicos) {
        if (servico.uuid.toString().toLowerCase() ==
            serviceUuid.toLowerCase()) {
          for (final char in servico.characteristics) {
            if (char.uuid.toString().toLowerCase() ==
                characteristicUuid.toLowerCase()) {
              await char.setNotifyValue(true);
              if (!mounted) return;
              setState(() {
                _caracteristica = char;
                _escaneando = false;
                _dispositivoEncontrado = true;
                _status = 'Pronto! Digite o nome e senha da rede WiFi.';
              });
              return;
            }
          }
        }
      }
      if (!mounted) return;
      setState(
        () => _status =
            'Erro ao encontrar serviço. '
            'Reinicie o IrrigaSmart e tente novamente.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _escaneando = false;
        _status = 'Falha ao conectar. Tente novamente.';
      });
    }
  }

  Future<void> _enviarCredenciais() async {
    if (_caracteristica == null) return;
    if (_ssidController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da rede WiFi')),
      );
      return;
    }

    setState(() {
      _enviando = true;
      _status = 'Enviando para o IrrigaSmart...';
    });

    final dados = jsonEncode({
      'ssid': _ssidController.text.trim(),
      'senha': _senhaController.text,
    });

    try {
      await _caracteristica!.write(utf8.encode(dados), withoutResponse: false);
    } catch (_) {
      // Ignora — ESP pode reiniciar antes de confirmar
    }

    if (!mounted) return;
    setState(
      () => _status =
          'Configuração enviada!\nAguardando o IrrigaSmart reiniciar...',
    );

    // Usa repositório DDD em vez do StorageService antigo
    await _repo.salvarWifiConfigurado(true);

    await Future.delayed(const Duration(seconds: 5));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _dispositivo?.disconnect();
    _ssidController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cor.surface,
      appBar: AppBar(
        title: const Text('Configurar conexão'),
        backgroundColor: cor.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: cor.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_escaneando || _enviando)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cor.primary,
                          ),
                        )
                      else
                        Icon(
                          _dispositivoEncontrado
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_searching,
                          color: cor.primary,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _status,
                          style: TextStyle(
                            fontSize: 13,
                            color: cor.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!_escaneando && !_dispositivoEncontrado) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pedirPermissoesEIniciar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ),
              ],

              if (_dispositivoEncontrado && _caracteristica != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Nome da rede WiFi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    hintText: 'Nome da rede',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  decoration: InputDecoration(
                    hintText: 'Deixe vazio se não tiver senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _enviando ? null : _enviarCredenciais,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.wifi_password),
                    label: Text(_enviando ? 'Configurando...' : 'Conectar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
