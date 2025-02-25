import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carventureapp/services/image_upload_service.dart';
import 'package:carventureapp/services/firebase_database_service.dart';

/**
 * Clase AddVehicleScreen
 *
 * Esta pantalla permite a los usuarios agregar un nuevo vehículo a la base de datos.
 * Incluye un formulario donde se pueden ingresar los datos del vehículo, como marca,
 * modelo, precio por día, tipo de vehículo y disponibilidad.
 *
 * Funcionalidades principales:
 * - Permite la selección de una imagen desde la galería o la cámara.
 * - Sube la imagen seleccionada a un servicio de almacenamiento en la nube.
 * - Guarda la información del vehículo en la base de datos de Firebase.
 * - Utiliza validaciones en los campos del formulario.
 * - Usa un diseño con temática futurista y efectos de neón.
 *
 * Métodos destacados:
 * - `_pickImage(ImageSource source)`: Permite al usuario seleccionar una imagen.
 * - `_saveVehicle()`: Valida y guarda la información del vehículo en Firebase.
 * - `_buildTextField(String label, TextEditingController controller, {bool isNumeric = false})`: 
 *   Construye un campo de texto con estilo personalizado.
 * - `_buildDropdown()`: Genera un menú desplegable para seleccionar el tipo de vehículo.
 * - `_buildAvailabilitySwitch()`: Permite alternar la disponibilidad del vehículo.
 * - `_buildImageSelector()`: Muestra la interfaz de selección de imágenes.
 * - `_buildNeonButton({required String text, required VoidCallback onPressed})`: 
 *   Crea un botón con efecto neón.
 *
 * Diseño:
 * - Fondo oscuro con efecto de gradiente radial en tonos azul y morado.
 * - Interfaz moderna con bordes redondeados y efectos de sombra en los elementos.
 * - Botones y controles con colores llamativos para resaltar la interacción del usuario.
 */

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print("Imagen seleccionada: ${_selectedImage!.path}"); // Debug
    } else {
      print("No se seleccionó ninguna imagen.");
    }
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {});

      String imageUrl =
          "https://cdn-icons-png.flaticon.com/512/1998/1998701.png";

      if (_selectedImage != null) {
        String? uploadedUrl =
            await _imageUploadService.uploadImageToCloudinary(_selectedImage!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      await _databaseService.agregarVehiculo(
        _marcaController.text,
        _modeloController.text,
        double.parse(_precioController.text),
        _tipo,
        _disponibilidad,
        imageUrl,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("🚗 Vehículo agregado con éxito",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.greenAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // 🔥 Evita el espacio negro en la parte inferior
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Agregar Vehículo",
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // 🔥 Para evitar el espacio negro
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField("Marca", _marcaController),
                              SizedBox(height: 10),
                              _buildTextField("Modelo", _modeloController),
                              SizedBox(height: 10),
                              _buildTextField(
                                  "Precio por día (€)", _precioController,
                                  isNumeric: true),
                              SizedBox(height: 15),
                              _buildDropdown(),
                              SizedBox(height: 15),
                              _buildAvailabilitySwitch(),
                              SizedBox(height: 20),
                              _buildImageSelector(),
                            ],
                          ),
                        ),
                        SizedBox(height: 30), // Espacio antes del botón
                        _buildNeonButton(
                            text: "Guardar Vehículo", onPressed: _saveVehicle),
                        SizedBox(
                            height: 20), // 🔥 Evita que el botón toque el borde
                      ],
                    ),
                  ),
                ),
              );
            },
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

  // 📲 Campos de Texto con Estilo Cyberpunk
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  // 🎛 Dropdown de Tipo de Vehículo
  Widget _buildDropdown() {
    return DropdownButtonFormField(
      dropdownColor: Colors.black,
      value: _tipo,
      items: ['Coche', 'Moto']
          .map((tipo) => DropdownMenuItem(
              value: tipo,
              child: Text(tipo, style: TextStyle(color: Colors.white))))
          .toList(),
      onChanged: (value) => setState(() => _tipo = value.toString()),
      decoration: InputDecoration(
          labelText: "Tipo de Vehículo",
          labelStyle: TextStyle(color: Colors.blueAccent)),
    );
  }

  // 🎛 Switch de Disponibilidad
  Widget _buildAvailabilitySwitch() {
    return SwitchListTile(
      title: Text("Disponible", style: TextStyle(color: Colors.white)),
      activeColor: Colors.blueAccent,
      value: _disponibilidad,
      onChanged: (value) => setState(() => _disponibilidad = value),
    );
  }

  // 📷 Selector de Imagen con Estilo Neón
  Widget _buildImageSelector() {
    return Column(
      children: [
        Text("Selecciona una Imagen",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 10),

        // Vista previa de la imagen seleccionada
        _selectedImage != null
            ? Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Text(
                "No se ha seleccionado ninguna imagen",
                style: TextStyle(color: Colors.white70),
              ),
        SizedBox(height: 15),

        // Botones para seleccionar imagen
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.image, color: Colors.white),
              label: Text("Galería", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text("Cámara", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
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
