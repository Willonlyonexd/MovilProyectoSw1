import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Music>> getMusics(String genero) async {
  final String url = 'https://ia-fluttter.vercel.app/api/genre/$genero';
  SharedPreferences prefs = await SharedPreferences.getInstance();
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

    return Music.fromJsonList(data);
  } else {
    throw Exception('Error al obtener la recomendación: ${response.body}');
  }
}

Future<List<Music>> getMusic(String genero) async {
  final String url =
      'https://api.spotify.com/v1/search?q=genre%3A$genero&limit=10&offset=0&type=track';
  SharedPreferences prefs = await SharedPreferences.getInstance();
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

    return Music.fromJsonList(data['tracks']['items']);
  } else {
    throw Exception('Error al obtener la recomendación: ${response.body}');
  }
}
