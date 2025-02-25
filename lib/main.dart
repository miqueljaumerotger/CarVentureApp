import 'package:carventureapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

/**
 * Clase MyApp
 *
 * Esta es la clase principal de la aplicación CarVenture Mallorca.
 * Se encarga de inicializar Firebase y configurar el proveedor de autenticación.
 *
 * Funcionalidades principales:
 * - `main()`: Inicializa Firebase antes de ejecutar la aplicación.
 * - `MultiProvider`: Administra el estado global con `Provider`, en este caso, `AuthProvider`.
 * - `MaterialApp`: Define la estructura principal de la aplicación.
 * - `SplashScreen()`: Pantalla de bienvenida que se muestra al iniciar la app.
 *
 * Uso:
 * - Este archivo es el punto de entrada de la aplicación.
 * - Se ejecuta automáticamente al iniciar la aplicación y gestiona la navegación.
 */


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CarVenture Mallorca',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}
