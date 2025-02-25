import 'package:firebase_auth/firebase_auth.dart';

/**
 * Clase FirebaseAuthService
 *
 * Esta clase proporciona servicios de autenticación utilizando Firebase Authentication.
 * Permite el registro, inicio de sesión y cierre de sesión de usuarios.
 * También maneja la autenticación con credenciales externas como Google.
 *
 * Funcionalidades principales:
 * - `register()`: Registra un nuevo usuario en Firebase con correo electrónico y contraseña.
 * - `signIn()`: Inicia sesión con correo y contraseña en Firebase.
 * - `signInWithCredential()`: Permite el inicio de sesión con credenciales externas, como Google.
 * - `signOut()`: Cierra la sesión del usuario actual.
 * - `user`: Getter que devuelve el usuario autenticado actualmente en Firebase.
 *
 * Uso:
 * - Esta clase se utiliza en conjunto con `AuthProvider` para manejar la autenticación dentro de la aplicación.
 * - Se conecta a Firebase Authentication para gestionar credenciales y sesiones de usuario.
 */


class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Agregar este getter para acceder al usuario autenticado
  User? get user => _auth.currentUser;

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 🔥 Método para autenticarse con Google (soluciona el error)
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
