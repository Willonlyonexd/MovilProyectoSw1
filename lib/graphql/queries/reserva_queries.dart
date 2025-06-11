class ReservaQueries {
  static String get getReservasByCliente => '''
    query GetReservasByCliente(\$tenantId: ID!, \$clienteId: ID!) {
      reservasByTenantIdAndClienteId(tenantId: \$tenantId, clienteId: \$clienteId) {
        reservaId
        fechaReserva
        hora
        cantidadPersonas
        estado
        confirmada
        observaciones
        mesa {
          mesaId
          numero
          capacidad
          estado
        }
        cliente {
          clienteId
          nombre
          apellido
          username
        }
      }
    }
  ''';

  static String get crearReserva => '''
    mutation CrearReserva(\$input: ReservaInput!) {
      createReserva(input: \$input) {
        reservaId
        fechaReserva
        hora
        cantidadPersonas
        estado
        confirmada
        mesa {
          mesaId
          numero
          capacidad
        }
        cliente {
          clienteId
          nombre
          apellido
        }
      }
    }
  ''';

  static String get confirmarReserva => '''
    mutation ConfirmarReserva(\$id: ID!) {
      confirmarReserva(id: \$id) {
        reservaId
        estado
        confirmada
        fechaReserva
        hora
      }
    }
  ''';

  static String get cancelarReserva => '''
    mutation CancelarReserva(\$id: ID!, \$motivo: String) {
      cancelarReserva(id: \$id, motivo: \$motivo) {
        reservaId
        estado
        confirmada
        fechaReserva
        hora
      }
    }
  ''';
}