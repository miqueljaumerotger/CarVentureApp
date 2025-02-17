import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;
  final Map<dynamic, dynamic> vehicleData;

  VehicleDetailsScreen({required this.vehicleId, required this.vehicleData});

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  double totalPrice = 0;

  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  // 🔥 Método para seleccionar fechas
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(Duration(days: 365)); // 1 año máximo

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = null; // Reset endDate si es menor que startDate
          }
        } else {
          endDate = pickedDate;
        }
        _calculateTotalPrice();
      });
    }
  }

  // 🔥 Método para calcular el precio total
  void _calculateTotalPrice() {
    if (startDate != null && endDate != null) {
      int days = endDate!.difference(startDate!).inDays + 1;
      double pricePerDay = widget.vehicleData['precio']?.toDouble() ?? 0;
      setState(() {
        totalPrice = days * pricePerDay;
      });
    }
  }

  // 🔥 Método para guardar la reserva en Firebase y actualizar la disponibilidad
  Future<void> _confirmReservation() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Selecciona las fechas de la reserva"),
      ));
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";
    DatabaseReference reservationsRef =
        FirebaseDatabase.instance.ref().child('reservas');
    DatabaseReference vehicleRef = FirebaseDatabase.instance
        .ref()
        .child('vehiculos')
        .child(widget.vehicleId);

    String reservationId = reservationsRef.push().key!;

    // 🔥 1️⃣ Guardar la reserva en Firebase
    await reservationsRef.child(reservationId).set({
      'usuario': userId,
      'vehiculo': widget.vehicleId,
      'fecha_inicio': dateFormat.format(startDate!),
      'fecha_fin': dateFormat.format(endDate!),
      'precio_total': totalPrice,
      'estado': 'pendiente',
    });

    // 🔥 2️⃣ Marcar el vehículo como NO disponible en Firebase
    await vehicleRef.update({'disponibilidad': false});

    // 🔥 3️⃣ Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Reserva realizada correctamente"),
    ));

    Navigator.pop(context); // Volver a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.vehicleData['imagenes'] != null &&
            widget.vehicleData['imagenes'].isNotEmpty)
        ? widget.vehicleData['imagenes'][0]
        : "https://cdn-icons-png.flaticon.com/512/1998/1998701.png"; // 🔥 Imagen por defecto

    return Scaffold(
      appBar: AppBar(
          title: Text(
              "${widget.vehicleData['marca']} ${widget.vehicleData['modelo']}")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(imageUrl,
                width: double.infinity, height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text("Precio por día: ${widget.vehicleData['precio']}€",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // 🔥 Selección de Fechas
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(startDate == null
                  ? "Seleccionar fecha de inicio"
                  : "Inicio: ${dateFormat.format(startDate!)}"),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(endDate == null
                  ? "Seleccionar fecha de fin"
                  : "Fin: ${dateFormat.format(endDate!)}"),
              onTap: () => _selectDate(context, false),
            ),

            // 🔥 Precio Total
            SizedBox(height: 10),
            Text("Total a pagar: ${totalPrice.toStringAsFixed(2)}€",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // 🔥 Botón para confirmar reserva
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmReservation,
              child: Text("Confirmar Reserva"),
            ),
          ],
        ),
      ),
    );
  }
}
