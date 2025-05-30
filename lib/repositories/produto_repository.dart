import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produto_model.dart';

class ProdutoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Produto produto) async {
    final response = await _client
        .from('produtos')
        .insert(produto.toMap())
        .select()
        .single();
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
}
