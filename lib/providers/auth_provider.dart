import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reproductor_colaborativo_sw1/models/cliente_model.dart';
import 'package:reproductor_colaborativo_sw1/models/usuario_model.dart';

// Provider para almacenar información del cliente actual
final clienteProvider = StateProvider<Cliente?>((ref) {
  return null; // Inicialmente no hay cliente autenticado
});

// Provider para almacenar información del usuario/mesero actual
final meseroProvider = StateProvider<Usuario?>((ref) {
  return null; // Inicialmente no hay usuario mesero autenticado
});

// Provider para tipo de usuario actual
final userTypeProvider = StateProvider<String>((ref) {
  return "none"; // Valores posibles: "none", "cliente", "mesero"
});