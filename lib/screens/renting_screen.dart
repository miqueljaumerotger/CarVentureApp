import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class RentingScreen extends StatefulWidget {
  @override
  _RentingScreenState createState() => _RentingScreenState();
}

class _RentingScreenState extends State<RentingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _rentingRef =
      FirebaseDatabase.instance.ref().child('reservas');
  List<Map<String, dynamic>> rentings = [];
  final DateFormat dateFormat =
      DateFormat("dd/MM/yyyy"); // 📌 Formato más amigable

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

        // 📌 Ordenar las reservas por fecha de inicio
        rentings.sort((a, b) {
          DateTime dateA = DateTime.parse(a['fecha_inicio']);
          DateTime dateB = DateTime.parse(b['fecha_inicio']);
          return dateA.compareTo(dateB);
        });
      });
    }
  }

  // 📌 Cancelar reserva si aún no ha comenzado
  Future<void> _cancelRenting(
      String rentingId, String vehicleId, String startDate) async {
    DateTime today = DateTime.now();
    DateTime start = DateTime.parse(startDate);

    if (today.isBefore(start)) {
      // 1️⃣ Eliminar la reserva de Firebase
      await _rentingRef.child(rentingId).remove();

      // 2️⃣ Volver a marcar el vehículo como disponible
      DatabaseReference vehicleRef =
          FirebaseDatabase.instance.ref().child('vehiculos').child(vehicleId);
      await vehicleRef.update({'disponibilidad': true});

      // 3️⃣ Refrescar la lista
      _loadRentings();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Reserva cancelada con éxito")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No puedes cancelar una reserva activa.")));
    }
  }

  // 📌 Agregar valoración y comentario
  Future<void> _addReview(String rentingId) async {
    double rating = 3; // Por defecto
    TextEditingController commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Valorar Reserva"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selecciona tu calificación"),
              DropdownButton<double>(
                value: rating,
                onChanged: (value) {
                  setState(() {
                    rating = value!;
                  });
                },
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem(
                        value: e.toDouble(), child: Text("$e ⭐")))
                    .toList(),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: "Deja tu comentario"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
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
                    SnackBar(content: Text("Valoración guardada con éxito")));
                _loadRentings(); // 🔄 Recargar la lista de rentings
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
      appBar: AppBar(title: Text("Mis Reservas")),
      body: rentings.isEmpty
          ? Center(child: Text("No tienes rentas aún."))
          : ListView.builder(
              itemCount: rentings.length,
              itemBuilder: (context, index) {
                var renting = rentings[index];
                DateTime startDate = DateTime.parse(renting['fecha_inicio']);
                DateTime endDate = DateTime.parse(renting['fecha_fin']);

                return Card(
                  child: ListTile(
                    title: Text("Vehículo: ${renting['vehiculo']}"),
                    subtitle: Text(
                      "Fecha: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}\n"
                      "Estado: ${renting['estado']} | Total: ${renting['precio_total']}€",
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "cancel") {
                          _cancelRenting(renting['id'], renting['vehiculo'],
                              renting['fecha_inicio']);
                        } else if (value == "review") {
                          _addReview(renting['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "review", child: Text("Valorar servicio")),
                        if (DateTime.now().isBefore(startDate))
                          PopupMenuItem(
                              value: "cancel", child: Text("Cancelar reserva")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
