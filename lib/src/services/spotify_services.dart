import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyService {
  final String clientId =
      '1d29336f6a00486e9c0d5ac46ba67c78'; // Reemplaza con tu Client ID
  final String clientSecret =
      'cce20ea8fc764f23b8fb50ba648e9e68'; // Reemplaza con tu Client Secret
  final String tokenUrl = 'https://accounts.spotify.com/api/token';
  final String searchUrl = 'https://api.spotify.com/v1/search';

  late SharedPreferences _prefs;

  // Inicializa los SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Obtiene el token de acceso almacenado
  String? get accessToken => _prefs.getString('token');

  // Obtiene el refresh token almacenado
  String? get refreshToken => _prefs.getString('refresh_token');

  // Guarda el token de acceso
  Future<void> _saveAccessToken(String token) async {
    await _prefs.setString('token', token);
  }

  // Busca canciones en Spotify
  Future<List<Map<String, String>>> search(String query) async {
    if (accessToken == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }

    final response = await http.get(
      Uri.parse('$searchUrl?q=$query&type=track&limit=10'),
      headers: _authHeaders(accessToken!),
    );

    // Si el token expiró, renovarlo y reintentar la solicitud
    if (response.statusCode == 401) {
      await _refreshToken();
      return await search(query); // Reintentar la búsqueda con el nuevo token
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = data['tracks']['items'];

      return tracks.map<Map<String, String>>((track) {
        return {
          'name': track['name'].toString(),
          'artist': track['artists'][0]['name'].toString(),
          'uri': track['uri'].toString(),
        };
      }).toList();
    } else {
      throw Exception('Error buscando en Spotify: ${response.body}');
    }
  }

  // Renueva el token de acceso
  Future<void> _refreshToken() async {
    if (refreshToken == null) {
      throw Exception('Refresh token no encontrado');
    }

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: _basicAuthHeaders(),
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newAccessToken = data['access_token'];

      // Guarda el nuevo token de acceso
      await _saveAccessToken(newAccessToken);
    } else {
      throw Exception('Error al renovar el token: ${response.body}');
    }
  }

  // Headers de autorización básica para renovar tokens
  Map<String, String> _basicAuthHeaders() {
    final String credentials =
        base64Encode(utf8.encode('$clientId:$clientSecret'));
    return {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  // Headers con el token de acceso
  Map<String, String> _authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
