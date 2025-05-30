import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movimentacao_model.dart';

class MovimentacaoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Movimentacao movimentacao) async {
    final response = await _client
        .from('movimentacoes')
        .insert(movimentacao.toMap())
        .select()
        .single();
    return response['id_movimentacao'] as int?;
  }

  Future<List<Movimentacao>> fetchAll() async {
    final response = await _client
        .from('movimentacoes')
        .select()
        .order('data_saida', ascending: false);
    return (response as List)
        .map((json) => Movimentacao.fromMap(json))
        .toList();
  }

  Future<List<Movimentacao>> fetchByTurma(int turmaId) async {
    final response = await _client
        .from('movimentacoes')
        .select()
        .eq('id_turma', turmaId)
        .order('data_saida', ascending: false);
    return (response as List)
        .map((json) => Movimentacao.fromMap(json))
        .toList();
  }

  Future<List<Movimentacao>> fetchByUsuario(int usuarioId) async {
    final response = await _client
        .from('movimentacoes')
        .select()
        .eq('id_usuarios', usuarioId)
        .order('data_saida', ascending: false);
    return (response as List)
        .map((json) => Movimentacao.fromMap(json))
        .toList();
  }

  Future<int?> update(Movimentacao movimentacao) async {
    await _client
        .from('movimentacoes')
        .update(movimentacao.toMap())
        .eq('id_movimentacao', movimentacao.id_movimentacao as Object);
    return movimentacao.id_movimentacao;
  }

  Future<int> delete(int id) async {
    await _client.from('movimentacoes').delete().eq('id_movimentacao', id);
    return id;
  }
}
