import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:reproductor_colaborativo_sw1/src/models/user.dart';
import 'package:reproductor_colaborativo_sw1/src/services/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> getUserProfile(WidgetRef ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final User user;
  if (token != null) {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      user = User.fromJson(jsonDecode(response.body));
      ref.read(userProvider.notifier).update((state) => user);
    } else {
      throw 'Error al obtener el perfil de usuario: ${response.body}';
    }
  } else {
    throw 'No se encontró el token de acceso';
  }
}
