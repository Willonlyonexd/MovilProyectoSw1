import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Importar el paquete Lottie
import '../widgets/spotify_button.dart';
import '../widgets/animated_gradient_text.dart'; // Asegúrate de importar el widget de texto animado

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto "Reproductor Colaborativo" (Texto fijo)
            const Text(
              'Reproductor Colaborativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white, // Color blanco
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10), // Separación entre los textos

            // Texto "FicctFy" con gradiente animado y fuente personalizada
            AnimatedMovingGradientText(
              text: 'FicctFy',
              textStyle: const TextStyle(
                fontSize: 60, // Tamaño más grande
                fontFamily: 'Starshines', // Fuente personalizada
                fontWeight: FontWeight.normal,
              ),
              gradientColors: [
                Colors.blue,
                Colors.purple,
                Colors.pink,
                Colors.red,
                Colors.orange,
                Color.fromARGB(255, 162, 126, 7),
              ],
              duration: const Duration(seconds: 5), // Duración del gradiente
            ),
            const SizedBox(height: 20), // Separación entre texto y animación

            // Animación Lottie más grande
            Lottie.asset(
              'assets/Lottie/Animation-Login1.json', // Ruta a la animación
              width: 400, // Ajusta el ancho
              height: 400, // Ajusta la altura
              fit: BoxFit.contain,
            ),
            const SizedBox(
                height: 40), // Separación entre la animación y el botón

            // Botón de inicio de sesión
            NeonButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/home'); // Navega a la pantalla principal

                print('Iniciando sesión con Spotify...');
              },
              text: 'Iniciar Sesión con Spotify',
              color: Colors.green,
              icon: Icons.music_note,
            ),
          ],
        ),
      ),
    );
  }
}
