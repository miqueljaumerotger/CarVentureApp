import 'package:carventureapp/screens/home_screen.dart' show HomeScreen;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/**
 * Clase AuthScreen
 *
 * Esta pantalla proporciona la funcionalidad de autenticación para los usuarios de la aplicación.
 * Permite a los usuarios iniciar sesión o registrarse con correo electrónico y contraseña utilizando Firebase Authentication.
 *
 * Funcionalidades principales:
 * - Inicio de sesión con Firebase Authentication mediante correo y contraseña.
 * - Registro de nuevos usuarios en Firebase Authentication.
 * - Almacena los datos de los usuarios registrados en Firebase Realtime Database.
 * - Redirige al usuario a la pantalla principal después de una autenticación exitosa.
 *
 * Métodos destacados:
 * - `_signIn()`: Inicia sesión con Firebase usando las credenciales ingresadas.
 * - `_register()`: Registra un nuevo usuario en Firebase Authentication y almacena su información en la base de datos.
 *
 * Diseño:
 * - Interfaz sencilla con campos de entrada para el correo y la contraseña.
 * - Botones para iniciar sesión y registrarse con estilo estándar de Material Design.
 */


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CarVenture Mallorca")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: Text("Iniciar Sesión")),
            ElevatedButton(onPressed: _register, child: Text("Registrarse")),
          ],
        ),
      ),
    );
  }
}
