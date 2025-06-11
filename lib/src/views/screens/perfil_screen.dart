import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reproductor_colaborativo_sw1/providers/auth_provider.dart';
//import 'package:reproductor_colaborativo_sw1/services/user_provider.dart';

class MiPerfilPage extends ConsumerWidget {
  const MiPerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener datos del cliente desde el provider
    final cliente = ref.watch(clienteProvider);
    
    // Si no hay cliente, mostrar indicador de carga
    if (cliente == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mi Perfil",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
            const SizedBox(height: 30),

            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.tealAccent,
                child: Text(
                  cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Datos del perfil (usando datos reales del cliente)
            _buildItem("👤 Nombre", "${cliente.nombre} ${cliente.apellido ?? ''}"),
            _buildItem("📧 Email", cliente.email ?? 'No especificado'),
            _buildItem("📱 Teléfono", cliente.telefono ?? 'No especificado'),
            _buildItem("🆔 Usuario", cliente.username),

            const SizedBox(height: 30),

            // Botón editar perfil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar a editar perfil
                },
                icon: const Icon(Icons.edit),
                label: const Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón cerrar sesión
            Center(
              child: TextButton.icon(
                onPressed: () => _cerrarSesion(context, ref),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }
  
  // Método para cerrar sesión
  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?', 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.tealAccent)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    // Mostrar indicador de carga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cerrando sesión...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Realizar el cierre de sesión
    const storage = FlutterSecureStorage();
    
    // Eliminar todos los datos de sesión
    await storage.delete(key: 'token');
    await storage.delete(key: 'clienteId');
    await storage.delete(key: 'clienteNombre');
    await storage.delete(key: 'clienteUsername');
    await storage.delete(key: 'userType');
    await storage.delete(key: 'tenantId');
    
    // También eliminar datos de mesero si existieran
    await storage.delete(key: 'usuarioId');
    await storage.delete(key: 'usuarioNombre');
    await storage.delete(key: 'usuarioUsername');
    
    // Resetear el estado del cliente en el provider
    ref.read(clienteProvider.notifier).state = null;
    
    // Navegar al login y eliminar todas las rutas anteriores
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}