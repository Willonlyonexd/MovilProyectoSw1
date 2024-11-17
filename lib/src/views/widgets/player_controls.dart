import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: () {
            print('Canción anterior');
          },
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green, size: 32),
          onPressed: () {
            print('Reproducir');
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: () {
            print('Siguiente canción');
          },
        ),
      ],
    );
  }
}
