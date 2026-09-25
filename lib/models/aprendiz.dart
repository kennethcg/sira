class Aprendiz {
  final int? id;
  final String identificacion;
  final String primerNombre;
  final String? segundoNombre;
  final String primerApellido;
  final String? segundoApellido;
  final String genero;
  final DateTime fechaNacimiento;
  final String departamentoId;
  final String ciudadId;

  Aprendiz({
    this.id,
    required this.identificacion,
    required this.primerNombre,
    this.segundoNombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.genero,
    required this.fechaNacimiento,
    required this.departamentoId,
    required this.ciudadId,
  });

  factory Aprendiz.fromJson(Map<String, dynamic> json) {
    return Aprendiz(
      id: json['id'] as int?,
      identificacion: json['identificacion'] as String,
      primerNombre: json['primer_nombre'] as String,
      segundoNombre: json['segundo_nombre'] as String?,
      primerApellido: json['primer_apellido'] as String,
      segundoApellido: json['segundo_apellido'] as String?,
      genero: json['genero'] as String,
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      departamentoId: json['departamento_id'] as String,
      ciudadId: json['ciudad_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'identificacion': identificacion,
        'primer_nombre': primerNombre,
        'segundo_nombre': segundoNombre,
        'primer_apellido': primerApellido,
        'segundo_apellido': segundoApellido,
        'genero': genero,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
        'departamento_id': departamentoId,
        'ciudad_id': ciudadId,
      };
}
