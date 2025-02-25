import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

/**
 * Clase UserDetailsScreen
 *
 * Esta pantalla permite a los usuarios ver y actualizar sus datos personales en la aplicación.
 * Proporciona funcionalidades para editar el nombre, el teléfono y seleccionar una imagen de perfil.
 * La información se almacena y actualiza en Firebase Realtime Database.
 *
 * Funcionalidades principales:
 * - Permite editar y actualizar el nombre y el número de teléfono del usuario.
 * - Ofrece un selector de imágenes de perfil con varias opciones predeterminadas.
 * - Guarda los cambios en la base de datos de Firebase.
 * - Muestra una interfaz con un diseño futurista y efectos de neón para mantener la coherencia visual de la aplicación.
 *
 * Métodos destacados:
 * - `_updateUserData()`: Actualiza la información del usuario en Firebase.
 * - `_buildTextField()`: Genera los campos de entrada de texto personalizados.
 * - `_buildProfileImageSelector()`: Permite seleccionar un avatar de una lista de imágenes SVG.
 * - `_buildSaveButton()`: Muestra un botón estilizado para guardar los cambios.
 *
 * Diseño:
 * - Fondo oscuro con degradado en tonos morados y negros para dar un efecto de neón.
 * - Inputs con bordes y etiquetas en colores vibrantes para mejorar la visibilidad.
 * - Botón de guardar con efecto de sombra y brillo para destacar la acción principal.
 */


class UserDetailsScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? userData;

  UserDetailsScreen({this.userData});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedProfileImage;

  final List<String> profileImages = [
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Aquarius",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Blizzard",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Cyclone",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Dusk",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Echo",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Falcon",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Galaxy",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Horizon",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Inferno",
    "https://api.dicebear.com/7.x/lorelei/svg?seed=Jungle",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['nombre'] ?? '';
      _phoneController.text = widget.userData!['telefono']?.toString() ?? '';
      selectedProfileImage =
          widget.userData!['profileImage'] ?? profileImages[0];
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      String newName = _nameController.text.trim();
      String newPhone = _phoneController.text.trim();

      await _userRef.child(userId).update({
        'nombre': newName,
        'telefono': newPhone,
        'profileImage': selectedProfileImage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Datos actualizados correctamente"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );

      Navigator.pop(context, {
        'nombre': newName,
        'telefono': newPhone,
        'email': widget.userData?['email'] ?? 'Sin Email',
        'profileImage': selectedProfileImage,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Editar Perfil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                blurRadius: 20,
                color: Colors.purpleAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple],
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
                _buildTextField("Nombre", _nameController),
                SizedBox(height: 15),
                _buildTextField(" Teléfono", _phoneController, isPhone: true),
                SizedBox(height: 25),

                // 🎭 Selector de Imágenes de Perfil con Neon
                Text("Selecciona tu Avatar",
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 10),
                _buildProfileImageSelector(),

                SizedBox(height: 30),

                // 🚀 Botón de Guardar con Efecto Neón
                _buildSaveButton(),
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
            colors: [
              Colors.deepPurple.shade900.withOpacity(0.5),
              Colors.black,
            ],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
      ),
    );
  }

  // 📲 Campos de Texto con Estilo Cyberpunk
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.purpleAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purpleAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purpleAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
        ),
      ),
    );
  }

  // 🎭 Selector de Avatares con Glow Effect
  Widget _buildProfileImageSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: profileImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedProfileImage = profileImages[index];
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: selectedProfileImage == profileImages[index]
                    ? Colors.deepPurpleAccent
                    : Colors.grey.shade800,
                child: ClipOval(
                  child: SvgPicture.network(
                    profileImages[index],
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🚀 Botón de Guardar con Efecto de Brillo
  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
        elevation: 10,
      ),
      onPressed: _updateUserData,
      child: Text(
        "Guardar Cambios",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
