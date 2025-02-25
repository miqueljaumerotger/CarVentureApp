class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String metodoPago;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.metodoPago = "PayPal",
  });

  factory UserModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return UserModel(
      id: id,
      nombre: data['nombre'] ?? 'Usuario',
      email: data['email'] ?? 'Sin Email',
      telefono: data['telefono'] ?? 'Sin Teléfono',
      metodoPago: data['metodo_pago'] ?? 'PayPal',
    );
  }
}
