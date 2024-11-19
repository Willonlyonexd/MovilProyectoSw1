import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/user_list.dart'; // Widget para lista de usuarios
import '../widgets/player_controls.dart'; // Widget para controles del reproductor

class PrincipalRoomScreen extends StatelessWidget {
  const PrincipalRoomScreen({Key? key}) : super(key: key);

  void handleSongSearch(String query) {
    print('Buscando canciones para: $query');
    // Aquí agregarás la lógica para consumir la API de Spotify
  }

  @override
  Widget build(BuildContext context) {
    // Datos simulados para la votación
    final List<Map<String, dynamic>> songs = [
      {
        'name': 'Sound for pass sw1',
        'artist': 'Martinez',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228',
      },
      {
        'name': 'Pensando en ti Julio',
        'artist': 'Korinor Chile',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTAqOBLNG4vuAfTXdNKjtriXqR-PJW62M2VA&s',
      },
      {
        'name': 'Por Interner Ft Wilder Choque',
        'artist': 'Wilder Choque',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYBPe8hRcxKH9IBD0v9EurywnEF94PwOK0Qw&s',
      },
      {
        'name': 'Robando en la Gabi',
        'artist': 'Will & Rafa',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b27331442844d01cb0a841796759',
      },
      {
        'name': 'Hoy me puse linda para detonarte',
        'artist': 'Evo Morales',
        'imageUrl':
            'https://i.pinimg.com/originals/87/97/1f/87971fc020e3a28e5b208685dc108b99.jpg',
      },
    ];

    // Canción en reproducción simulada
    final Map<String, dynamic> currentSong = {
      'name': 'Rafa y los Nene Malo',
      'artist': 'Rafael Salvatierra',
      'imageUrl':
          'https://lastfm.freetls.fastly.net/i/u/ar0/fdfb5def5dc5484aaa83fb2bbf0d4242.jpg',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Positioned(
            top: 15,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/home');
                print('Regresando a la pantalla principal...');
              },
              child: Lottie.asset(
                'assets/Lottie/Animation -exit3.json', // Ruta de la animación Lottie
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrado horizontal
                  children: [
                    // Sección superior: Nombre de la sala y código
                    const Column(
                      children: [
                        Text(
                          'Nombre de Sala',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Código: XXXX',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buscador de canciones
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buscar canciones:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Ingresa el nombre de la canción',
                                  hintStyle:
                                      const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                onSubmitted: handleSongSearch,
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.search, color: Colors.green),
                              onPressed: () {
                                // Aquí se procesará la búsqueda
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Parte media: Votación de canciones
                    Column(
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
                        SizedBox(
                          height: 340, // Altura máxima para mostrar 5 canciones
                          child: ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return ListTile(
                                leading: Image.network(
                                  song['imageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  song['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  song['artist'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.thumb_up,
                                      color: Colors.green),
                                  onPressed: () {
                                    print('Voto positivo para ${song['name']}');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                    // Nueva columna: Reproduciendo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reproduciendo:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PlayerControls(currentSong: currentSong),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Indicador para el sidebar
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: Container(
                  width: 15, // Ancho del indicador
                  height: 100, // Altura del indicador
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.black, // Fondo negro del Drawer
        child: Column(
          children: [
            // Nueva cabecera con el Lottie animationconnect
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/Lottie/Animation-connect.json', // Nueva animación Lottie
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Conectados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Lista de usuarios conectados
            const Expanded(
              child: UserList(), // Muestra la lista de usuarios
            ),

            // Animación Lottie al final
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Lottie.asset(
                  'assets/Lottie/Animation-pulposhark.json', // Animación del pulposhark
                  width: 350,
                  height: 350,
                ),
              ),
            ),

            // Frase debajo del Lottie
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '¡Comparte la diversión o invita a otros a unirse a esta sala!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
