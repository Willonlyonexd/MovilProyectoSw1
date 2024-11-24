import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/services/providers.dart';
import 'package:reproductor_colaborativo_sw1/src/services/socket_services.dart';
import 'package:reproductor_colaborativo_sw1/src/services/spotify_services.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../widgets/user_list.dart';

class PrincipalRoomScreen extends ConsumerStatefulWidget {
  const PrincipalRoomScreen({super.key});

  @override
  PrincipalRoomScreenState createState() => PrincipalRoomScreenState();
}

class PrincipalRoomScreenState extends ConsumerState<PrincipalRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _currentTrackId;
  List<Music> _searchResults = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _subscribeToPlayerState();
  }

  void _subscribeToPlayerState() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription =
        SpotifySdk.subscribePlayerState().listen((PlayerState playerState) {
      if (playerState.track?.uri != null) {
        final newTrackId = playerState.track!.uri;
        if (newTrackId != _currentTrackId) {
          _currentTrackId = newTrackId;
          print(
              'Nueva canción reproducida: ${playerState.track!.name} - ${playerState.track!.artist.name}');
        }
      }
    }, onError: (err) {
      print('Error al suscribirse al estado del reproductor: $err');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _playerStateSubscription?.cancel();
    super.dispose();
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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // Extraer los valores
    final String roomName = args['roomName'];
    final String roomCode = args['roomCode'];
    final List<String> genres = args['genres'];
    final bool hasAnimator = args['hasAnimator'];
    SocketProvider socketProvider = args['socketProvider'];
    final musics = ref.watch(musicsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Lottie.asset(
              'assets/Lottie/Animation -exit3.json', // Ruta de la animación Lottie
              width: 40,
              height: 40,
            ),
          ),
        ],
        title: Text(
          roomName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                if (_isLoading) const CircularProgressIndicator(),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade700)),
                  height: 257,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final song = _searchResults[index];
                      return _listTileMusic(song);
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Lista de músicas',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                SizedBox(
                  height: 370, // Altura máxima para mostrar 5 canciones
                  child: ListView.builder(
                    itemCount: musics.length,
                    itemBuilder: (context, index) {
                      Music song = musics[index];
                      return ListTile(
                        leading: Image.network(
                          song.album.images[1].url,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          song.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          song.artists.first.name,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.thumb_up, color: Colors.green),
                          onPressed: () async {
                            await SpotifySdk.queue(spotifyUri: song.uri);
                            print(song.name);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.black, // Fondo negro del Drawer
        child: SafeArea(
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
