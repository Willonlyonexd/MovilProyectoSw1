import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Importa Lottie
import '../widgets/code_join.dart'; 
import '../widgets/animated_gradient_text.dart'; // Asegúrate de importar el widget de texto animado
import '../widgets/BorderAnimationButton.dart'; // Importa el widget del botón animado
// Importa el widget de texto animado
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ValueNotifier<String> _codeNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      _codeNotifier.value = _codeController.text; // Actualiza el estado del código
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 55),
            

            // Texto en la parte superior con degradado
            AnimatedMovingGradientText(
              text: 'Únete a la sala con tus amigos',
              textStyle: const TextStyle(
                fontSize: 26, // Tamaño estándar
                fontWeight: FontWeight.bold, // Negrita
              ),
              gradientColors: [
                Colors.blue,
                Colors.purple,
                Colors.pink,
                Colors.red,
                Colors.orange,
                Colors.yellow,
              ],
              duration: const Duration(seconds: 5), // Duración del degradado
            ),
            const SizedBox(height: 20),

            // Animación Lottie
            Center(
              child: Lottie.asset(
                'assets/Lottie/Animation-joinsala.json', // Ruta al archivo Lottie
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // Texto adicional
            const Text(
              'Pide al anfitrión que te comparta el código de acceso',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70, // Color blanco más tenue
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo de entrada personalizado
            CodeInputField(
              length: 4, // Número de dígitos
              onCompleted: (code) {
                _codeController.text = code; // Almacena el código ingresado
              },
            ),
            const SizedBox(height: 30),

            // Botón para confirmar
            ValueListenableBuilder<String>(
              valueListenable: _codeNotifier,
              builder: (context, code, child) {
                return BorderAnimationButton(
                  onPressed: () {
                    if (code.length == 4) {
                      if (code == '1234') {
                        Navigator.pushNamed(context, '/main_room');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código inválido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, ingresa un código de 4 dígitos.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                  
                  text: 'Ingresar',
                  borderColor: Colors.green,
                  textColor: Colors.white,
                  buttonColor: Colors.grey[900]!,
                  borderWidth: 3.0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
