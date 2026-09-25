import '../config/supabase_config.dart';
import '../models/departamento.dart';

class DepartamentoService {
  Future<List<Departamento>> getDepartamentos() async {
    final response = await SupabaseConfig.client
        .from('departamentos')
        .select()
        .order('nombre');

    return (response as List)
        .map((e) => Departamento.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
