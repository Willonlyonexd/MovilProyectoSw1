import 'package:flutter/material.dart';

class VoteSection extends StatelessWidget {
  const VoteSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votación de canciones:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Canción 1', style: TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.thumb_up, color: Colors.green),
                onPressed: () {
                  print('Voto positivo para Canción 1');
                },
              ),
            ),
            ListTile(
              title: const Text('Canción 2', style: TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.thumb_up, color: Colors.green),
                onPressed: () {
                  print('Voto positivo para Canción 2');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
