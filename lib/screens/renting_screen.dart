import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

/**
 * Clase RentingScreen
 *
 * Esta pantalla muestra la lista de reservas activas y pasadas del usuario, permitiéndole 
 * gestionar sus rentas de vehículos. Incluye opciones para cancelar reservas antes de su inicio 
 * y dejar una valoración después de finalizarlas.
 *
 * Funcionalidades principales:
 * - Muestra todas las reservas del usuario obtenidas de Firebase Realtime Database.
 * - Permite cancelar una reserva si aún no ha comenzado, actualizando la disponibilidad del vehículo.
 * - Permite calificar y dejar un comentario en reservas finalizadas.
 * - Ordena las reservas por fecha de inicio.
 *
 * Métodos destacados:
 * - `_loadRentings()`: Carga todas las reservas del usuario desde Firebase y las ordena por fecha.
 * - `_cancelRenting(rentingId, vehicleId, startDate)`: Permite cancelar una reserva antes de su inicio y 
 *   actualiza la disponibilidad del vehículo en Firebase.
 * - `_addReview(rentingId)`: Muestra un cuadro de diálogo donde el usuario puede calificar y dejar un comentario 
 *   sobre su experiencia.
 * - `_buildNeonBackground()`: Aplica un fondo degradado con efecto futurista.
 *
 * Diseño:
 * - Fondo oscuro con gradiente en tonos azul y morado para mantener la estética de la aplicación.
 * - Tarjetas de reserva con información detallada sobre cada renta, destacando fechas y estado.
 * - Botón flotante y menús de acción con diseño estilizado para una mejor experiencia de usuario.
 */


class RentingScreen extends StatefulWidget {
  @override
  _RentingScreenState createState() => _RentingScreenState();
}

class _RentingScreenState extends State<RentingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _rentingRef =
      FirebaseDatabase.instance.ref().child('reservas');
  List<Map<String, dynamic>> rentings = [];
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    _loadRentings();
  }

  Future<void> _loadRentings() async {
    String userId = _auth.currentUser?.uid ?? "unknown_user";
    DatabaseEvent event =
        await _rentingRef.orderByChild('usuario').equalTo(userId).once();

    if (event.snapshot.value != null &&
        event.snapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        rentings = data.entries.map((entry) {
          Map<String, dynamic> rentingData =
              Map<String, dynamic>.from(entry.value as Map);
          return {'id': entry.key.toString(), ...rentingData};
        }).toList();

        rentings.sort((a, b) {
          DateTime dateA = DateTime.parse(a['fecha_inicio']);
          DateTime dateB = DateTime.parse(b['fecha_inicio']);
          return dateA.compareTo(dateB);
        });
      });
    }
  }

  Future<void> _cancelRenting(
      String rentingId, String vehicleId, String startDate) async {
    DateTime today = DateTime.now();
    DateTime start = DateTime.parse(startDate);

    if (today.isBefore(start)) {
      await _rentingRef.child(rentingId).remove();

      DatabaseReference vehicleRef =
          FirebaseDatabase.instance.ref().child('vehiculos').child(vehicleId);
      await vehicleRef.update({'disponibilidad': true});

      _loadRentings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚫 Reserva cancelada con éxito"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ No puedes cancelar una reserva activa."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _addReview(String rentingId) async {
    double rating = 3;
    TextEditingController commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("⭐ Valorar Reserva", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selecciona tu calificación", style: TextStyle(color: Colors.white70)),
              DropdownButton<double>(
                dropdownColor: Colors.black,
                value: rating,
                onChanged: (value) {
                  setState(() {
                    rating = value!;
                  });
                },
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem(
                        value: e.toDouble(),
                        child: Text("$e ⭐", style: TextStyle(color: Colors.white))))
                    .toList(),
              ),
              TextField(
                controller: commentController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "💬 Deja tu comentario",
                  labelStyle: TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
              child: Text("Enviar"),
              onPressed: () async {
                DatabaseReference rentingRef = FirebaseDatabase.instance
                    .ref()
                    .child('reservas')
                    .child(rentingId);

                await rentingRef.update({
                  'valoracion': rating,
                  'comentario': commentController.text,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Valoración guardada con éxito"), backgroundColor: Colors.greenAccent),
                );
                _loadRentings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Mis Rentings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.purpleAccent.withOpacity(0.5),
      ),
      body: Stack(
        children: [
          _buildNeonBackground(),
          rentings.isEmpty
              ? Center(child: Text("No tienes rentas aún :(", style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: rentings.length,
                  itemBuilder: (context, index) {
                    var renting = rentings[index];
                    DateTime startDate = DateTime.parse(renting['fecha_inicio']);
                    DateTime endDate = DateTime.parse(renting['fecha_fin']);

                    return Card(
                      color: Colors.black,
                      shadowColor: Colors.purpleAccent,
                      elevation: 10,
                      child: ListTile(
                        title: Text("🚘 Vehículo: ${renting['vehiculo']}", style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "📅 Fecha: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}\n"
                          "📌 Estado: ${renting['estado']} | 💰 Total: ${renting['precio_total']}€",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: PopupMenuButton<String>(
                          color: Colors.black,
                          onSelected: (value) {
                            if (value == "cancel") {
                              _cancelRenting(renting['id'], renting['vehiculo'], renting['fecha_inicio']);
                            } else if (value == "review") {
                              _addReview(renting['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: "review", child: Text("⭐ Valorar servicio", style: TextStyle(color: Colors.white))),
                            if (DateTime.now().isBefore(startDate))
                              PopupMenuItem(value: "cancel", child: Text("🚫 Cancelar reserva", style: TextStyle(color: Colors.redAccent))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildNeonBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.blue.shade900.withOpacity(0.5),
              Colors.black,
            ],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
      ),
    );
  }
}
