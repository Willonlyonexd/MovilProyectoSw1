class Music {
  final Album album;
  final List<Artist> artists;
  final int durationMs;
  final bool explicit;
  final String id;
  final String name;
  final int popularity;
  final dynamic previewUrl;
  final String uri;
  int votos; // Nuevo atributo votos

  Music({
    required this.album,
    required this.artists,
    required this.durationMs,
    required this.explicit,
    required this.id,
    required this.name,
    required this.popularity,
    required this.previewUrl,
    required this.uri,
    this.votos = 0, // Inicializamos votos con 0
  });

  // Método para aumentar los votos
  void aumentarVotos() {
    votos++;
  }

  // Método para disminuir los votos
  void disminuirVotos() {
    if (votos > 0) {
      votos--;
    }
  }

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        album: Album.fromJson(json["album"]),
        artists:
            List<Artist>.from(json["artists"].map((x) => Artist.fromJson(x))),
        durationMs: json["duration_ms"],
        explicit: json["explicit"],
        id: json["id"],
        name: json["name"],
        popularity: json["popularity"],
        previewUrl: json["preview_url"],
        uri: json["uri"],
        votos: json["votos"] ?? 0, // Si no viene, se inicializa con 0
      );

  Map<String, dynamic> toJson() => {
        "album": album.toJson(),
        "artists": List<dynamic>.from(artists.map((x) => x.toJson())),
        "duration_ms": durationMs,
        "explicit": explicit,
        "id": id,
        "name": name,
        "popularity": popularity,
        "preview_url": previewUrl,
        "uri": uri,
        "votos": votos, // Incluimos votos en la conversión a JSON
      };
  static List<Music> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Music.fromJson(json)).toList();
  }
}

class Album {
  final String id;
  final List<Images> images;
  final String name;
  final String uri;

  Album({
    required this.id,
    required this.images,
    required this.name,
    required this.uri,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        id: json["id"],
        images:
            List<Images>.from(json["images"].map((x) => Images.fromJson(x))),
        name: json["name"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "images": List<dynamic>.from(images.map((x) => x.toJson())),
        "name": name,
        "uri": uri,
      };
}

class Artist {
  final String id;
  final String name;
  final String uri;

  Artist({
    required this.id,
    required this.name,
    required this.uri,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        id: json["id"],
        name: json["name"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "uri": uri,
      };
}

class ExternalUrls {
  final String spotify;

  ExternalUrls({
    required this.spotify,
  });

  factory ExternalUrls.fromJson(Map<String, dynamic> json) => ExternalUrls(
        spotify: json["spotify"],
      );

  Map<String, dynamic> toJson() => {
        "spotify": spotify,
      };
}

class Images {
  final int height;
  final String url;
  final int width;

  Images({
    required this.height,
    required this.url,
    required this.width,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        height: json["height"],
        url: json["url"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "url": url,
        "width": width,
      };
}

class ExternalIds {
  final String isrc;

  ExternalIds({
    required this.isrc,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) => ExternalIds(
        isrc: json["isrc"],
      );

  Map<String, dynamic> toJson() => {
        "isrc": isrc,
      };
}
