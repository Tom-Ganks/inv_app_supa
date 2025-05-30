import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medida_model.dart';

class MedidaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Medida medida) async {
    final response =
        await _client.from('medidas').insert(medida.toMap()).select().single();
    return response['id_medida'] as int?;
  }

  Future<List<Medida>> fetchAll() async {
    final response = await _client.from('medidas').select().order('medida');
    return (response as List).map((json) => Medida.fromMap(json)).toList();
  }

  Future<int?> update(Medida medida) async {
    await _client
        .from('medidas')
        .update(medida.toMap())
        .eq('id_medida', medida.id_medida as Object);
    return medida.id_medida;
  }

  Future<int> delete(int id) async {
    await _client.from('medidas').delete().eq('id_medida', id);
    return id;
  }
}
