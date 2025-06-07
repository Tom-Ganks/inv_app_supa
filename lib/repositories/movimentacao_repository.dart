// src/repositories/movimentacao_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movimentacao_model.dart';

class MovimentacaoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Movimentacao movimentacao) async {
    try {
      final response = await _client
          .from('movimentacao')
          .insert(movimentacao.toMap())
          .select()
          .single();
      return response['id_movimentacao'] as int?;
    } catch (e) {
      print('Error inserting movimentacao: $e');
      rethrow;
    }
  }

  Future<List<Movimentacao>> fetchAll() async {
    try {
      final response = await _client
          .from(
              'movimentacao') // Changed from 'movimentacoes' to 'movimentacao'
          .select()
          .order('data_saida', ascending: false);
      return (response as List)
          .map((json) => Movimentacao.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all movimentacoes: $e');
      rethrow;
    }
  }

  Future<List<Movimentacao>> fetchByTurma(int turmaId) async {
    try {
      final response = await _client
          .from(
              'movimentacao') // Changed from 'movimentacoes' to 'movimentacao'
          .select()
          .eq('id_turma', turmaId)
          .order('data_saida', ascending: false);
      return (response as List)
          .map((json) => Movimentacao.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching movimentacoes by turma: $e');
      rethrow;
    }
  }

  Future<List<Movimentacao>> fetchByUsuario(int usuarioId) async {
    try {
      final response = await _client
          .from(
              'movimentacao') // Changed from 'movimentacoes' to 'movimentacao'
          .select()
          .eq('id_usuarios', usuarioId)
          .order('data_saida', ascending: false);
      return (response as List)
          .map((json) => Movimentacao.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching movimentacoes by usuario: $e');
      rethrow;
    }
  }

  Future<int?> update(Movimentacao movimentacao) async {
    try {
      await _client
          .from(
              'movimentacao') // Changed from 'movimentacoes' to 'movimentacao'
          .update(movimentacao.toMap())
          .eq('id_movimentacao', movimentacao.id_movimentacao as Object);
      return movimentacao.id_movimentacao;
    } catch (e) {
      print('Error updating movimentacao: $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    try {
      await _client
          .from(
              'movimentacao') // Changed from 'movimentacoes' to 'movimentacao'
          .delete()
          .eq('id_movimentacao', id);
      return id;
    } catch (e) {
      print('Error deleting movimentacao: $e');
      rethrow;
    }
  }
}
