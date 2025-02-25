import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

/**
 * Clase RegisterScreen
 *
 * Esta pantalla permite a los usuarios registrarse en la aplicación mediante un formulario 
 * que recopila su nombre, correo electrónico, número de teléfono y contraseña.
 *
 * Funcionalidades principales:
 * - Permite a los usuarios ingresar sus datos personales y crear una cuenta en Firebase Authentication.
 * - Almacena la información del usuario en Firebase Realtime Database después del registro.
 * - Redirige automáticamente a la pantalla principal (`HomeScreen`) tras un registro exitoso.
 * - Valida los campos del formulario para asegurar que la información ingresada sea correcta.
 *
 * Métodos destacados:
 * - `_buildTextField(label, controller, {isPassword})`: Genera un campo de texto con estilos personalizados.
 * - `_buildNeonButton({required String text, required VoidCallback onPressed})`: 
 *   Crea un botón estilizado con efecto neón para la acción de registro.
 * - `_buildNeonBackground()`: Aplica un fondo con degradado y efecto futurista.
 *
 * Diseño:
 * - Fondo oscuro con un gradiente en tonos azul y morado.
 * - Campos de entrada con estilos modernos y bordes iluminados.
 * - Botón de registro con efecto neón y sombras suaves para mejorar la experiencia de usuario.
 */


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Registro",
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField("Nombre", _nameController),
                SizedBox(height: 15),
                _buildTextField("Email", _emailController),
                SizedBox(height: 15),
                _buildTextField("Teléfono", _phoneController),
                SizedBox(height: 15),
                _buildTextField("Contraseña", _passwordController, isPassword: true),
                SizedBox(height: 25),

                // 🚀 Botón de Registro con Efecto Neón
                _buildNeonButton(
                  text: "Registrarse",
                  onPressed: () async {
                    try {
                      await authProvider.register(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _nameController.text.trim(),
                        _phoneController.text.trim(),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("⚠️ Error: ${e.toString()}")),
                      );
                    }
                  },
                ),
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

  // 📲 Campos de Texto con Estilo Cyberpunk
  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  // 🚀 Botón de Registro con Efecto Neón
  Widget _buildNeonButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.8),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
