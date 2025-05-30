import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turma_model.dart';

class TurmaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Turma turma) async {
    final response =
        await _client.from('turmas').insert(turma.toMap()).select().single();
    return response['id_turma'] as int?;
  }

  Future<List<Turma>> fetchAll() async {
    final response = await _client.from('turmas').select().order('turma');
    return (response as List).map((json) => Turma.fromMap(json)).toList();
  }

  Future<List<Turma>> fetchByInstrutor(String instrutor) async {
    final response = await _client
        .from('turmas')
        .select()
        .eq('instrutor', instrutor)
        .order('turma');
    return (response as List).map((json) => Turma.fromMap(json)).toList();
  }

  Future<int?> update(Turma turma) async {
    await _client
        .from('turmas')
        .update(turma.toMap())
        .eq('id_turma', turma.id_turma as Object);
    return turma.id_turma;
  }

  Future<int> delete(int id) async {
    await _client.from('turmas').delete().eq('id_turma', id);
    return id;
  }
}
