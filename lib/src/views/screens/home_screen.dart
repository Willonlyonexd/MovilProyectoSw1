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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserProfile(ref); // Asegúrate de tener este método correctamente implementado.
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final playlists = [
      {'name': 'Mi Playlist 1', 'description': 'Mis canciones favoritas'},
      {'name': 'Workout Mix', 'description': 'Energía para entrenar'},
      {'name': 'Relax Vibes', 'description': 'Canciones para relajarme'},
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Avatar del usuario y texto alineado a la derecha
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800], // Fondo del avatar
                  backgroundImage: user.images != null && user.images!.isNotEmpty
                      ? NetworkImage(user.images![0].url) // Imagen del usuario
                      : null, // Si no hay imagen, se deja sin fondo
                  child: user.images == null || user.images!.isEmpty
                      ? const Icon(
                          Icons.person, // Ícono predeterminado
                          color: Colors.white,
                          size: 40,
                        )
                      : null, // No mostrar icono si hay imagen
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Bandera o ícono del país
                          if (user.country == 'BO') ...[
                            Image.asset(
                              'assets/Images/bolivia.png',
                              width: 30,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ] else ...[
                            const Icon(
                              Icons.flag,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                          const SizedBox(width: 5),
                          Text(
                            'País: ${user.country}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Hola, ${user.displayName.isNotEmpty ? user.displayName : 'Usuario'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email.isNotEmpty
                            ? user.email
                            : 'Correo no disponible', // Mostrar correo si existe
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              '¿Qué escucharemos hoy?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Título de playlists
            const Text(
              'Tus Playlists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Playlists dinámicas
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            playlist['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            playlist['description']!,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
