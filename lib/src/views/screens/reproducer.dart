import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> currentSong; // Información de la canción actual

  const PlayerScreen({Key? key, required this.currentSong}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Color backgroundColor = Colors.black; // Color de fondo inicial

  @override
  void initState() {
    super.initState();
    _updateBackgroundColor(); // Actualiza el color de fondo al inicializar
  }

  Future<void> _updateBackgroundColor() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.currentSong['imageUrl']),
      );

      setState(() {
        backgroundColor = paletteGenerator.dominantColor?.color ?? Colors.black;
      });
    } catch (e) {
      setState(() {
        backgroundColor = Colors.black; // Color de respaldo en caso de error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.currentSong;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de la canción
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  song['imageUrl'],
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nombre de la canción
            Text(
              song['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Nombre del artista
            Text(
              song['artist'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  iconSize: 50,
                  onPressed: () {
                    print('Canción anterior');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_fill,
                      color: Colors.white),
                  iconSize: 80,
                  onPressed: () {
                    print('Reproducir canción');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  iconSize: 50,
                  onPressed: () {
                    print('Siguiente canción');
                  },
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
