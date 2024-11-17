import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reproductor_colaborativo_sw1/src/models/user.dart';

final userProvider = StateProvider<User>((ref) {
  return User(
      country: '',
      displayName: '',
      email: '',
      explicitContent: null,
      externalUrls: null,
      followers: null,
      href: '',
      id: '',
      images: null,
      product: '',
      type: '',
      uri: '');
});
