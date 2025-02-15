import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  User? get user => _authService.user;

  Future<void> signIn(String email, String password) async {
  try {
    UserCredential userCredential =
        await _authService.signIn(email, password);
    String userId = userCredential.user!.uid;

    // Obtener referencia a la base de datos
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    DataSnapshot snapshot = await userRef.get();

    // ✅ Manejar el caso en que el usuario no exista en la base de datos
    if (!snapshot.exists || snapshot.value == null) {
      print("Error: Usuario no encontrado en la base de datos.");
      throw Exception("Usuario no registrado en la base de datos.");
    }

    // ✅ Convertir los datos a un Map y manejar valores nulos
    Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;

    if (userData == null) {
      print("Error: Datos del usuario en Firebase son null.");
      throw Exception("Error: Datos del usuario en Firebase no son válidos.");
    }

    // ✅ Extraer datos asegurándose de que no sean null
    String nombre = userData['nombre'] ?? 'Usuario Desconocido';
    String firebaseEmail = userData['email'] ?? 'Sin Email';
    String telefono = userData['telefono']?.toString() ?? 'Sin teléfono';

    print("Inicio de sesión exitoso para: $nombre ($email)");

    // ✅ Notificar cambios en el estado del usuario
    notifyListeners();
  } catch (e) {
    print("Error en el inicio de sesión: $e");
    throw e;
  }
}

  Future<void> register(String email, String password) async {
  try {
    // Intentar crear el usuario en Firebase Auth
    UserCredential userCredential =
        await _authService.register(email, password);
    String userId = userCredential.user!.uid;

    // Verificar si el usuario ya existe en la base de datos
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists && snapshot.value != null) {
      print("El usuario ya está registrado.");
      throw Exception("El usuario ya existe en la base de datos.");
    }

    // ✅ Guardar datos del usuario en Firebase Database con valores seguros
    await userRef.set({
      'email': email,
      'nombre': 'Usuario',
      'telefono': 'Sin teléfono', // Evita errores por falta de campo
      'metodo_pago': 'No definido',
    });

    print("Usuario registrado exitosamente en Firebase Database.");

    notifyListeners();
  } catch (e) {
    print("Error en el registro: $e");
    throw e;
  }
}

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
