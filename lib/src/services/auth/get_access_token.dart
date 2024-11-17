import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reproductor_colaborativo_sw1/src/views/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> getAccessToken(String code, BuildContext context) async {
  const String clientId = '1d29336f6a00486e9c0d5ac46ba67c78';
  const String clientSecret = 'cce20ea8fc764f23b8fb50ba648e9e68';
  const String redirectUri = 'myapp://callback';
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.post(
    Uri.parse('https://accounts.spotify.com/api/token'),
    headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    final String accessToken = json['access_token'];
    prefs.setString('token', accessToken);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    throw 'Failed to get access token: ${response.body}';
  }
}
