import 'package:url_launcher/url_launcher.dart';

void authenticateWithSpotify() async {
  const String clientId = '1d29336f6a00486e9c0d5ac46ba67c78';
  const String redirectUri = 'myapp://callback';
  const String scopes = 'user-read-private user-read-email';

  const String authUrl =
      'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&scope=$scopes&redirect_uri=$redirectUri';

  // ignore: deprecated_member_use
  await launch(authUrl);
}
