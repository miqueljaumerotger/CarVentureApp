import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  final DatabaseReference _vehiclesRef =
      FirebaseDatabase.instance.ref().child('vehiculos');

  Future<void> agregarVehiculo(
      String marca, String modelo, double precio, String tipo, bool disponibilidad, String imagenUrl) async {
    String newVehicleId = _vehiclesRef.push().key!;

    await _vehiclesRef.child(newVehicleId).set({
      'marca': marca,
      'modelo': modelo,
      'precio': precio,
      'tipo': tipo,  // 🔥 Tipo de vehículo (Coche, Moto, etc.)
      'disponibilidad': disponibilidad, // 🔥 Indica si está disponible
      'imagenes': [imagenUrl], // 🔥 Guardar URL de imagen en array
      'propietario': FirebaseAuth.instance.currentUser?.uid,
    });

    print("Vehículo agregado exitosamente: $marca $modelo");
  }
}
