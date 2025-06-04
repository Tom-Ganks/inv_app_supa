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

  Future<void> updateSaldo(int idProduto, int quantidade, String tipo) async {
    final produto = await _client
        .from('produtos')
        .select()
        .eq('id_produtos', idProduto)
        .single();

    int novoSaldo = produto['saldo'] as int;
    if (tipo == 'saida') {
      novoSaldo -= quantidade;
    } else if (tipo == 'entrada') {
      novoSaldo += quantidade;
    }

    await _client
        .from('produtos')
        .update({'saldo': novoSaldo}).eq('id_produtos', idProduto);
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
