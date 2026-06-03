import 'package:shared_preferences/shared_preferences.dart';
import '../../dominio/entidades/agendamento.dart';
import '../../dominio/repositorios/agendamento_repositorio.dart';

class AgendamentoRepositorioImpl implements AgendamentoRepositorio {
  static const _key = 'agendamentos';

  @override
  Future<List<Agendamento>> buscarTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    return Agendamento.listaDeJson(json);
  }

  @override
  Future<void> salvarTodos(List<Agendamento> agendamentos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Agendamento.listaParaJson(agendamentos));
  }

  @override
  Future<void> adicionar(Agendamento agendamento) async {
    final todos = await buscarTodos();
    todos.add(agendamento);
    await salvarTodos(todos);
  }

  @override
  Future<void> remover(String id) async {
    final todos = await buscarTodos();
    todos.removeWhere((a) => a.id == id);
    await salvarTodos(todos);
  }

  @override
  Future<void> atualizar(Agendamento agendamento) async {
    final todos = await buscarTodos();
    final index = todos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) todos[index] = agendamento;
    await salvarTodos(todos);
  }
}