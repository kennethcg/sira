class Ciudad {
  final String id;
  final String departamentoId;
  final String nombre;

  Ciudad({
    required this.id,
    required this.departamentoId,
    required this.nombre,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      id: json['id'] as String,
      departamentoId: json['departamento_id'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'departamento_id': departamentoId,
        'nombre': nombre,
      };
}
