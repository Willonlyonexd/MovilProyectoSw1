class User {
  final String country;
  final String displayName;
  final String email;
  final ExplicitContent? explicitContent;
  final ExternalUrls? externalUrls;
  final Followers? followers;
  final String href;
  final String id;
  final List<Image>? images;
  final String product;
  final String type;
  final String uri;

  User({
    required this.country,
    required this.displayName,
    required this.email,
    this.explicitContent,
    this.externalUrls,
    this.followers,
    required this.href,
    required this.id,
    this.images,
    required this.product,
    required this.type,
    required this.uri,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        country: json["country"],
        displayName: json["display_name"],
        email: json["email"],
        explicitContent: ExplicitContent.fromJson(json["explicit_content"]),
        externalUrls: ExternalUrls.fromJson(json["external_urls"]),
        followers: Followers.fromJson(json["followers"]),
        href: json["href"],
        id: json["id"],
        images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        product: json["product"],
        type: json["type"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "display_name": displayName,
        "email": email,
        "explicit_content": explicitContent!.toJson(),
        "external_urls": externalUrls!.toJson(),
        "followers": followers!.toJson(),
        "href": href,
        "id": id,
        "images": List<dynamic>.from(images!.map((x) => x.toJson())),
        "product": product,
        "type": type,
        "uri": uri,
      };
}

class ExplicitContent {
  final bool filterEnabled;
  final bool filterLocked;

  ExplicitContent({
    required this.filterEnabled,
    required this.filterLocked,
  });

  factory ExplicitContent.fromJson(Map<String, dynamic> json) =>
      ExplicitContent(
        filterEnabled: json["filter_enabled"],
        filterLocked: json["filter_locked"],
      );

  Map<String, dynamic> toJson() => {
        "filter_enabled": filterEnabled,
        "filter_locked": filterLocked,
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
