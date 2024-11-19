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
  final Map<String, bool> _genres = {
    'Rock': false,
    'Pop': false,
    'Hip-Hop': false,
    'Electrónica': false,
    'Clásica': false,
    'Jazz': false,
    'Reguetón': false,
    'Indie': false,
  }; // Mapa para manejar los géneros y su selección
  bool _hasAnimator = false; // Estado del checkbox para "¿Habrá animador?"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 50),

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

              // Título para géneros musicales
              const Text(
                'Selecciona géneros musicales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Chips de géneros musicales
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _genres.keys.map((genre) {
                  final isSelected = _genres[genre]!;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _genres[genre] = !isSelected;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Checkbox para "¿Habrá animador?"
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

                    // Obtener géneros seleccionados
                    final selectedGenres = _genres.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    // Verifica si se seleccionaron géneros
                    if (selectedGenres.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, selecciona al menos un género.',
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
                        'roomCode': 'ABCD', // Código de sala generado
                        'genres': selectedGenres,
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
