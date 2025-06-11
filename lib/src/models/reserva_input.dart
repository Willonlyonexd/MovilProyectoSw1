class ReservaInput {
  final int cantidadPersonas;
  final String fechaReserva;
  final String hora;
  final String? observaciones;
  final int clienteId;
  final int mesaId;
  final int tenantId;
  final bool estado;
  final String createdAt;

  ReservaInput({
    required this.cantidadPersonas,
    required this.fechaReserva,
    required this.hora,
    this.observaciones,
    required this.clienteId,
    required this.mesaId,
    required this.tenantId,
    required this.estado,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'cantidadPersonas': cantidadPersonas,
      'fechaReserva': fechaReserva,
      'hora': hora,
      'observaciones': observaciones,
      'clienteId': clienteId,
      'mesaId': mesaId,
      'tenantId': tenantId,
      'estado': estado,
      'createdAt': createdAt,
    };
  }
}
