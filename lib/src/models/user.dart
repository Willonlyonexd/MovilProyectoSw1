class User {
  final String displayName;
  final ExternalUrls? externalUrls;
  final Followers? followers;
  final String href;
  final String id;
  final List<Image>? images;
  final String type;
  final String uri;
  bool admin = false;

  User({
    required this.displayName,
    required this.externalUrls,
    required this.followers,
    required this.href,
    required this.id,
    required this.images,
    required this.type,
    required this.uri,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        displayName: json["display_name"],
        externalUrls: ExternalUrls.fromJson(json["external_urls"]),
        followers: Followers.fromJson(json["followers"]),
        href: json["href"],
        id: json["id"],
        images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        type: json["type"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "display_name": displayName,
        "external_urls": externalUrls?.toJson(),
        "followers": followers?.toJson(),
        "href": href,
        "id": id,
        "images": List<dynamic>.from(images!.map((x) => x.toJson())),
        "type": type,
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

class Followers {
  final dynamic href;
  final int total;

  Followers({
    required this.href,
    required this.total,
  });

  factory Followers.fromJson(Map<String, dynamic> json) => Followers(
        href: json["href"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
        "total": total,
      };
}

class Image {
  final int height;
  final String url;
  final int width;

  Image({
    required this.height,
    required this.url,
    required this.width,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
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
