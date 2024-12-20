import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart' as provider;
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/services/socket_services.dart';
import 'package:reproductor_colaborativo_sw1/src/services/spotify_services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../widgets/BorderAnimationButton.dart'; // Importa el widget del botón animado

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final Map<String, bool> _genres = {
    'Rock': false,
    'Pop': false,
    'Hip-Hop': false,
    'Electrónica': false,
    'Clásica': false,
    'Jazz': false,
    'Reguetón': false,
    'Indie': false,
  }; // Mapa para manejar los géneros y su selección
  bool _hasAnimator = false; // Estado del checkbox para "¿Habrá animador?"
  String roomCode = '';
  final TextEditingController _searchController = TextEditingController();
  List<Music> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _searchMusic(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      List<Music> results = await searchSpotify(query, ref);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = provider.Provider.of<SocketProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              // Campo de texto para el nombre de la sala
              const Text(
                'Nombre de la sala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  hintText: 'Ingresa el nombre de la sala',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Título para géneros musicales
              const Text(
                'Selecciona géneros musicales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Chips de géneros musicales
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _genres.keys.map((genre) {
                    final isSelected = _genres[genre]!;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _genres[genre] = !isSelected;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              const Text(
                'O busca una canción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 15),
                height: 70,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.black),
                child: TextField(
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  controller: _searchController,
                  onChanged: _searchMusic,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Escribe una canción o artista...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.purple.shade900, width: 2)),
                height: 188,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final song = _searchResults[index];
                    return _listTileMusic(song);
                  },
                ),
              ),

              // Checkbox para "¿Habrá animador?"
              Row(
                children: [
                  Checkbox(
                    value: _hasAnimator,
                    onChanged: (value) {
                      setState(() {
                        _hasAnimator = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text(
                    '¿Habrá animador?',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Animación Lottie encima del botón
              Center(
                child: Lottie.asset(
                  'assets/Lottie/Animation-CrearSala.json', // Ruta al archivo Lottie
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Botón para crear la sala usando BorderAnimationButton
              Center(
                child: BorderAnimationButton(
                  onPressed: () async {
                    // Verifica si el nombre de la sala está vacío
                    if (_roomNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, ingresa un nombre para la sala.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Obtener géneros seleccionados
                    final selectedGenres = _genres.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    // Verifica si se seleccionaron géneros
                    if (selectedGenres.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, selecciona al menos un género.',
                          ),
                        ),
                      );
                      return;
                    }
                    await socketProvider.emit(
                        'crear-sala', {'musicLits': [], 'userDetails': []});

                    await socketProvider.on('nombre-de-sala', (payload) {
                      setState(() {
                        roomCode = payload;
                      });
                    });
                    // Redirige a PrincipalRoomScreen con los datos de la sala
                    Navigator.pushNamed(
                      context,
                      '/principal_room',
                      arguments: {
                        'roomName': _roomNameController.text,
                        'roomCode': roomCode,
                        'genres': selectedGenres,
                        'hasAnimator': _hasAnimator,
                        'socketProvider': socketProvider
                      },
                    );
                  },
                  text: 'Crear Sala',
                  borderColor: Colors.blue, // Color del borde animado
                  textColor: Colors.white,
                  buttonColor: Colors.grey[900]!,
                  borderWidth: 3.0,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _listTileMusic(Music song) {
    return ListTile(
        title: Text(
          song.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artists.first.name,
          style: TextStyle(color: Colors.grey.shade300),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Image.network(song.album.images.first.url),
        onTap: () async {
          await SpotifySdk.play(spotifyUri: song.uri);
        });
  }
}
