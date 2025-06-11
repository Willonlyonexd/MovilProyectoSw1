import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:lottie/lottie.dart';
import 'package:reproductor_colaborativo_sw1/api/popular_products_provider.dart';
//import 'package:reproductor_colaborativo_sw1/services/user_provider.dart';
import 'package:reproductor_colaborativo_sw1/src/services1/providers.dart';
//import 'package:reproductor_colaborativo_sw1/src/services1/user_service.dart';
//import '../widgets/spotify_button.dart';

class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //nal cliente = ref.watch(clienteProvider);
    final user = ref.watch(userProvider);
    final popularProducts = ref.watch(popularProductsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 21),
          // ... (TODO EL CÓDIGO QUE YA TENÍAS, pero borra secciones de reservas)
          const SizedBox(height: 20),
          const Text(
            '¿Qué se te antoja hoy?',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          const Text(
            'Platos Populares',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          popularProducts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Error al cargar productos', style: TextStyle(color: Colors.red)),
            data: (productos) => SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.asset(
                              producto['imagen']!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                          ),
                          child: Text(
                            producto['nombre']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
