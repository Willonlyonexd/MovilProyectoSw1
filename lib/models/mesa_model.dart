class Mesa {
  final String mesaId;
  final int numero;
  final bool estado;
  final int capacidad;

  Mesa({
    required this.mesaId,
    required this.numero,
    required this.estado,
    required this.capacidad,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      mesaId: json['mesaId']?.toString() ?? '0',
      // Manejar número nulo - usar 0 o el ID como número
      numero: json['numero'] != null ? int.tryParse(json['numero'].toString()) ?? 0 : 0,
      estado: json['estado'] == true, // Conversión segura
      capacidad: json['capacidad'] != null ? int.tryParse(json['capacidad'].toString()) ?? 0 : 0,
    );
  }

  factory Mesa.empty() {
    return Mesa(
      mesaId: '0',
      numero: 0,
      estado: false,
      capacidad: 0,
    );
  }
}