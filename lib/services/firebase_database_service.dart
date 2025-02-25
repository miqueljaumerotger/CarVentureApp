import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

/**
 * Clase FirebaseDatabaseService
 *
 * Esta clase maneja la interacción con Firebase Realtime Database para gestionar vehículos y reservas.
 * Permite agregar vehículos, realizar reservas y consultar vehículos reservados.
 *
 * Funcionalidades principales:
 * - `agregarVehiculo()`: Agrega un nuevo vehículo a la base de datos con su información y disponibilidad.
 * - `reservarVehiculo()`: Crea una reserva para un vehículo, registrando las fechas y marcándolo como no disponible.
 * - `getReservedVehicleIds()`: Obtiene una lista de los vehículos que están reservados en la fecha actual.
 *
 * Uso:
 * - Esta clase se usa dentro de la aplicación para interactuar con la base de datos en la gestión de vehículos y reservas.
 * - Requiere autenticación con Firebase para asociar vehículos y reservas con los usuarios correspondientes.
 */


class FirebaseDatabaseService {
  final DatabaseReference _vehiclesRef =
      FirebaseDatabase.instance.ref().child('vehiculos');
  final DatabaseReference _reservationsRef =
      FirebaseDatabase.instance.ref().child('reservas');

  // 🔥 Función para agregar un vehículo (SIN CAMBIOS)
  Future<void> agregarVehiculo(String marca, String modelo, double precio,
      String tipo, bool disponibilidad, String imagenUrl) async {
    String newVehicleId = _vehiclesRef.push().key!;

    await _vehiclesRef.child(newVehicleId).set({
      'marca': marca,
      'modelo': modelo,
      'precio': precio,
      'tipo': tipo, // 🔥 Tipo de vehículo (Coche, Moto, etc.)
      'disponibilidad': disponibilidad, // 🔥 Indica si está disponible
      'imagenes': [imagenUrl], // 🔥 Guardar URL de imagen en array
      'propietario': FirebaseAuth.instance.currentUser?.uid,
    });

    print("Vehículo agregado exitosamente: $marca $modelo");
  }

  // 🔥 Función para reservar un vehículo
  Future<void> reservarVehiculo(String vehiculoId, DateTime fechaInicio,
      DateTime fechaFin, double precioTotal) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";
    DatabaseReference reservaRef = _reservationsRef.push();

    await reservaRef.set({
      'vehiculo': vehiculoId,
      'usuario': userId,
      'fecha_inicio': DateFormat("yyyy-MM-dd").format(fechaInicio),
      'fecha_fin': DateFormat("yyyy-MM-dd").format(fechaFin),
      'precio_total': precioTotal,
      'estado': 'pendiente',
    });

    // 🔥 Marcar vehículo como NO disponible
    await _vehiclesRef.child(vehiculoId).update({'disponibilidad': false});

    print("✅ Reserva creada para el vehículo $vehiculoId");
  }

  // 🔍 Función para obtener los IDs de vehículos reservados dentro del rango de fechas
  Future<List<String>> getReservedVehicleIds() async {
    DateTime today = DateTime.now();
    DatabaseEvent event = await _reservationsRef.once();
    List<String> reservedVehicleIds = [];

    if (event.snapshot.value != null &&
        event.snapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      reservedVehicleIds = data.entries
          .where((entry) {
            var reserva = entry.value as Map<dynamic, dynamic>;

            if (reserva.containsKey('fecha_inicio') &&
                reserva.containsKey('fecha_fin') &&
                reserva.containsKey('vehiculo')) {
              DateTime startDate =
                  DateFormat("yyyy-MM-dd").parse(reserva['fecha_inicio']);
              DateTime endDate =
                  DateFormat("yyyy-MM-dd").parse(reserva['fecha_fin']);

              return today.isAfter(startDate) && today.isBefore(endDate);
            }
            return false;
          })
          .map((entry) => entry.value['vehiculo'].toString())
          .toList();
    }

    print("🚗 Vehículos Reservados: $reservedVehicleIds"); // ✅ Debug en consola
    return reservedVehicleIds;
  }
}
