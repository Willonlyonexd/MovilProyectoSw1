import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/models/user.dart' as users;
import 'package:reproductor_colaborativo_sw1/src/services/providers.dart';
import 'package:reproductor_colaborativo_sw1/src/services/socket_services.dart';
import 'package:reproductor_colaborativo_sw1/src/services/spotify_services.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../widgets/user_list.dart';
import 'package:provider/provider.dart' as provider;

class PrincipalRoomScreen extends ConsumerStatefulWidget {
  const PrincipalRoomScreen({super.key});

  @override
  PrincipalRoomScreenState createState() => PrincipalRoomScreenState();
}

class PrincipalRoomScreenState extends ConsumerState<PrincipalRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _currentTrackId;
  late SocketProvider _socketProvider =
      provider.Provider.of<SocketProvider>(context, listen: true);
  List<Music> _searchResults = [];
  bool _isLoading = false;
  int _hasExecutedOnce = 0;
  bool b = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ahora que el contexto está disponible, obtenemos el socket provider
    _socketProvider =
        provider.Provider.of<SocketProvider>(context, listen: true);

    // Suscribirse al estado del reproductor si no está ya suscrito
    if (_playerStateSubscription == null) {
      _subscribeToPlayerState();
    }
  }

  void _subscribeToPlayerState() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = SpotifySdk.subscribePlayerState().listen(
        (PlayerState playerState) async {
      if (playerState.track?.uri != null) {
        final newTrackId = playerState.track!.uri;

        // Verificamos si es una canción diferente
        if (newTrackId != _currentTrackId) {
          _currentTrackId = newTrackId;
          // Verificar si es la segunda vez o más
          if (_hasExecutedOnce > 0) {
            final roomCode = ref.watch(roomCodeProvider);
            _socketProvider.removeFirstFromMusics(roomCode);
            if (_socketProvider.musicQueue.isNotEmpty) {
              Music music = _socketProvider.musicQueue.first;
              _socketProvider.addMusicToList(roomCode, music);
              await SpotifySdk.queue(spotifyUri: music.uri);
              _socketProvider.removeFirstFromQueue(roomCode);
            } else {
              Music music = _socketProvider.musicReserved.first;
              _socketProvider.addMusicToList(roomCode, music);
              await SpotifySdk.queue(spotifyUri: music.uri);
              _socketProvider.removeFirstFromReserved(roomCode);
            }
            print(
                'Nueva canción reproducida: ${playerState.track!.name} - ${playerState.track!.artist.name}');
          } else {
            _hasExecutedOnce += 1;
          }
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
    final List<String> genres = args['genres'];
    final bool hasAnimator = args['hasAnimator'];
    final roomCode = ref.watch(roomCodeProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          roomCode,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.people_alt_rounded,
                  color: Color.fromARGB(255, 97, 248, 102),
                  size: 30,
                ), // Cambiar el ícono aquí
                onPressed: () {
                  // Abre el EndDrawer cuando se hace clic en el ícono
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  height: 180, // Altura máxima para mostrar 5 canciones
                  child: ListView.builder(
                    itemCount: _socketProvider.musicList.length,
                    itemBuilder: (context, index) {
                      Music song = _socketProvider.musicList[index];
                      return ListTile(
                          dense: true,
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
                          trailing: LottieBuilder.asset(
                            'assets/Lottie/play-music.json',
                            width: 30,
                          ));
                    },
                  ),
                ),
                const Text(
                  'Sugiere una música',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 8),
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
                  height: 190,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final song = _searchResults[index];
                      return _listTileMusic(song, _socketProvider, roomCode);
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Vota por una música',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    height: 370, // Altura máxima para mostrar 5 canciones
                    child: ListView.builder(
                      itemCount: _socketProvider.musicQueue.length,
                      itemBuilder: (context, index) {
                        Music song = _socketProvider.musicQueue[index];
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
                          dense: true,
                          trailing: Container(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: _socketProvider.hasVoted(song.id)
                                        ? Colors.green
                                        : Colors
                                            .grey, // Si ya votó, deshabilitar el color
                                  ),
                                  onPressed: _socketProvider.hasVoted(song.id)
                                      ? null // Deshabilitar el botón si ya ha votado
                                      : () async {
                                          _socketProvider.increaseVotes(
                                              roomCode, song);
                                        },
                                ),
                                Text(
                                  song.votos.toString(),
                                  style: TextStyle(
                                      color: Colors.grey.shade100,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
              Expanded(
                  child: ListView.builder(
                itemCount: _socketProvider.users.length,
                itemBuilder: (context, index) {
                  users.User user = _socketProvider.users[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[800], // Fondo del avatar
                      backgroundImage:
                          user.images != null && user.images!.isNotEmpty
                              ? NetworkImage(
                                  user.images![0].url) // Imagen del usuario
                              : null, // Si no hay imagen, se deja sin fondo
                      child: user.images == null || user.images!.isEmpty
                          ? const Icon(
                              Icons.person, // Ícono predeterminado
                              color: Colors.white,
                              size: 40,
                            )
                          : null, // No mostrar icono si hay imagen
                    ),
                    title: Text(
                      user.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.music_note, color: Colors.purple[200]),
                  );
                },
              )),

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

  ListTile _listTileMusic(
      Music song, SocketProvider socketProvider, String roomCode) {
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
          socketProvider.addMusicToQueue(roomCode, song);
        });
  }
}
