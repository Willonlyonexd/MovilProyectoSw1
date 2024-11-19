import 'package:spotify_sdk/spotify_sdk.dart';

Future<void> playSong(String uri) async {
  try {
    await SpotifySdk.play(spotifyUri: uri);
    print('Reproduciendo: $uri');
  } catch (e) {
    print('Error al reproducir canción: $e');
  }
}
