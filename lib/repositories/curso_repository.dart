import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curso_model.dart';

class CursoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Curso curso) async {
    final response =
        await _client.from('cursos').insert(curso.toMap()).select().single();
    return response['id_cursos'] as int?;
  }

  Future<List<Curso>> fetchAll() async {
    final response = await _client.from('cursos').select().order('nome');
    return (response as List).map((json) => Curso.fromMap(json)).toList();
  }

  Future<int?> update(Curso curso) async {
    await _client
        .from('cursos')
        .update(curso.toMap())
        .eq('id_cursos', curso.id_cursos as Object);
    return curso.id_cursos;
  }

  Future<int> delete(int id) async {
    await _client.from('cursos').delete().eq('id_cursos', id);
    return id;
  }
}
