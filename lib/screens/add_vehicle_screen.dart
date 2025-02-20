import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carventureapp/services/image_upload_service.dart';
import 'package:carventureapp/services/firebase_database_service.dart';

class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  String _tipo = 'Coche';
  bool _disponibilidad = true;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  // 🔥 Método para seleccionar imagen de la galería o la cámara
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 🔥 Método para guardar vehículo en Firebase
  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {});

      String imageUrl = "https://cdn-icons-png.flaticon.com/512/1998/1998701.png"; // Imagen por defecto

      if (_selectedImage != null) {
        print("📷 Imagen seleccionada: ${_selectedImage!.path}");
        
        String? uploadedUrl = await _imageUploadService.uploadImageToCloudinary(_selectedImage!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl; // ✅ Si la subida es exitosa, usar la URL de Cloudinary
        } else {
          print("⚠️ Error al subir la imagen a Cloudinary, usando imagen por defecto.");
        }
      } else {
        print("⚠️ No se seleccionó ninguna imagen.");
      }

      await _databaseService.agregarVehiculo(
        _marcaController.text,
        _modeloController.text,
        double.parse(_precioController.text),
        _tipo,
        _disponibilidad,
        imageUrl,
      );

      print("✅ Vehículo agregado con imagen: $imageUrl");

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vehículo agregado con éxito")),
      );
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
                decoration: InputDecoration(labelText: "Marca"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(labelText: "Modelo"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: "Precio por día (€)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              DropdownButtonFormField(
                value: _tipo,
                items: ['Coche', 'Moto']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (value) => setState(() => _tipo = value.toString()),
                decoration: InputDecoration(labelText: "Tipo de Vehículo"),
              ),
              SwitchListTile(
                title: Text("Disponible"),
                value: _disponibilidad,
                onChanged: (value) => setState(() => _disponibilidad = value),
              ),
              SizedBox(height: 10),

              // 📷 Selección de imagen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Galería"),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text("Cámara"),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // 🔥 Mostrar imagen seleccionada
              _selectedImage != null
                  ? Image.file(_selectedImage!, width: 200, height: 200, fit: BoxFit.cover)
                  : Text("No se ha seleccionado ninguna imagen"),

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
