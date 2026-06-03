import '../entidades/configuracao_irrigacao.dart';
import '../entidades/agendamento.dart';
import '../value_objects/nivel_umidade.dart';
import '../value_objects/modo_irrigacao.dart';
import 'servico_agendamento.dart';

enum DecisaoIrrigacao {
  irrigar,
  naoIrrigar,
  verificarUmidadeNoEsp,
}

class ServicoDecisaoIrrigacao {
  final ServicoAgendamento _servicoAgendamento;

  ServicoDecisaoIrrigacao({
    ServicoAgendamento? servicoAgendamento,
  }) : _servicoAgendamento =
            servicoAgendamento ?? ServicoAgendamento();

  // Decide o que fazer dado o contexto atual
  DecisaoIrrigacao decidir({
    required ConfiguracaoIrrigacao configuracao,
    required List<Agendamento> agendamentos,
    required NivelUmidade umidadeAtual,
    required bool irrigandoAtualmente,
  }) {
    if (irrigandoAtualmente) return DecisaoIrrigacao.naoIrrigar;

    switch (configuracao.modo) {
      case ModoIrrigacao.horario:
        return _decidirPorHorario(agendamentos);

      case ModoIrrigacao.umidade:
        return _decidirPorUmidade(umidadeAtual, configuracao);

      case ModoIrrigacao.combinado:
        return _decidirCombinado(
            agendamentos, umidadeAtual, configuracao);
    }
  }

  DecisaoIrrigacao _decidirPorHorario(List<Agendamento> agendamentos) {
    final agendamento =
        _servicoAgendamento.encontrarParaAgoraExato(agendamentos);
    if (agendamento != null) return DecisaoIrrigacao.irrigar;
    return DecisaoIrrigacao.naoIrrigar;
  }

  DecisaoIrrigacao _decidirPorUmidade(
    NivelUmidade umidadeAtual,
    ConfiguracaoIrrigacao configuracao,
  ) {
    if (umidadeAtual.estaAbaixoDe(configuracao.umidadeMinima)) {
      return DecisaoIrrigacao.irrigar;
    }
    return DecisaoIrrigacao.naoIrrigar;
  }

  DecisaoIrrigacao _decidirCombinado(
    List<Agendamento> agendamentos,
    NivelUmidade umidadeAtual,
    ConfiguracaoIrrigacao configuracao,
  ) {
    final agendamento =
        _servicoAgendamento.encontrarParaAgoraExato(agendamentos);
    if (agendamento == null) return DecisaoIrrigacao.naoIrrigar;
    // No modo combinado o ESP verifica a umidade antes de irrigar
    return DecisaoIrrigacao.verificarUmidadeNoEsp;
  }
}