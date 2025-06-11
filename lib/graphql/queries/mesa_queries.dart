class MesaQueries {
  static String get getMesasDisponibles => '''
    query GetMesasDisponibles(\$tenantId: ID!, \$estado: Boolean!) {
      mesasByTenantIdAndEstado(tenantId: \$tenantId, estado: \$estado) {
        mesaId
        numero
        capacidad
        estado
      }
    }
  ''';

  static String get getCuentasActivas => '''
    query GetCuentasActivas(\$tenantId: ID!) {
      cuentasActivasByTenantId(tenantId: \$tenantId) {
        cuentaMesaId
        estado
        numComensales
        montoTotal
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
}