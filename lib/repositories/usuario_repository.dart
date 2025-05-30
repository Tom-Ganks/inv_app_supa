import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class UsuarioRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Usuario usuario) async {
    final response = await _client
        .from('usuarios')
        .insert(usuario.toMap())
        .select()
        .single();
    return response['id_usuarios'] as int?;
  }

  Future<List<Usuario>> fetchAll() async {
    final response = await _client.from('usuarios').select().order('nome');
    return response.map((json) => Usuario.fromMap(json)).toList();
  }

  Future<Usuario?> findByEmail(String email) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Usuario.fromMap(response);
  }

  Future<List<Usuario>> fetchByTurma(int turmaId) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('turma', turmaId)
        .order('nome');
    return response.map((json) => Usuario.fromMap(json)).toList();
  }

  Future<List<Usuario>> fetchByCargo(int cargoId) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('cargo', cargoId)
        .order('nome');
    return response.map((json) => Usuario.fromMap(json)).toList();
  }

  Future<int?> update(Usuario usuario) async {
    await _client
        .from('usuarios')
        .update(usuario.toMap())
        .eq('id_usuarios', usuario.id_usuarios as Object);
    return usuario.id_usuarios;
  }

  Future<int> delete(int id) async {
    await _client.from('usuarios').delete().eq('id_usuarios', id);
    return id;
  }

  Future<Usuario?> authenticate(String email, String senha) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('email', email)
        .eq('senha', senha)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Usuario.fromMap(response);
  }
}
