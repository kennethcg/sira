import 'package:flutter/material.dart';
import '../models/aprendiz.dart';
import '../models/departamento.dart';
import '../models/ciudad.dart';
import '../services/aprendiz_service.dart';
import '../services/departamento_service.dart';
import '../services/ciudad_service.dart';

class AprendizFormDialog extends StatefulWidget {
  final Aprendiz? aprendizEditando; // Si viene con datos, es para editar

  const AprendizFormDialog({super.key, this.aprendizEditando});

  @override
  State<AprendizFormDialog> createState() => _AprendizFormDialogState();
}

class _AprendizFormDialogState extends State<AprendizFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _identificacionController;
  late final TextEditingController _primerNombreController;
  late final TextEditingController _segundoNombreController;
  late final TextEditingController _primerApellidoController;
  late final TextEditingController _segundoApellidoController;

  String _genero = 'M';
  final DateTime _fechaNacimiento = DateTime(2000, 1, 1);

  List<Departamento> _departamentos = [];
  List<Ciudad> _ciudades = [];

  String? _selectedDepartamentoId;
  String? _selectedCiudadId;

  final _dptoService = DepartamentoService();
  final _ciudadService = CiudadService();
  final _aprendizService = AprendizService();

  @override
  void initState() {
    super.initState();
    final a = widget.aprendizEditando;
    _identificacionController =
        TextEditingController(text: a?.identificacion ?? '');
    _primerNombreController =
        TextEditingController(text: a?.primerNombre ?? '');
    _segundoNombreController =
        TextEditingController(text: a?.segundoNombre ?? '');
    _primerApellidoController =
        TextEditingController(text: a?.primerApellido ?? '');
    _segundoApellidoController =
        TextEditingController(text: a?.segundoApellido ?? '');

    if (a != null) {
      _genero = a.genero;
      _selectedDepartamentoId = a.departamentoId;
      _cargarCiudadesIniciales(a.departamentoId, a.ciudadId);
    }
    _cargarDepartamentos();
  }

  Future<void> _cargarDepartamentos() async {
    final dptos = await _dptoService.getDepartamentos();
    setState(() => _departamentos = dptos);
  }

  Future<void> _cargarCiudadesIniciales(String dptoId, String ciudadId) async {
    final ciudades = await _ciudadService.getCiudadesPorDepartamento(dptoId);
    setState(() {
      _ciudades = ciudades;
      _selectedCiudadId = ciudadId;
    });
  }

  Future<void> _onDepartamentoChanged(String? dptoId) async {
    if (dptoId == null) return;
    setState(() {
      _selectedDepartamentoId = dptoId;
      _selectedCiudadId = null;
      _ciudades = [];
    });
    final ciudades = await _ciudadService.getCiudadesPorDepartamento(dptoId);
    setState(() => _ciudades = ciudades);
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartamentoId == null || _selectedCiudadId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione departamento y ciudad')),
        );
        return;
      }

      final nuevo = Aprendiz(
        id: widget.aprendizEditando?.id,
        identificacion: _identificacionController.text,
        primerNombre: _primerNombreController.text,
        segundoNombre: _segundoNombreController.text.isEmpty
            ? null
            : _segundoNombreController.text,
        primerApellido: _primerApellidoController.text,
        segundoApellido: _segundoApellidoController.text.isEmpty
            ? null
            : _segundoApellidoController.text,
        genero: _genero,
        fechaNacimiento: _fechaNacimiento,
        departamentoId: _selectedDepartamentoId!,
        ciudadId: _selectedCiudadId!,
      );

      if (widget.aprendizEditando == null) {
        await _aprendizService.crearAprendiz(nuevo);
      } else {
        await _aprendizService.actualizarAprendiz(
            widget.aprendizEditando!.id!, nuevo);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkCard = Color(0xFF151922);
    const primaryNeon = Color(0xFF00FF87);

    return AlertDialog(
      backgroundColor: darkCard,
      title: Text(
        widget.aprendizEditando == null
            ? 'Registrar Aprendiz'
            : 'Editar Aprendiz',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _identificacionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Identificación',
                      labelStyle: TextStyle(color: Colors.white70)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primerNombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'Primer Nombre',
                            labelStyle: TextStyle(color: Colors.white70)),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _segundoNombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'Segundo Nombre',
                            labelStyle: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primerApellidoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'Primer Apellido',
                            labelStyle: TextStyle(color: Colors.white70)),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _segundoApellidoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'Segundo Apellido',
                            labelStyle: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _genero,
                  dropdownColor: darkCard,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Género',
                      labelStyle: TextStyle(color: Colors.white70)),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Masculino')),
                    DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  ],
                  onChanged: (v) => setState(() => _genero = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDepartamentoId,
                  dropdownColor: darkCard,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Departamento',
                      labelStyle: TextStyle(color: Colors.white70)),
                  items: _departamentos
                      .map((d) =>
                          DropdownMenuItem(value: d.id, child: Text(d.nombre)))
                      .toList(),
                  onChanged: _onDepartamentoChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCiudadId,
                  dropdownColor: darkCard,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      labelStyle: TextStyle(color: Colors.white70)),
                  items: _ciudades
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCiudadId = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryNeon, foregroundColor: Colors.black),
          onPressed: _guardar,
          child:
              Text(widget.aprendizEditando == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }
}
