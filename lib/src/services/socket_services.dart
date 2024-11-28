import 'package:flutter/material.dart';
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/models/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ignore: constant_identifier_names
enum ServerStatus { Online, Offline, Connecting }

class SocketProvider with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  final IO.Socket _socket = IO.io('http://192.168.0.13:3001/', {
    'transports': ['websocket'],
    'autoConnect': true
  });

  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;
  Function get on => _socket.on;
  ServerStatus get serverStatus => _serverStatus;
  final Set<String> _votedSongs = {};
  bool hasVoted(String songId) {
    return _votedSongs.contains(songId);
  }

  List<User> _users = [];
  List<Music> _musicList = [];
  List<Music> _musicQueue = [];
  List<Music> _musicReserved = [];

  List<User> get users => _users;
  List<Music> get musicList => _musicList;
  List<Music> get musicQueue => _musicQueue;
  List<Music> get musicReserved => _musicReserved;

  SocketProvider() {
    _initConfig();
  }

  void _initConfig() {
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // Escuchar actualizaciones del servidor
    _socket.on('actualizar-lista-musica', (data) {
      _musicList = (data as List).map((item) => Music.fromJson(item)).toList();
      notifyListeners();
    });
//
    _socket.on('actualizar-reserva-musica', (data) {
      _musicReserved =
          (data as List).map((item) => Music.fromJson(item)).toList();
      notifyListeners();
    });
//
    _socket.on('actualizar-cola-musica', (data) {
      _musicQueue = (data as List).map((item) => Music.fromJson(item)).toList();
      // Ordenar la cola por votos de mayor a menor
      _musicQueue.sort((a, b) => b.votos.compareTo(a.votos));
      notifyListeners();
    });

    _socket.on('actualizar-usuarios', (data) {
      _users = (data as List).map((item) => User.fromJson(item)).toList();
      notifyListeners();
    });
  }

  // Método para agregar música a la lista general
  void addMusicToList(String roomCode, Music music) {
    // Verificar si la canción ya está en la lista
    if (!_musicList.any((song) => song.id == music.id)) {
      _musicList.add(music);
      notifyListeners();

      // Emitir un evento al servidor para sincronizar los datos
      _socket.emit(
          'agregar-musica', {'roomCode': roomCode, 'song': music.toJson()});
    }
  }

//
  void addMusicToReserved(String roomCode, Music music) {
    // Verificar si la canción ya está en la reserva
    if (!_musicReserved.any((song) => song.id == music.id)) {
      _musicReserved.add(music);
      notifyListeners();

      // Emitir un evento al servidor para sincronizar los datos
      _socket.emit(
          'agregar-reserva', {'roomCode': roomCode, 'song': music.toJson()});
    }
  }

//
  // Método para agregar música a la cola de reproducción
  void addMusicToQueue(String roomCode, Music music) {
    // Verificar si la canción ya está en la cola
    if (!_musicQueue.any((song) => song.id == music.id)) {
      _musicQueue.add(music);
      notifyListeners();

      // Emitir un evento al servidor para sincronizar los datos
      _socket.emit(
          'agregar-a-cola', {'roomCode': roomCode, 'song': music.toJson()});
    }
  }

  // Método para eliminar la primera música de la cola de reproducción
  void removeFirstFromQueue(String roomCode) {
    if (_musicQueue.isNotEmpty) {
      _musicQueue.removeAt(0);
      notifyListeners();

      // Emitir el evento al servidor para sincronizar los datos
      _socket.emit('eliminar-primera-musica-queue', roomCode);
    }
  }

  void removeFirstFromReserved(String roomCode) {
    if (_musicReserved.isNotEmpty) {
      _musicReserved.removeAt(0);
      notifyListeners();

      // Emitir el evento al servidor para sincronizar los datos
      _socket.emit('eliminar-primera-musica-reserved', roomCode);
    }
  }

  // Método para eliminar la primera música de la lista general
  void removeFirstFromMusics(String roomCode) {
    if (_musicList.isNotEmpty) {
      _musicList.removeAt(0);
      notifyListeners();

      // Emitir el evento al servidor para sincronizar los datos
      _socket.emit('eliminar-primera-musica-list', roomCode);
    }
  }

  // Método para agregar un usuario a la lista de usuarios
  void addUser(String roomCode, User user) {
    _users.add(user);
    notifyListeners();

    // Emitir un evento al servidor para sincronizar los datos
    _socket
        .emit('agregar-usuario', {'roomCode': roomCode, 'user': user.toJson()});
  }

  void increaseVotes(String roomCode, Music music) {
    // Encontramos la canción en la lista de música
    if (!hasVoted(music.id)) {
      _votedSongs.add(music.id);
      int index = _musicQueue.indexOf(music);

      if (index != -1) {
        _musicQueue[index].aumentarVotos(); // Aumentar los votos de la canción
        notifyListeners(); // Notificar a los oyentes del cambio

        // Emitir el cambio al servidor para que todos los usuarios se sincronicen
        _socket.emit('actualizar-votos', {
          'roomCode': roomCode,
          'song': _musicQueue[index].toJson(),
        });
      }
    }
  }
}
