import '../config/supabase_config.dart';
import '../models/ciudad.dart';

class CiudadService {
  Future<List<Ciudad>> getCiudadesPorDepartamento(String departamentoId) async {
    final response = await SupabaseConfig.client
        .from('ciudades')
        .select()
        .eq('departamento_id', departamentoId)
        .order('nombre');

    return (response as List)
        .map((e) => Ciudad.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
