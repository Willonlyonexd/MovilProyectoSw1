    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:reproductor_colaborativo_sw1/models/reserva_model.dart';
    import 'package:reproductor_colaborativo_sw1/repositories/reserva_repository.dart';

    // Provider para el repositorio de reservas
    final reservaRepositoryProvider = Provider((ref) => ReservaRepository());

    // FutureProvider para obtener todas las reservas del cliente actual
    final reservasClienteProvider = FutureProvider<List<Reserva>>((ref) async {
      final repository = ref.read(reservaRepositoryProvider);
      try {
        return await repository.getReservasCliente();
      } catch (e) {
        // Capturar y re-lanzar con mensaje más descriptivo
        throw Exception('Error al cargar reservas: ${e.toString()}');
      }
    });

    // Provider para filtrar reservas por estado
    final reservasFiltradasProvider = Provider.family<List<Reserva>, String>((ref, filtro) {
      final reservasAsync = ref.watch(reservasClienteProvider);
      return reservasAsync.when(
        data: (reservas) {
          if (filtro == 'todas') return reservas;
          
          // Filtrar por estado, usando mayúsculas para coincidencia exacta
          return reservas.where((r) => r.estado.toUpperCase() == filtro.toUpperCase()).toList();
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

    // Notifier para operaciones de reserva
    class ReservaActionsNotifier extends StateNotifier<AsyncValue<void>> {
      ReservaActionsNotifier(this._repository) : super(const AsyncValue.data(null));

      final ReservaRepository _repository;

      // Método para crear una nueva reserva
      Future<bool> crearReserva({
        required String mesaId,
        required String fechaReserva,
        required String hora,
        required int cantidadPersonas,
        String? observaciones,
      }) async {
        // Actualizar estado a cargando
        state = const AsyncValue.loading();
        
        try {
          // Validar parámetros requeridos
          if (mesaId.isEmpty || fechaReserva.isEmpty || hora.isEmpty || cantidadPersonas <= 0) {
            throw Exception('Todos los campos son obligatorios');
          }
          
          // Llamar al repositorio para crear la reserva
          final result = await _repository.crearReserva(
            mesaId: mesaId,
            fechaReserva: fechaReserva,
            hora: hora,
            cantidadPersonas: cantidadPersonas,
            observaciones: observaciones ?? '',
          );
          
          // Actualizar estado con éxito
          state = const AsyncValue.data(null);
          return result != null;
        } catch (error, stackTrace) {
          // Actualizar estado con error
          state = AsyncValue.error(error, stackTrace);
          return false;
        }
      }

      // Método para confirmar una reserva existente
      Future<bool> confirmarReserva(String reservaId) async {
        state = const AsyncValue.loading();
        try {
          // Validar ID de reserva
          if (reservaId.isEmpty) {
            throw Exception('ID de reserva no válido');
          }
          
          final result = await _repository.confirmarReserva(reservaId);
          state = const AsyncValue.data(null);
          return result;
        } catch (error, stackTrace) {
          state = AsyncValue.error(error, stackTrace);
          return false;
        }
      }

      // Método para cancelar una reserva
      Future<bool> cancelarReserva(String reservaId, {String? motivo}) async {
        state = const AsyncValue.loading();
        try {
          // Validar ID de reserva
          if (reservaId.isEmpty) {
            throw Exception('ID de reserva no válido');
          }
          
          final result = await _repository.cancelarReserva(reservaId, motivo: motivo ?? 'Cancelado por el cliente');
          state = const AsyncValue.data(null);
          return result;
        } catch (error, stackTrace) {
          state = AsyncValue.error(error, stackTrace);
          return false;
        }
      }
    }

    // Provider para acciones de reserva
    final reservaActionsProvider = StateNotifierProvider<ReservaActionsNotifier, AsyncValue<void>>(
      (ref) => ReservaActionsNotifier(ref.read(reservaRepositoryProvider)),
    );

    // Provider para reservas por fecha (útil para el calendario)
    final reservasPorFechaProvider = Provider.family<List<Reserva>, DateTime>((ref, fecha) {
      final reservasAsync = ref.watch(reservasClienteProvider);
      final fechaStr = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      
      return reservasAsync.when(
        data: (reservas) {
          return reservas.where((r) => r.fechaReserva == fechaStr).toList();
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

    // Provider para verificar si una fecha tiene reservas
    final fechaTieneReservasProvider = Provider.family<bool, DateTime>((ref, fecha) {
      final reservas = ref.watch(reservasPorFechaProvider(fecha));
      return reservas.isNotEmpty;
    });