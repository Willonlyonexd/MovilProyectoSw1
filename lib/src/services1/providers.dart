import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reproductor_colaborativo_sw1/src/models/music.dart';
import 'package:reproductor_colaborativo_sw1/src/models/user.dart';

final userProvider = StateProvider<User>((ref) {
  return User(
      displayName: '',
      externalUrls: null,
      followers: null,
      href: '',
      id: '',
      images: null,
      type: '',
      uri: '');
});

final musicsProvider = StateProvider<List<Music>>((ref) {
  return [];
});

final usersProvider = StateProvider<List<User>>((ref) {
  return [];
});
