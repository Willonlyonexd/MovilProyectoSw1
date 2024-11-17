import 'package:flutter/material.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a una Sala'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.black, // Fondo oscuro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título
            const Text(
              'Ingresa el código de la sala',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo de entrada de código
            TextField(
              controller: codeController,
              maxLength: 4, // Máximo 4 dígitos
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: '1234',
                hintStyle: const TextStyle(color: Colors.white54),
                counterText: '', // Oculta el contador de caracteres
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Botón para confirmar
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.length == 4) {
                  // Lógica para verificar el código
                  print('Código ingresado: $code');
                  // Aquí puedes verificar si el código es válido y redirigir
                  Navigator.pushNamed(context, '/main_room'); // Cambia la ruta según tu configuración
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, ingresa un código válido de 4 dígitos.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Unirse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
