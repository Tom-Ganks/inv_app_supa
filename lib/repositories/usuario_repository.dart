import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class UsuarioRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int> insert(Usuario usuario) async {
    try {
      final response = await _client
          .from('usuarios')
          .insert(usuario.toMap())
          .select()
          .single();

      return response['id_usuarios'] as int;
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<List<Usuario>> fetchAll() async {
    try {
      final response = await _client.from('usuarios').select().order('nome');
      return response.map((json) => Usuario.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<Usuario?> findByEmail(String email) async {
    try {
      final response = await _client
          .from('usuarios')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Usuario.fromMap(response);
    } catch (e) {
      throw Exception('Failed to find user by email: $e');
    }
  }

  Future<List<Usuario>> fetchByTurma(int turmaId) async {
    try {
      final response = await _client
          .from('usuarios')
          .select()
          .eq('turma', turmaId)
          .order('nome');
      return response.map((json) => Usuario.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by turma: $e');
    }
  }

  Future<List<Usuario>> fetchByCargo(int cargoId) async {
    try {
      final response = await _client
          .from('usuarios')
          .select()
          .eq('cargo', cargoId)
          .order('nome');
      return response.map((json) => Usuario.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by cargo: $e');
    }
  }

  Future<void> update(Usuario usuario) async {
    try {
      if (usuario.id_usuarios == null) {
        throw Exception('Cannot update user without id_usuarios');
      }

      await _client
          .from('usuarios')
          .update(usuario.toMap())
          .eq('id_usuarios', usuario.id_usuarios as Object);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.from('usuarios').delete().eq('id_usuarios', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<Usuario?> authenticate(String email, String senha) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to authenticate user: $e');
    }
  }
}
