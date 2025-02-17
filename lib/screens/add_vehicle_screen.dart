import 'package:flutter/material.dart';
import '../services/firebase_database_service.dart';

class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _precioController = TextEditingController();
  final _imagenController =
      TextEditingController(); // Campo para la URL de la imagen
  String selectedType = 'Coche';
  bool disponibilidad = true;

  final List<String> vehicleTypes = ['Coche', 'Moto'];

  // 🔥 Imagen por defecto si el usuario no ingresa una URL
  final String defaultImage =
      "https://cdn-icons-png.flaticon.com/512/1998/1998701.png"; // URL de imagen por defecto

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      double precio = double.tryParse(_precioController.text) ?? 0;

      await FirebaseDatabaseService().agregarVehiculo(
        _marcaController.text,
        _modeloController.text,
        precio,
        selectedType,
        disponibilidad,
        _imagenController.text.isNotEmpty
            ? _imagenController.text
            : defaultImage, // 🔥 Usamos imagen por defecto si no introduce URL
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Vehículo agregado correctamente"),
      ));

      Navigator.pop(context); // Volver a HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Vehículo")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(labelText: 'Marca'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(labelText: 'Modelo'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio (€)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _imagenController,
                decoration:
                    InputDecoration(labelText: 'URL de Imagen (opcional)'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: vehicleTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Tipo de Vehículo'),
              ),
              SwitchListTile(
                title: Text("Disponible"),
                value: disponibilidad,
                onChanged: (value) {
                  setState(() {
                    disponibilidad = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text("Guardar Vehículo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
