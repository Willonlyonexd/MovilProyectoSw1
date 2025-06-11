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

  List<User> _users = [];
  List<User> get users => _users;
  List<Music> _musics = [];
  List<Music> get musics => _musics;

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
    _socket.on('actualizar-musicas', (data) {
      _musics = (data as List).map((item) => Music.fromJson(item)).toList();
      notifyListeners();
    });

    _socket.on('actualizar-usuarios', (data) {
      _users = (data as List).map((item) => User.fromJson(item)).toList();
      notifyListeners();
    });
  }
}
