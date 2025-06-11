import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Cambiar provider por riverpod
import 'package:reproductor_colaborativo_sw1/src/services1/socket_services.dart';
//import 'package:reproductor_colaborativo_sw1/src/views/screens/create_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/registro_cliente_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/reserva_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/login_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/home_screen.dart'; 
import 'package:reproductor_colaborativo_sw1/src/views/screens/onboarding.dart';
//import 'package:reproductor_colaborativo_sw1/src/views/screens/principal_room_screen.dart';
import 'package:reproductor_colaborativo_sw1/src/views/screens/menu_screen.dart';

// Crear un provider para SocketProvider
final socketProvider = ChangeNotifierProvider((ref) => SocketProvider());

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reproductor Colaborativo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Tema oscuro para que coincida con el resto de la app
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(), 
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/reservation': (context) => const ReservaScreen(),
        '/join_room': (context) => const MenuScreen(),
        //'/principal_room': (context) => const PrincipalRoomScreen(),
        '/registro': (context) => const RegistroClienteScreen(),
      },
    );
  }
}