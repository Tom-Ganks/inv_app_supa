import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produto_model.dart';

class ProdutoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Produto produto) async {
    final Map<String, dynamic> dados = produto.toMap();
    dados.remove('id_produtos');

    final response =
        await _client.from('produtos').insert(dados).select().single();

    return response['id_produtos'] as int?;
  }

  Future<List<Produto>> fetchAll() async {
    final response = await _client.from('produtos').select().order('nome');
    return (response as List).map((json) => Produto.fromMap(json)).toList();
  }

  Future<List<Produto>> fetchLowStock() async {
    final response =
        await _client.from('produtos').select().lte('saldo', 5).order('nome');
    return (response as List).map((json) => Produto.fromMap(json)).toList();
  }

  Future<Produto?> fetchByName(String nome) async {
    final response =
        await _client.from('produtos').select().eq('nome', nome).maybeSingle();

    if (response == null) {
      return null;
    }

    return Produto.fromMap(response);
  }

  Future<int?> update(Produto produto) async {
    await _client
        .from('produtos')
        .update(produto.toMap())
        .eq('id_produtos', produto.id_produtos as Object);
    return produto.id_produtos;
  }

  Future<int> delete(int id) async {
    await _client.from('produtos').delete().eq('id_produtos', id);
    return id;
  }

  Future<void> updateSaldo(int produtoId, int quantidade, String tipo,
      {int? userId, bool skipMovementRecord = false}) async {
    try {
      // Get current product
      final produto = await _client
          .from('produtos')
          .select()
          .eq('id_produtos', produtoId)
          .single();

      if (produto == null) {
        throw Exception('Produto não encontrado');
      }

      int novoSaldo;
      int entrada = produto['entrada'];
      int saida = produto['saida'];

      if (tipo == 'entrada') {
        novoSaldo = produto['saldo'] + quantidade;
        entrada += quantidade;
      } else if (tipo == 'saida') {
        novoSaldo = produto['saldo'] - quantidade;
        saida += quantidade;
      } else {
        throw Exception('Tipo de movimentação inválido');
      }

      // Update product
      await _client.from('produtos').update({
        'saldo': novoSaldo,
        'entrada': entrada,
        'saida': saida,
      }).eq('id_produtos', produtoId);

      // Only create movement record if not skipped
      if (!skipMovementRecord) {
        final currentUserId = userId ?? _client.auth.currentUser?.id;
        if (currentUserId == null) {
          throw Exception('Usuário não autenticado');
        }

        await _client.from('movimentacao').insert({
          'id_produtos': produtoId,
          'id_usuarios': currentUserId,
          'quantidade': quantidade,
          'tipo': tipo,
          'data_saida': DateTime.now().toIso8601String(),
          'observacao': 'Atualizado via solicitação',
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar saldo: $e');
    }
  }
}
