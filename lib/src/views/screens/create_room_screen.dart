import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/BorderAnimationButton.dart'; // Importa el widget del botón animado

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  String _selectedGenre = 'Rock'; // Género seleccionado por defecto
  bool _hasAnimator = false; // Estado del checkbox

  final List<String> _genres = [
    'Rock',
    'Pop',
    'Hip-Hop',
    'Electrónica',
    'Clásica',
    'Jazz',
    'Reguetón',
    'Indie',
  ]; // Lista de géneros

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Sala'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.black, // Fondo negro
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Campo de texto para el nombre de la sala
              const Text(
                'Nombre de la sala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  hintText: 'Ingresa el nombre de la sala',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Dropdown para seleccionar género musical
              const Text(
                'Selecciona un género musical',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedGenre,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: _genres.map((genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Checkbox para "Habrá animador"
              Row(
                children: [
                  Checkbox(
                    value: _hasAnimator,
                    onChanged: (value) {
                      setState(() {
                        _hasAnimator = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text(
                    '¿Habrá animador?',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Animación Lottie encima del botón
              Center(
                child: Lottie.asset(
                  'assets/Lottie/Animation-CrearSala.json', // Ruta al archivo Lottie
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Botón para crear la sala usando BorderAnimationButton
              Center(
                child: BorderAnimationButton(
                  onPressed: () {
                    // Verifica si el nombre de la sala está vacío
                    if (_roomNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, ingresa un nombre para la sala.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Redirige a PrincipalRoomScreen con los datos de la sala
                    Navigator.pushNamed(
                      context,
                      '/principal_room',
                      arguments: {
                        'roomName': _roomNameController.text,
                        'roomCode': 'ABCD', // Código de sala generado (puedes cambiarlo)
                        'genre': _selectedGenre,
                        'hasAnimator': _hasAnimator,
                      },
                    );
                  },
                  text: 'Crear Sala',
                  borderColor: Colors.blue, // Color del borde animado
                  textColor: Colors.white,
                  buttonColor: Colors.grey[900]!,
                  borderWidth: 3.0,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
