import 'package:flutter/material.dart';
import 'package:reproductor_colaborativo_sw1/src/controllers/spotify_controller.dart';
import 'package:reproductor_colaborativo_sw1/src/services/spotify_services.dart';

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({super.key});

  @override
  _SearchMusicPageState createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = []; // Para almacenar resultados
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchMusic(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Llama a tu función para buscar música
      List<Map<String, String>> results = await searchSpotify(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error buscando música: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Música')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchMusic,
              decoration: InputDecoration(
                labelText: 'Escribe una canción o artista...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final song = _searchResults[index];
                return ListTile(
                  title: Text(song['name']!),
                  subtitle: Text(song['artist']!),
                  onTap: () => playSong(song['uri']!), // Reproducir al tocar
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
