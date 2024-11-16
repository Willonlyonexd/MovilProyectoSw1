import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/spotify_button.dart'; // Asegúrate de importar el botón generalizado

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String profileImageUrl = ''; // Ruta de imagen de usuario (cambiar según datos obtenidos)

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Avatar del usuario
            CircleAvatar(
              radius: 40,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null, // Imagen del usuario si está disponible
              backgroundColor: Colors.grey[800], // Fondo del avatar
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null, // Icono predeterminado si no hay imagen
            ),

            const SizedBox(height: 10),

            // Texto de bienvenida
            const Text(
              'Hola, Usuario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              '¿Qué escucharemos hoy?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),

            // Título de recomendaciones
            const Text(
              'Recomendaciones para ti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Contenedores de recomendaciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Daily Mix 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Rock y Alternativa',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Top Hits',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Tus canciones favoritas',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Animación Lottie centrada
            Center(
              child: Lottie.asset(
                'assets/Lottie/Animation-Home.json',
                width: 200, // Ajusta el tamaño según sea necesario
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Botones "Crear Sala" y "Unirse a Sala"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeonButton(
                  onPressed: () {
                    print('Crear Sala presionado');
                    Navigator.pushNamed(context, '/create_room');
                  },
                  text: 'Crear Sala',
                  color: Colors.blue,
                  icon: Icons.add,
                ),
                NeonButton(
                  onPressed: () {
                    print('Unirse a Sala presionado');
                    Navigator.pushNamed(context, '/join_room');
                  },
                  text: 'Unirse a Sala',
                  color: Colors.green,
                  icon: Icons.group,
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
