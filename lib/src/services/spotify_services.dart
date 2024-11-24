import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/services/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Music>> searchSpotify(String query, WidgetRef ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    throw Exception('Token no encontrado. Por favor, inicia sesión.');
  }

  final String url =
      'https://api.spotify.com/v1/search?q=$query&type=track&limit=10';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  // Si el token expiró, renovarlo y reintentar la solicitud
  if (response.statusCode == 401) {
    await refreshSpotifyToken();
    token = prefs.getString('token'); // Obtener el nuevo token renovado
    return await searchSpotify(query, ref); // Reintentar la búsqueda
  }

  if (response.statusCode == 200) {
    final data = await jsonDecode(response.body);
    List<Music> musics = (data['tracks']['items'] as List)
        .map((item) => Music.fromJson(item))
        .toList();
    ref.read(musicsProvider.notifier).update((state) => musics);
    return musics;
  } else {
    throw Exception('Error buscando en Spotify: ${response.body}');
  }
}

Future<void> refreshSpotifyToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refresh_token');

  if (refreshToken == null) {
    throw Exception('Refresh token no encontrado');
  }

  const String clientId =
      '1d29336f6a00486e9c0d5ac46ba67c78'; // Reemplaza con tu Client ID
  const String clientSecret =
      'cce20ea8fc764f23b8fb50ba648e9e68'; // Reemplaza con tu Client Secret

  const String url = 'https://accounts.spotify.com/api/token';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String newAccessToken = data['access_token'];

    // Guarda el nuevo token de acceso
    await prefs.setString('token', newAccessToken);
  } else {
    throw Exception('Error al renovar el token: ${response.body}');
  }
}

Future<List<Map<String, dynamic>>> getRecommendations(String trackId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String url =
      'https://api.spotify.com/v1/recommendations?seed_tracks=$trackId&limit=10';
  String? token = prefs.getString('token');
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final tracks = data['tracks'];
    // Mapeamos la lista de canciones recomendadas
    return tracks.map<Map<String, dynamic>>((track) {
      return {
        'name': track['name'],
        'artist': track['artists'][0]['name'],
        'uri': track['uri'],
        'image': track['album']['images'][0]['url'], // Imagen del álbum
      };
    }).toList();
  } else {
    throw Exception('Error al obtener recomendaciones: ${response.body}');
  }
}
