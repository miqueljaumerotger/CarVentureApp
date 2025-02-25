import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_screen.dart';

/**
 * Clase SplashScreen
 *
 * Esta pantalla de inicio proporciona una animación de carga mientras la aplicación se prepara 
 * para navegar a la pantalla de autenticación (`AuthScreen`). Sirve como una introducción visual
 * que refuerza la identidad de la aplicación.
 *
 * Funcionalidades principales:
 * - Muestra un efecto de neón con el logotipo de "CARVENTURE".
 * - Incluye una animación de texto con una transición de opacidad para una mejor experiencia visual.
 * - Integra una barra de progreso animada para indicar el tiempo de espera antes de redirigir al usuario.
 * - Utiliza un temporizador (`Timer.periodic`) para simular el proceso de carga antes de mostrar la pantalla de autenticación.
 *
 * Métodos destacados:
 * - `_startLoadingAnimation()`: Inicia la animación de carga y controla el progreso.
 * - `_navigateToLogin()`: Redirige automáticamente a la pantalla de autenticación cuando finaliza la animación.
 *
 * Diseño:
 * - Fondo oscuro con un degradado radial en tonos morado y negro para mantener la temática futurista.
 * - Animación de opacidad en el logotipo para un efecto de entrada progresivo.
 * - Barra de progreso con un diseño estilizado y efectos de sombra para una apariencia moderna.
 */


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
  }

  void _startLoadingAnimation() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (progress < 1.0) {
        setState(() {
          progress += 0.025;
        });
      } else {
        timer.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🖤 Fondo oscuro elegante
      body: Stack(
        children: [
          // 🔥 Efecto de neón en el fondo
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✨ Texto con sombra de neón animada
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
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
                    );
                  },
                ),

                SizedBox(height: 10),

                // 🏎️ Animación de "Cargando..."
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(seconds: 3),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        "Preparando tu próxima aventura...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 30),

                // 🚀 Barra de progreso con animación suave
                Container(
                  width: 250,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: progress * 250,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purpleAccent, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
