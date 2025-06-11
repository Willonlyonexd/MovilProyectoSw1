import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:reproductor_colaborativo_sw1/config/graphql_config.dart';
import 'package:reproductor_colaborativo_sw1/graphql/queries/reserva_queries.dart';
import 'package:reproductor_colaborativo_sw1/models/reserva_model.dart';

class ReservaRepository {
  final GraphQLClient _client = getGraphQLClient();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getTenantId() async {
    final tenantId = await _storage.read(key: 'tenantId');
    debugPrint('🔐 ReservaRepository: TenantId: $tenantId');
    return tenantId;
  }

  Future<String?> _getClienteId() async {
    final clienteId = await _storage.read(key: 'clienteId');
    debugPrint('🔐 ReservaRepository: ClienteId: $clienteId');
    return clienteId;
  }

  Future<List<Reserva>> getReservasCliente() async {
    try {
      final tenantId = await _getTenantId();
      final clienteId = await _getClienteId();
      
      if (tenantId == null || clienteId == null) {
        throw Exception('No hay un tenant o cliente seleccionado');
      }
      
      debugPrint('🔍 ReservaRepository: Consultando reservas para cliente: $clienteId en tenant: $tenantId');
      
      final result = await _client.query(
        QueryOptions(
          document: gql(ReservaQueries.getReservasByCliente),
          variables: {
            'tenantId': tenantId,
            'clienteId': clienteId,
          },
          fetchPolicy: FetchPolicy.networkOnly, // Siempre obtener datos frescos
        ),
      );
      
      if (result.hasException) {
        debugPrint('❌ ReservaRepository: Error en consulta GraphQL: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      if (result.data == null || result.data!['reservasByTenantIdAndClienteId'] == null) {
        debugPrint('❌ ReservaRepository: No se encontraron datos de reservas');
        return [];
      }
      
      final reservasList = result.data!['reservasByTenantIdAndClienteId'] as List<dynamic>;
      debugPrint('✅ ReservaRepository: Se encontraron ${reservasList.length} reservas');
      
      // Procesamos cada reserva y manejamos posibles errores de forma individual
      List<Reserva> reservas = [];
      for (var json in reservasList) {
        try {
          reservas.add(Reserva.fromJson(json));
        } catch (e) {
          debugPrint('⚠️ ReservaRepository: Error al procesar una reserva: $e. Datos: $json');
          // Continuamos con la siguiente reserva
        }
      }
      
      return reservas;
    } catch (e) {
      debugPrint('❌ ReservaRepository: Error obteniendo reservas del cliente: $e');
      return [];
    }
  }

  Future<Reserva?> crearReserva({
    required String mesaId,
    required String fechaReserva,
    required String hora,
    required int cantidadPersonas,
    String? observaciones,
  }) async {
    try {
      final tenantId = await _getTenantId();
      final clienteId = await _getClienteId();
      
      if (tenantId == null || clienteId == null) {
        throw Exception('No hay un tenant o cliente seleccionado');
      }
      
      debugPrint('💾 ReservaRepository: Creando reserva - Mesa: $mesaId, Fecha: $fechaReserva, Hora: $hora, Personas: $cantidadPersonas');
      
      // Validación de datos antes de enviar
      if (mesaId.isEmpty) throw Exception('ID de mesa no válido');
      if (fechaReserva.isEmpty) throw Exception('Fecha no válida');
      if (hora.isEmpty) throw Exception('Hora no válida');
      if (cantidadPersonas <= 0) throw Exception('Cantidad de personas debe ser mayor a 0');
      
      final Map<String, dynamic> inputVars = {
        'tenantId': tenantId,
        'mesaId': mesaId,
        'clienteId': clienteId,
        'fechaReserva': fechaReserva,
        'hora': hora,
        'cantidadPersonas': cantidadPersonas,
      };
      
      // Solo añadimos observaciones si no es null o vacío
      if (observaciones != null && observaciones.isNotEmpty) {
        inputVars['observaciones'] = observaciones;
      }
      
      debugPrint('🔍 ReservaRepository: Variables de mutación: $inputVars');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ReservaQueries.crearReserva),
          variables: {
            'input': inputVars
          },
        ),
      );
      
      if (result.hasException) {
        debugPrint('❌ ReservaRepository: Error en mutación GraphQL: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      if (result.data == null || result.data!['createReserva'] == null) {
        debugPrint('❌ ReservaRepository: Respuesta vacía al crear reserva');
        throw Exception('No se recibió respuesta del servidor al crear la reserva');
      }
      
      debugPrint('✅ ReservaRepository: Reserva creada exitosamente');
      return Reserva.fromJson(result.data!['createReserva']);
    } catch (e) {
      debugPrint('❌ ReservaRepository: Error creando reserva: $e');
      return null;
    }
  }

  Future<bool> confirmarReserva(String reservaId) async {
    try {
      if (reservaId.isEmpty) {
        throw Exception('ID de reserva no válido');
      }
      
      debugPrint('🔄 ReservaRepository: Confirmando reserva: $reservaId');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ReservaQueries.confirmarReserva),
          variables: {
            'id': reservaId,
          },
        ),
      );
      
      if (result.hasException) {
        debugPrint('❌ ReservaRepository: Error al confirmar reserva: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      debugPrint('✅ ReservaRepository: Reserva confirmada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ ReservaRepository: Error confirmando reserva: $e');
      return false;
    }
  }

  Future<bool> cancelarReserva(String reservaId, {String? motivo}) async {
    try {
      if (reservaId.isEmpty) {
        throw Exception('ID de reserva no válido');
      }
      
      debugPrint('🚫 ReservaRepository: Cancelando reserva: $reservaId, Motivo: $motivo');
      
      final variables = {
        'id': reservaId,
      };
      
      if (motivo != null && motivo.isNotEmpty) {
        variables['motivo'] = motivo;
      }
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ReservaQueries.cancelarReserva),
          variables: variables,
        ),
      );
      
      if (result.hasException) {
        debugPrint('❌ ReservaRepository: Error al cancelar reserva: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }
      
      debugPrint('✅ ReservaRepository: Reserva cancelada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ ReservaRepository: Error cancelando reserva: $e');
      return false;
    }
  }
}