import '../entidades/agendamento.dart';

abstract class AgendamentoRepositorio {
  Future<List<Agendamento>> buscarTodos();
  Future<void> salvarTodos(List<Agendamento> agendamentos);
  Future<void> adicionar(Agendamento agendamento);
  Future<void> remover(String id);
  Future<void> atualizar(Agendamento agendamento);
}