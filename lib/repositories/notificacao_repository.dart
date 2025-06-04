import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notificacoes_model.dart';

class NotificacoesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int> insert(Notificacao notificacao) async {
    final response = await _client
        .from('notificacoes')
        .insert(notificacao.toMap())
        .select('id_notificacao')
        .single();
    return response['id_notificacao'] as int;
  }

  Future<List<Notificacao>> fetchAll() async {
    final response = await _client
        .from('notificacoes')
        .select()
        .order('data_solicitacao', ascending: false);
    return response.map((json) => Notificacao.fromMap(json)).toList();
  }

  Future<List<Notificacao>> fetchByUser(String solicitanteNome) async {
    final response = await _client
        .from('notificacoes')
        .select()
        .eq('solicitante_nome', solicitanteNome)
        .order('data_solicitacao', ascending: false);
    return response.map((json) => Notificacao.fromMap(json)).toList();
  }

  Future<int> updateStatus(
    int id, {
    required String status,
    String? observacao,
    int? quantidadeAprovada,
  }) async {
    await _client.from('notificacoes').update({
      'status': status,
      'observacao': observacao,
      'quantidade_aprovada': quantidadeAprovada,
      'lida': true,
    }).eq('id_notificacao', id); // Alterado para o nome correto
    return id;
  }

  Future<void> deleteAll() async {
    await _client.from('notificacoes').delete().neq('id', 0);
  }

  Future<int> getUnreadCount() async {
    final response =
        await _client.from('notificacoes').select().eq('lida', false);
    return response.length;
  }

  Future<void> markAsRead(int id) async {
    await _client.from('notificacoes').update({'lida': true}).eq('id', id);
  }
}
