import 'package:flutter/material.dart';
import '../models/aprendiz.dart';
import '../services/aprendiz_service.dart';
import '../services/auth_service.dart';
import '../widgets/aprendiz_form_dialog.dart';
import 'login_screen.dart';

class AprendicesScreen extends StatefulWidget {
  const AprendicesScreen({super.key});

  @override
  State<AprendicesScreen> createState() => _AprendicesScreenState();
}

class _AprendicesScreenState extends State<AprendicesScreen> {
  final AprendizService _aprendizService = AprendizService();
  final AuthService _authService = AuthService();

  List<Aprendiz> _todosLosAprendices = [];
  List<Aprendiz> _aprendicesFiltrados = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';
  bool _esAdmin = false;
  int _menuSeleccionado = 0; // 0: Aprendices, 1: Reportes, 2: Info SIRA

  @override
  void initState() {
    super.initState();
    _verificarRolYCargar();
  }

  Future<void> _verificarRolYCargar() async {
    final email = _authService.currentUser?.email ?? '';
    _esAdmin = email.toLowerCase() == 'kennethcogo@gmail.com';
    await _cargarAprendices();
  }

  Future<void> _cargarAprendices() async {
    setState(() => _isLoading = true);
    try {
      final data = await _aprendizService.getAprendices();
      setState(() {
        _todosLosAprendices = data;
        _filtrar(_filtroBusqueda);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      }
    }
  }

  void _filtrar(String query) {
    setState(() {
      _filtroBusqueda = query;
      if (query.isEmpty) {
        _aprendicesFiltrados = _todosLosAprendices;
      } else {
        _aprendicesFiltrados = _todosLosAprendices.where((a) {
          final nombreCompleto =
              '${a.primerNombre} ${a.primerApellido}'.toLowerCase();
          return a.identificacion.contains(query) ||
              nombreCompleto.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _cerrarSesion() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _abrirFormulario({Aprendiz? aprendiz}) async {
    // ¡Ahora el operativo SÍ puede registrar (aprendiz == null) y editar! Solo se bloquea la eliminación.
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AprendizFormDialog(aprendizEditando: aprendiz),
    );

    if (result == true) {
      await _cargarAprendices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(aprendiz == null
                ? '¡Aprendiz registrado con éxito!'
                : '¡Aprendiz actualizado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryNeon = Color(0xFF00FF87);
    const darkBg = Color(0xFF0B0E14);
    const cardBg = Color(0xFF151922);
    const sidebarBg = Color(0xFF0E121A);

    return Scaffold(
      backgroundColor: darkBg,
      body: Row(
        children: [
          // Menú Lateral Exótico
          Container(
            width: 260,
            color: sidebarBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: primaryNeon.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.bolt,
                            color: primaryNeon, size: 24),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [primaryNeon, Color(0xFF60EFFF)],
                        ).createShader(bounds),
                        child: const Text(
                          'SIRA WEB',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                const SizedBox(height: 16),
                _buildMenuItem(
                    0, Icons.people_outline, 'Aprendices', primaryNeon),
                _buildMenuItem(
                    1, Icons.analytics_outlined, 'Reportes DANE', primaryNeon),
                _buildMenuItem(
                    2, Icons.info_outline, 'Acerca de SIRA', primaryNeon),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _esAdmin
                              ? primaryNeon.withValues(alpha: 0.2)
                              : Colors.blue.withValues(alpha: 0.2),
                          child: Icon(
                            _esAdmin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            size: 18,
                            color: _esAdmin ? primaryNeon : Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _esAdmin ? 'Administrador' : 'Operativo',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              Text(
                                'Conectado',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent.withValues(alpha: 0.1),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _cerrarSesion,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Cerrar Sesión',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido Principal
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _menuSeleccionado == 0
                            ? 'Módulo de Gestión de Aprendices'
                            : _menuSeleccionado == 1
                                ? 'Reportes y Estadísticas'
                                : 'Acerca de la Plataforma',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      if (_menuSeleccionado == 0)
                        SizedBox(
                          width: 280,
                          height: 40,
                          child: TextField(
                            onChanged: _filtrar,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Buscar por cédula o nombre...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3)),
                              prefixIcon: const Icon(Icons.search,
                                  color: primaryNeon, size: 18),
                              filled: true,
                              fillColor: darkBg,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _menuSeleccionado == 0
                      ? _buildTablaAprendices(cardBg, primaryNeon)
                      : _menuSeleccionado == 1
                          ? _buildVistaEnConstruccion()
                          : _buildAcercaDeSira(cardBg, primaryNeon),
                ),
              ],
            ),
          ),
        ],
      ),
      // ¡El botón flotante ahora está disponible tanto para el Admin como para el Operativo!
      floatingActionButton: _menuSeleccionado == 0
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              backgroundColor: primaryNeon,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('NUEVO APRENDIZ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildMenuItem(
      int index, IconData icon, String title, Color primaryNeon) {
    bool activo = _menuSeleccionado == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _menuSeleccionado = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: activo
                ? primaryNeon.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: activo
                    ? primaryNeon.withValues(alpha: 0.3)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: activo ? primaryNeon : Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: activo ? Colors.white : Colors.white60,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaAprendices(Color cardBg, Color primaryNeon) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryNeon))
            : _aprendicesFiltrados.isEmpty
                ? Center(
                    child: Text('No se encontraron aprendices.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4))),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            Colors.white.withValues(alpha: 0.03)),
                        columns: [
                          DataColumn(
                              label: Text('ID',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('IDENTIFICACIÓN',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('NOMBRES',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('APELLIDOS',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('GÉNERO',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('DPTO / CIUDAD',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('ACCIONES',
                                  style: TextStyle(
                                      color: primaryNeon,
                                      fontWeight: FontWeight.bold))),
                        ],
                        rows: _aprendicesFiltrados.map((a) {
                          return DataRow(
                            cells: [
                              DataCell(Text('#${a.id}',
                                  style:
                                      const TextStyle(color: Colors.white70))),
                              DataCell(Text(a.identificacion,
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(
                                  '${a.primerNombre} ${a.segundoNombre ?? ""}',
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(
                                  '${a.primerApellido} ${a.segundoApellido ?? ""}',
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: a.genero == 'M'
                                        ? Colors.blue.withValues(alpha: 0.2)
                                        : Colors.pink.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    a.genero == 'M' ? 'Masc' : 'Fem',
                                    style: TextStyle(
                                        color: a.genero == 'M'
                                            ? Colors.lightBlueAccent
                                            : Colors.pinkAccent),
                                  ),
                                ),
                              ),
                              DataCell(Text(
                                  '${a.departamentoId} - ${a.ciudadId}',
                                  style:
                                      const TextStyle(color: Colors.white70))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.amberAccent, size: 20),
                                      tooltip: 'Editar',
                                      onPressed: () =>
                                          _abrirFormulario(aprendiz: a),
                                    ),
                                    // ¡Solo el Administrador puede ver el botón de eliminar!
                                    if (_esAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent, size: 20),
                                        tooltip: 'Eliminar',
                                        onPressed: () async {
                                          if (a.id != null) {
                                            await _aprendizService
                                                .eliminarAprendiz(a.id!);
                                            await _cargarAprendices();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Aprendiz eliminado correctamente'),
                                                    backgroundColor:
                                                        Colors.red),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildAcercaDeSira(Color cardBg, Color primaryNeon) {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: primaryNeon, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Acerca de SIRA Web',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            const Text(
              'SIRA (Sistema de Información de Registro de Aprendices) es una plataforma web desarrollada en Flutter y conectada con Supabase para la gestión centralizada de aprendices.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Roles del Sistema:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                '• Administrador: Control total (Lectura, Registro, Edición y Eliminación).',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 4),
            const Text(
                '• Operativo: Gestión de datos (Lectura, Registro y Edición de aprendices).',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 24),
            Text(
              'Versión actual: 1.0.0 - Edición Exótica',
              style: TextStyle(
                  color: primaryNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaEnConstruccion() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.engineering_outlined,
              size: 64, color: Colors.amberAccent),
          const SizedBox(height: 16),
          const Text('Módulo en desarrollo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
              'Esta sección estará disponible en la próxima actualización del SIRA.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
