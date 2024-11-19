import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final Map<String, dynamic> currentSong; // Datos de la canción actual

  const PlayerControls({Key? key, required this.currentSong}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Imagen de la canción
            Image.network(
              currentSong['imageUrl'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            // Detalles de la canción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la canción
                  Text(
                    currentSong['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Manejo de texto largo
                  ),
                  const SizedBox(height: 5),
                  // Artista
                  Text(
                    currentSong['artist'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Controles de reproducción
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () {
                print('Canción anterior');
                // Lógica para ir a la canción anterior
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green, size: 32),
              onPressed: () {
                print('Reproducir/Pausar');
                // Lógica para reproducir o pausar
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {
                print('Siguiente canción');
                // Lógica para ir a la siguiente canción
              },
            ),
          ],
        ),
      ],
    );
  }
}
