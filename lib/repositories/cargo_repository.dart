import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cargo_model.dart';

class CargoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> insert(Cargo cargo) async {
    final response =
        await _client.from('cargos').insert(cargo.toMap()).select().single();
    return response['id_cargos'] as int?;
  }

  Future<List<Cargo>> fetchAll() async {
    final response = await _client.from('cargos').select().order('cargo');
    return (response as List).map((json) => Cargo.fromMap(json)).toList();
  }

  Future<int?> update(Cargo cargo) async {
    if (cargo.id_cargos == null) {
      throw Exception('ID do cargo é nulo');
    }
    await _client
        .from('cargos')
        .update(cargo.toMap())
        .eq('id_cargos', cargo.id_cargos!);
    return cargo.id_cargos;
  }

  Future<int> delete(int id) async {
    await _client.from('cargos').delete().eq('id_cargos', id);
    return id;
  }
}
