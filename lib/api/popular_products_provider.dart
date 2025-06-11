import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final popularProductsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500)); // Simula latencia

  final random = Random();
  final indices = <int>{};
  while (indices.length < 5) {
    indices.add(random.nextInt(30) + 1); // producto1.png a producto30.png
  }

  return indices.map((i) => {
    'nombre': 'Producto $i',
    'imagen': 'assets/images/producto$i.png',
  }).toList();
});
