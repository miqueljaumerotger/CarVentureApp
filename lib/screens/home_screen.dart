import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _vehiclesRef =
      FirebaseDatabase.instance.ref().child('vehiculos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehículos Disponibles"), actions: [
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await _auth.signOut();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthScreen()));
          },
        )
      ]),
      body: StreamBuilder(
  stream: _vehiclesRef.onValue,
  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
      return Center(child: Text("No hay vehículos disponibles."));
    }

    final data = snapshot.data!.snapshot.value;
    if (data is! Map<dynamic, dynamic>) {
      return Center(child: Text("Error al cargar los datos."));
    }

    Map<dynamic, dynamic> vehicles = data;
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        String key = vehicles.keys.elementAt(index);
        var vehicle = vehicles[key];

        return Card(
          child: ListTile(
            leading: Image.network(vehicle['imagenes'][0] ?? '', width: 80, height: 80, fit: BoxFit.cover),
            title: Text("${vehicle['marca'] ?? 'Desconocido'} ${vehicle['modelo'] ?? ''}"),
            subtitle: Text("Precio: \${vehicle['precio']?.toString() ?? 'N/A'}€/día"),
          ),
        );
      },
    );
  },
),


    );
  }
}
