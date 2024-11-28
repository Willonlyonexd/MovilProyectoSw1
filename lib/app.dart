import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reproductor_colaborativo_sw1/src/services/socket_services.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/client_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/create_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/join_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/login_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/home_screen.dart'; // Pantalla principal
import 'package:reproductor_colaborativo_sw1/src/views/screens/principal_room_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (BuildContext context) => SocketProvider())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Reproductor Colaborativo',
          theme: ThemeData(
            primarySwatch:
                Colors.green, // Cambia el tema según tus necesidades.
          ),
          initialRoute: '/', // Ruta inicial.
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/create_room': (context) => const CreateRoomScreen(),
            '/join_room': (context) => const JoinRoomScreen(),
            '/principal_room': (context) => const PrincipalRoomScreen(),
            '/client': (context) => const ClientScreen(),
          },
        ));
  }
}
