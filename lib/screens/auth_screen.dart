import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carventureapp/providers/auth_provider.dart';
import 'package:carventureapp/screens/home_screen.dart';
import 'package:carventureapp/screens/register_screen.dart';

/**
 * Clase AuthScreen
 *
 * Esta pantalla proporciona la interfaz de inicio de sesión para los usuarios de la aplicación.
 * Permite autenticarse mediante correo y contraseña, así como con Google Sign-In.
 *
 * Funcionalidades principales:
 * - Inicio de sesión con correo y contraseña a través de Firebase Authentication.
 * - Autenticación con Google Sign-In.
 * - Navegación a la pantalla de registro si el usuario no tiene una cuenta.
 * - Diseño moderno con temática futurista y efectos de neón.
 *
 * Métodos destacados:
 * - `_buildTextField(controller, hintText, icon, {obscureText})`: Crea un campo de entrada de texto con estilos personalizados.
 * - `_buildNeonButton({required String text, required VoidCallback onPressed})`: Genera un botón de inicio de sesión con efecto neón.
 * - `_buildGoogleButton(AuthProvider authProvider)`: Crea un botón de inicio de sesión con Google, con icono y estilos personalizados.
 *
 * Diseño:
 * - Fondo oscuro con efecto de gradiente radial en tonos morado y negro.
 * - Campos de entrada con bordes redondeados y efectos de luz.
 * - Botones con sombras y efectos llamativos para mejorar la experiencia de usuario.
 */


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // 🔥 Fondo oscuro elegante
      body: Stack(
        children: [
          // 🔥 Fondo con degradado oscuro y efecto de neón
          Positioned.fill(
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
          ),

          // 🔥 Contenido centrado
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✨ Texto con sombra de neón animada
                  Text(
                    "CARVENTURE",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.deepPurpleAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 🔥 Campo de Email
                  _buildTextField(_emailController, "Correo Electrónico", Icons.email),

                  SizedBox(height: 15),

                  // 🔥 Campo de Contraseña
                  _buildTextField(_passwordController, "Contraseña", Icons.lock, obscureText: true),

                  SizedBox(height: 25),

                  // 🚀 Botón de Inicio de Sesión Tradicional
                  _buildNeonButton(
                    text: "Iniciar Sesión",
                    onPressed: () async {
                      try {
                        await authProvider.signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 15),

                  // 🌟 Botón de Google Sign-In con efecto de brillo
                  _buildGoogleButton(authProvider),

                  SizedBox(height: 20),

                  // 🔥 Link para registrarse con efecto sutil
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "¿No tienes cuenta? Regístrate aquí",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Estilo para los TextFields con efecto futurista
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🚀 Botón con efecto de neón
  Widget _buildNeonButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🔥 Botón de Google Sign-In con estilo mejorado
  Widget _buildGoogleButton(AuthProvider authProvider) {
    return ElevatedButton.icon(
      icon: Image.asset('assets/google_logo.png', width: 24),
      label: Text("Iniciar sesión con Google", style: TextStyle(fontSize: 16)),
      onPressed: () async {
        try {
          await authProvider.signInWithGoogle();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }
}
