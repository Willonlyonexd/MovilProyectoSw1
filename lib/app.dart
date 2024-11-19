import 'package:flutter/material.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/create_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/join_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/login_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/home_screen.dart'; // Pantalla principal
import 'package:reproductor_colaborativo_sw1/src/views/screens/principal_room_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reproductor Colaborativo',
      theme: ThemeData(
        primarySwatch: Colors.green, // Cambia el tema según tus necesidades.
      ),
      initialRoute: '/', // Ruta inicial.
      routes: {
        '/': (context) => const LoginScreen(), // Pantalla de inicio de sesión.
        '/home': (context) => const HomeScreen(), // Pantalla principal.
        '/create_room': (context) => const CreateRoomScreen(), // Crear sala.
        '/join_room': (context) => const JoinRoomScreen(), // Unirse a una sala.
        '/principal_room': (context) => const PrincipalRoomScreen(),
      },
    );
  }
}
