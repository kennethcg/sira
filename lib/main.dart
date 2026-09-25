import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/aprendices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const SiraApp());
}

class SiraApp extends StatelessWidget {
  const SiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SupabaseConfig.client.auth.currentSession;

    return MaterialApp(
      title: 'SIRA Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: session != null ? const AprendicesScreen() : const LoginScreen(),
    );
  }
}
