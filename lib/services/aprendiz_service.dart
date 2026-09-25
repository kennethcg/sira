import '../config/supabase_config.dart';
import '../models/aprendiz.dart';

class AprendizService {
  Future<List<Aprendiz>> getAprendices() async {
    final response = await SupabaseConfig.client
        .from('aprendices')
        .select()
        .order('id', ascending: false);

    return (response as List)
        .map((e) => Aprendiz.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearAprendiz(Aprendiz aprendiz) async {
    await SupabaseConfig.client.from('aprendices').insert(aprendiz.toJson());
  }

  Future<void> actualizarAprendiz(int id, Aprendiz aprendiz) async {
    await SupabaseConfig.client
        .from('aprendices')
        .update(aprendiz.toJson())
        .eq('id', id);
  }

  Future<void> eliminarAprendiz(int id) async {
    await SupabaseConfig.client.from('aprendices').delete().eq('id', id);
  }
}
