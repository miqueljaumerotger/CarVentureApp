import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

/**
 * Clase VehicleDetailsScreen
 *
 * Esta pantalla muestra los detalles de un vehículo específico y permite a los usuarios realizar reservas.
 * Los usuarios pueden ver información del vehículo, seleccionar fechas para la reserva y calcular el costo total.
 * 
 * Funcionalidades principales:
 * - Muestra la imagen, marca, modelo y precio por día del vehículo.
 * - Permite seleccionar la fecha de inicio y fin de la reserva con un selector de fecha estilizado.
 * - Calcula automáticamente el precio total en función de los días seleccionados.
 * - Guarda la reserva en Firebase Realtime Database y marca el vehículo como no disponible.
 *
 * Métodos destacados:
 * - `_selectDate()`: Abre un selector de fecha con un tema personalizado.
 * - `_calculateTotalPrice()`: Calcula el precio total en base a los días seleccionados.
 * - `_confirmReservation()`: Guarda la reserva en Firebase y cambia la disponibilidad del vehículo.
 * - `_buildNeonBackground()`: Genera un fondo degradado con efecto neón.
 * - `_buildVehicleImage()`: Muestra la imagen del vehículo con efecto de sombra brillante.
 * - `_buildNeonButton()`: Renderiza un botón estilizado con efecto de neón.
 *
 * Diseño:
 * - Utiliza un fondo oscuro con efectos de neón en tonos morados y azules.
 * - Los elementos visuales incluyen sombras, degradados y un diseño atractivo para mejorar la experiencia del usuario.
 * - El selector de fecha y los botones están adaptados al estilo futurista de la aplicación.
 */


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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurpleAccent,
            hintColor: Colors.deepPurpleAccent,
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurpleAccent,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = null;
          }
        } else {
          endDate = pickedDate;
        }
        _calculateTotalPrice();
      });
    }
  }

  void _calculateTotalPrice() {
    if (startDate != null && endDate != null) {
      int days = endDate!.difference(startDate!).inDays + 1;
      double pricePerDay = widget.vehicleData['precio']?.toDouble() ?? 0;
      setState(() {
        totalPrice = days * pricePerDay;
      });
    }
  }

  Future<void> _confirmReservation() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("⚠️ Selecciona las fechas de la reserva"),
        backgroundColor: Colors.redAccent,
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

    await reservationsRef.child(reservationId).set({
      'usuario': userId,
      'vehiculo': widget.vehicleId,
      'fecha_inicio': dateFormat.format(startDate!),
      'fecha_fin': dateFormat.format(endDate!),
      'precio_total': totalPrice,
      'estado': 'pendiente',
    });

    await vehicleRef.update({'disponibilidad': false});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("✅ Reserva realizada correctamente"),
      backgroundColor: Colors.greenAccent,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.vehicleData['imagenes'] != null &&
            widget.vehicleData['imagenes'].isNotEmpty)
        ? widget.vehicleData['imagenes'][0]
        : "https://cdn-icons-png.flaticon.com/512/1998/1998701.png";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "${widget.vehicleData['marca']} ${widget.vehicleData['modelo']}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildVehicleImage(imageUrl),
                SizedBox(height: 15),
                _buildDetailText(
                    "Precio por día: ${widget.vehicleData['precio']}€"),
                SizedBox(height: 15),
                _buildDatePickerTile(
                    "Inicio: ", startDate, () => _selectDate(context, true)),
                _buildDatePickerTile(
                    "Fin: ", endDate, () => _selectDate(context, false)),
                SizedBox(height: 20),
                _buildDetailText(
                    "Total a pagar: ${totalPrice.toStringAsFixed(2)}€"),
                SizedBox(height: 30),
                _buildNeonButton(
                    text: "Confirmar Reserva", onPressed: _confirmReservation),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎇 Fondo con efecto neón
  Widget _buildNeonBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.blue.shade900.withOpacity(0.5), Colors.black],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
      ),
    );
  }

  // 🖼 Imagen del vehículo con glow
  Widget _buildVehicleImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  // 📅 Selección de fechas con estilo neón
  Widget _buildDatePickerTile(
      String label, DateTime? date, VoidCallback onTap) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: Colors.purpleAccent),
      title: Text(
          date == null
              ? "$label Seleccionar fecha"
              : "$label ${dateFormat.format(date)}",
          style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  // 📝 Texto de detalles del vehículo
  Widget _buildDetailText(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // 🚀 Botón con Efecto Neón
  Widget _buildNeonButton(
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
      child: Text(text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
