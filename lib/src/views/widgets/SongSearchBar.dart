import 'package:flutter/material.dart';

class SongSearchBar extends StatefulWidget {
  final Function(String) onSearch; // Callback para manejar la búsqueda

  const SongSearchBar({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  _SongSearchBarState createState() => _SongSearchBarState();
}

class _SongSearchBarState extends State<SongSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar canciones:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ingresa el nombre de la canción',
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
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.green),
              onPressed: () {
                widget.onSearch(_controller.text); // Llama al callback
              },
            ),
          ],
        ),
      ],
    );
  }
}
