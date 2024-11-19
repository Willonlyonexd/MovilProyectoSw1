import 'package:flutter/material.dart';

class VoteSection extends StatelessWidget {
  // Lista de canciones (puede venir de la API)
  final List<Map<String, dynamic>> songs;

  // Callback para manejar votos
  final Function(Map<String, dynamic>) onVote;

  // Constructor
  const VoteSection({
    Key? key,
    required this.songs, // Lista de canciones obligatoria
    required this.onVote, // Callback para manejar votos
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votación de canciones:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        // Manejo del estado vacío
        songs.isEmpty
            ? const Center(
                child: Text(
                  'No hay canciones disponibles.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                shrinkWrap: true, // Evita errores de scroll
                physics:
                    const NeverScrollableScrollPhysics(), // Scroll manejado por la pantalla principal
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Card(
                    color: Colors.grey[900], // Fondo oscuro
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8), // Bordes redondeados para la imagen
                        child: Image.network(
                          song['imageUrl'] ??
                              'https://via.placeholder.com/50', // Imagen de la canción
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.music_note,
                                  color: Colors.white70),
                        ),
                      ),
                      title: Text(
                        song['name'] ?? 'Sin título', // Nombre de la canción
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        song['artist'] ?? 'Artista desconocido', // Artista
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.green),
                        onPressed: () {
                          onVote(song); // Llama al callback cuando se vota
                        },
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
