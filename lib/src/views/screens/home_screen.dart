import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:reproductor_colaborativo_sw1/src/services/providers.dart';
import 'package:reproductor_colaborativo_sw1/src/services/user_service.dart';
import '../widgets/spotify_button.dart'; // Asegúrate de importar el botón generalizado

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getUserProfile(ref);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
              backgroundColor: Colors.grey[800], // Fondo del avatar
              backgroundImage: user.images != null
                  ? NetworkImage(user.images![0].url) // Imagen del usuario
                  : null, // Si no hay imagen, se deja sin fondo
              child: user.images == null
                  ? const Icon(
                      Icons.person, // Ícono predeterminado
                      color: Colors.white,
                      size: 40,
                    )
                  : null, // No mostrar icono si hay imagen
            ),

            const SizedBox(height: 10),

            // Texto de bienvenida
            Text(
              'Hola, ${user.displayName}',
              style: const TextStyle(
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                    Navigator.pushNamed(context, '/create_room');
                  },
                  text: 'Crear Sala',
                  color: Colors.blue,
                  icon: Icons.add,
                ),
                NeonButton(
                  onPressed: () {
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
