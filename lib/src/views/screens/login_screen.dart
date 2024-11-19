import 'package:flutter/material.dart';

import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:reproductor_colaborativo_sw1/src/services/auth/auth_spotify.dart';
import 'package:reproductor_colaborativo_sw1/src/services/auth/get_access_token.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../widgets/spotify_button.dart';
import '../widgets/animated_gradient_text.dart'; // Asegúrate de importar el widget de texto animado

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _listenToRedirects();
  }

  void _listenToRedirects() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.toString().startsWith('myapp://callback')) {
        // final String? code = uri.queryParameters['code'];
        // if (code != null) {
        //   getAccessToken(code, context);
        // }
      }
    }, onError: (err) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto "Reproductor Colaborativo" (Texto fijo)
            const Text(
              'Reproductor Colaborativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white, // Color blanco
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10), // Separación entre los textos

            // Texto "FicctFy" con gradiente animado y fuente personalizada
            const AnimatedMovingGradientText(
              text: 'FicctFy',
              textStyle: TextStyle(
                fontSize: 60, // Tamaño más grande
                fontFamily: 'Starshines', // Fuente personalizada
                fontWeight: FontWeight.normal,
              ),
              gradientColors: [
                Colors.blue,
                Colors.purple,
                Colors.pink,
                Colors.red,
                Colors.orange,
                Color.fromARGB(255, 162, 126, 7),
              ],
              duration: Duration(seconds: 5), // Duración del gradiente
            ),
            const SizedBox(height: 20), // Separación entre texto y animación

            // Animación Lottie más grande
            Lottie.asset(
              'assets/Lottie/Animation-Login1.json', // Ruta a la animación
              width: 400, // Ajusta el ancho
              height: 400, // Ajusta la altura
              fit: BoxFit.contain,
            ),
            const SizedBox(
                height: 40), // Separación entre la animación y el botón

            // Botón de inicio de sesión
            NeonButton(
              onPressed: () async {
                try {
                  await SpotifySdk.connectToSpotifyRemote(
                      clientId: "1d29336f6a00486e9c0d5ac46ba67c78",
                      redirectUrl: "myapp://callback");

                  SpotifySdk.subscribePlayerState();
                  SpotifySdk.subscribePlayerContext();
                  final accessToken = await SpotifySdk.getAccessToken(
                      clientId: "1d29336f6a00486e9c0d5ac46ba67c78",
                      redirectUrl: "myapp://callback",
                      scope:
                          "app-remote-control,user-modify-playback-state,playlist-read-private");
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('token', accessToken);
                  Navigator.pushNamed(context, '/prueba');
                  print(accessToken);
                } catch (e) {}
              },
              text: 'Iniciar Sesión con Spotify',
              color: Colors.green,
              icon: Icons.music_note,
            ),
          ],
        ),
      ),
    );
  }
}
