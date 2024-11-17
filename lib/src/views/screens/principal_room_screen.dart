import 'package:flutter/material.dart';
import '../widgets/user_list.dart'; // Widget para lista de usuarios
import '../widgets/room_code_display.dart'; // Widget para mostrar código de la sala
import '../widgets/vote_section.dart'; // Widget para votación de canciones
import '../widgets/player_controls.dart'; // Widget para controles del reproductor

class PrincipalRoomScreen extends StatelessWidget {
  const PrincipalRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala Principal'), // Título fijo
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context); // Navega a la pantalla anterior
              print('Saliendo de la sala');
            },
          ),
        ],
      ),
      backgroundColor: Colors.black, // Fondo negro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parte superior: Título fijo y código de sala
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sala Principal', // Nombre fijo
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const RoomCodeDisplay(roomCode: 'XXXX'), // Código fijo por ahora
              ],
            ),
            const SizedBox(height: 20),

            // Parte media: Lista de usuarios y votación
            Expanded(
              child: Column(
                children: [
                  const Expanded(
                    child: UserList(), // Muestra la lista de usuarios
                  ),
                  const SizedBox(height: 20),
                  const VoteSection(), // Sección de votación de canciones
                ],
              ),
            ),

            // Parte inferior: Controles del reproductor y botón para salir
            Column(
              children: [
                const PlayerControls(), // Controles del reproductor
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Navega hacia atrás
                      print('Saliendo de la sala...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Botón rojo
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Abandonar Sala',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
