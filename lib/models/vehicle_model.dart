class VehicleModel {
  final String id;
  final String marca;
  final String modelo;
  final double precio;
  final String tipo;
  final bool disponibilidad;
  final List<String> imagenes;

  VehicleModel({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.precio,
    required this.tipo,
    required this.disponibilidad,
    required this.imagenes,
  });

  factory VehicleModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return VehicleModel(
      id: id,
      marca: data['marca'] ?? 'Desconocido',
      modelo: data['modelo'] ?? 'Desconocido',
      precio: (data['precio'] ?? 0).toDouble(),
      tipo: data['tipo'] ?? 'Coche',
      disponibilidad: data['disponibilidad'] ?? true,
      imagenes: List<String>.from(data['imagenes'] ?? []),
    );
  }
}
