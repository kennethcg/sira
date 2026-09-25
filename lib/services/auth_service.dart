import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  // Obtener usuario actual
  User? get currentUser => SupabaseConfig.client.auth.currentUser;

  // Iniciar sesión con email y contraseña
  Future<AuthResponse> signIn(String email, String password) async {
    return await SupabaseConfig.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Registrar nuevo usuario
  Future<AuthResponse> signUp(String email, String password) async {
    return await SupabaseConfig.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await SupabaseConfig.client.auth.signOut();
  }
}
